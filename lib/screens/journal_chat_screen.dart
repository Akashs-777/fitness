import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../widgets/nav_drawer.dart';
import 'chat_history_screen.dart';

class JournalingChatScreen extends StatefulWidget {
  JournalingChatScreen({super.key});

  @override
  State<JournalingChatScreen> createState() => _JournalingChatScreenState();
}

class _JournalingChatScreenState extends State<JournalingChatScreen> {
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  bool _isLoading = false;
  bool _isAtBottom = true; // Tracks if user is at the bottom
  Timer? _scrollDebounceTimer;

  late final GenerativeModel model;
  late final String userId;
  late String chatName;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollDebounceTimer?.isActive ?? false)
        _scrollDebounceTimer!.cancel();
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
        final atBottom =
            _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 10;
        if (atBottom != _isAtBottom) {
          setState(() {
            _isAtBottom = atBottom;
          });
        }
      });
    });
    if (apiKey != null) {
      model = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'text/plain',
        ),
        systemInstruction: Content.system(
          '"You are a supportive and understanding AI designed to help users reflect on their day and create personalized journal entries. Your primary goal is to guide users through a structured conversation about their experiences, feelings, and thoughts related to the present day.\n\nYour role is to:\n\nEngage in empathetic conversation: Ask open-ended questions about the user\'s day, focusing on key events, feelings, challenges, and moments of joy or gratitude. Examples: "How did your day go?", "What was a highlight of your day?", "Was there anything that challenged you today?", "How are you feeling right now?", "What are you grateful for today?".\n\nActively listen: Pay close attention to the user\'s responses, acknowledging their feelings and showing genuine interest. Use phrases like, "That sounds like it was difficult," or "That\'s wonderful to hear!" or "I understand how you might feel that way."\n\nAsk follow-up questions: Encourage the user to elaborate on their experiences and feelings, prompting deeper reflection. Examples: "Can you tell me more about that?", "How did that make you feel?", "What were you thinking at that moment?", "What did you learn today?".\n\nSummarize and synthesize: After a period of conversation, summarize the key points of the user\'s day, highlighting their experiences, feelings, and thoughts.\n\nGenerate a personalized journal entry: Based on the conversation, create a journal entry that reflects the user\'s day. The entry should capture the user\'s experiences, feelings, and thoughts in a clear, concise, and insightful manner. The style should be warm, encouraging, and focus on positive reframing where appropriate.\n\nImportant Instructions:\n\nStay on topic: Your sole focus is to discuss the user\'s day and generate a journal entry based on that conversation.\n\nRedirection: If the user asks a question or brings up a topic unrelated to reflecting on their day and journaling, respond gently and redirect them back to the intended conversation. For example:\n\nUser: "What\'s the weather like today?"\n\nYou: "That\'s an interesting question! Right now, I\'m focusing on helping you reflect on your day. Perhaps we can talk about how the weather affected your day, or if there is anything else you would like to share and would like me to include it in your journal entry?"\n\nUser: "Can you help me with my homework?"\n\nYou: "I understand you need help with your homework, but right now, my purpose is to help you reflect on your day. Let\'s get back to creating your journal entry so you don\'t forget any important moments!"\n\nUser: "What\'s your favorite color?"\n\nYou: "That\'s a fun question, but let\'s get back to your day for now. It\'s important to get all the info right before i start writing. Is there anything else you like to include in your journal?"\n\nMaintain a supportive and non-judgmental tone: Use empathetic language and avoid offering unsolicited advice.\n\nRespect user privacy: Do not ask for personally identifiable information (PII) such as addresses, phone numbers, or social security numbers.\n\nEthical Considerations: Remind the user that you are not a substitute for professional mental health support: "Remember, I am an AI and cannot provide mental health advice. If you are struggling, please reach out to a qualified professional." (Can be stated if the conversation becomes highly emotional or distressing).\n\nLet\'s begin with: "How did your day go?""',
        ),
      );
    } else {
      log('GEMINI_API_KEY is not set in .env');
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  Future<void> _handleSubmitted(String text) async {
    _textController.clear();

    List<Content> chatHistory = [];
    for (var message in _messages) {
      chatHistory.add(Content(message.sender, [TextPart(message.text)]));
    }

    setState(() {
      _messages.add(ChatMessage(text: text, sender: "user"));
      _isLoading = true;
    });
    if (_isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    await Future.delayed(Duration(seconds: 1));

    final chat = model.startChat(
      history:
          _messages.map((m) => Content(m.sender, [TextPart(m.text)])).toList(),
    );
    final content = Content.text(text);
    final response = await chat.sendMessage(content);

    setState(() {
      if (response.text != null) {
        _messages.add(ChatMessage(text: response.text!, sender: "model"));
        _isLoading = false;
      }
    });
    if (_isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    await Future.delayed(Duration(seconds: 1));

    if (_isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journaling Chat')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder:
                                (context, index) =>
                                    ChatBubble(message: _messages[index]),
                          ),
                          if (!_isAtBottom)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: FloatingActionButton(
                                  onPressed: _scrollToBottom,
                                  child: const Icon(Icons.arrow_downward),
                                  mini: true,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildTextComposer(),
                  ],
                ),
              ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollDebounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final String sender;
  ChatMessage({required this.text, required this.sender});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({Key? key, required this.message}) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copied to clipboard")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to copy: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == "user";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: isUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SelectableText(
                  message.text,
                ),
              ),
              ),
               Padding(
                 padding: const EdgeInsets.only(top: 10.0),
                 child: IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  color: Theme.of(context).colorScheme.primary,
                onPressed: () => _copyToClipboard(context, message.text),
                tooltip: "Copy",
                                 ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}