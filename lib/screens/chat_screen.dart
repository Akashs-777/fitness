import 'package:flutter/material.dart';
import 'dart:math' as math;


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      messageContent: "Hello, Will",
      messageType: "receiver",
    ),
    ChatMessage(
      messageContent: "How have you been?",
      messageType: "receiver",
    ),
    ChatMessage(
        messageContent: "Hey Kriss, I am doing fine dude. wbu?",
        messageType: "sender"),
    ChatMessage(
        messageContent: "ehhhh, doing OK.", messageType: "receiver"),
    ChatMessage(
        messageContent: "Is there any thing wrong?", messageType: "sender"),
  ];

  final TextEditingController _messageController = TextEditingController();

  void _handleSubmitted(String text) {
    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(messageContent: text, messageType: "sender"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
             DrawerHeader(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary
              ),
              child: Text(
                'Navigation Drawer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text('Profile'), onTap: () {}),
            ListTile(
              leading: Icon(Icons.food_bank),
              title: const Text('Supplements'), onTap: () {}),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: const Text('Exercise'), onTap: () {}),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Chat Screen"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final reversedIndex = _messages.length - 1 - index;
                return ChatBubble(message: _messages[reversedIndex]);
              },
            ),
          ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _messageController,
              onSubmitted: _handleSubmitted,
              decoration:
                  const InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
                icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_messageController.text),
              hoverColor: Colors.blue[100], 
              splashColor: Colors.blue[200],
              
            ),
          ),
          const Symbol(),
        ],
      ),
    );
  }
}
class Symbol extends StatefulWidget {
  const Symbol({Key? key}) : super(key: key);
  @override
  _SymbolState createState() => _SymbolState();
}
class _SymbolState extends State<Symbol> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovering = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_isHovering && _controller.status == AnimationStatus.dismissed) _controller.forward();
          if (!_isHovering && _controller.status == AnimationStatus.completed) _controller.reverse();
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: Icon(Icons.star, color: Color.lerp(Colors.grey, Colors.yellow, _controller.value)),
            ),
        },
      ),
    );
  }
}

class ChatMessage {
  String messageContent;
  String messageType;
  ChatMessage({required this.messageContent, required this.messageType});
}

class ChatBubble extends StatelessWidget {

  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  void initState() {
    
  }
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: (message.messageType == "receiver"
            ? Alignment.topLeft
            : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (message.messageType == "receiver"
                ? Colors.grey.shade200
                : Colors.blue[200]),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            message.messageContent,
            style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
