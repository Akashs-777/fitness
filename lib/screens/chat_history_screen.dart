import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/chat_screen.dart';

import '../models/chat_list_model.dart';
import '../services/api_service.dart';

class ChatHistoryScreen extends StatefulWidget {
  final String userId;
  const ChatHistoryScreen({super.key, required this.userId});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final List<ChatListModel> _chats = [];
  List<ChatListModel> _filteredChats = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredChats = List.from(_chats);
    _searchController.addListener(_onSearchChanged);
    _loadChats();
  }

  void _loadChats() async {
    try {
      List<ChatListModel>? chatList = await _fetchChats();
      setState(() {
        _chats.clear();
        // _chats.addAll(chats);
        // _filteredChats = List.from(_chats);
      });
      for (var chat in chatList!) {
        if (kDebugMode) {
          print('${chat.chatName}: ${chat.chatSessionId} : ${chat.createdAt}');
        } // Debugging
        setState(() {
          _chats.add(chat);
        });
      }
      setState(() {
        _filteredChats = List.from(_chats);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<List<ChatListModel>?> _fetchChats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.get('chats/${widget.userId}');

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        final List<dynamic> jsonData = jsonDecode(response.body);

        return jsonData
            .map((item) => ChatListModel.fromJson(item))
            .toList(); // Map JSON to Chat objects
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print(e);
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load chats: $e')));
    }
    return null;
  }

  String formatDateTimePST(String dateTimeString) {
    // Parse the input string into a DateTime object (UTC).
    DateTime utcDateTime = DateTime.parse(dateTimeString);

    // Convert the UTC DateTime to PST.
    // PST is UTC-8, so we subtract 8 hours.
    DateTime pstDateTime = utcDateTime.subtract(Duration(hours: 8));

    // Format the PST DateTime into a string.
    // You can customize the format as needed.
    // Example: 'yyyy-MM-dd HH:mm:ss' for '2023-10-27 10:30:00'
    // Example: 'MMM dd, yyyy hh:mm a' for 'Oct 27, 2023 10:30 AM'
    String formattedDateTime = DateFormat(
      'MMM dd, yyyy hh:mm a',
    ).format(pstDateTime);

    return formattedDateTime;
  }

  Future<void> _deleteChat(String chatSessionId) async {
    try {
      final response = await ApiService.delete('chat/$chatSessionId');
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Chat deleted successfully: $chatSessionId');
        }
        _loadChats();
      } else {
        throw Exception('Failed to delete chat');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting chat: $e');
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete chat: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChats =
          _chats.where((chat) {
            final chatName = chat.chatName.toLowerCase();
            final createdAt = chat.createdAt.toLowerCase();
            return chatName.contains(query) || createdAt.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    PreferredSize? bottomAppBar;
    if (_isSearchBarVisible) {
      bottomAppBar = PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by name or date',
            ),
          ),
        ),
      );
    } else {
      bottomAppBar = null;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchBarVisible = !_isSearchBarVisible;
              });
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        ],
        bottom: bottomAppBar,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = _filteredChats[index];
                  return ListTile(
                    title: Text(
                      chat.chatName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(formatDateTimePST(chat.createdAt)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteChat(chat.chatSessionId);
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ChatScreen(chatSessionId: chat.chatSessionId),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

class ChatSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, String>> chats;
  ChatSearchDelegate({required this.chats});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text('');
  }
}