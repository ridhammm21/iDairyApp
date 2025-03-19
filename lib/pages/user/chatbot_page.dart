import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:idairy/utils/global_colors.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'bot');

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _sendGreeting(); // Greet the user when they open the app
  }

  void _sendGreeting() {
    final greetingMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: "Hello! Welcome to iDairy. 😊 How can I assist you today? Feel free to ask about our dairy products!",
    );
    _addMessage(greetingMessage);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(userMessage);
    _generateResponse(message.text);
  }

  Future<void> _generateResponse(String prompt) async {
    // Display Typing Indicator
    final typingMessage = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: "Typing...",
    );
    _addMessage(typingMessage);

    const apiKey = "AIzaSyDgAZoZUTGb3dS7tYD2-z1XM_vw5-rolTE"; // Replace with your actual API key
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);

    String initialContext = """
      You are an AI assistant for iDairy, an online dairy store. The store offers dairy products within these price ranges:
      - When a customer says hi or hello, greet or welcome them properly.
      - Milk: ₹60 per liter
      - Cheese: ₹85 per 100 gm
      - Butter: ₹250 per 500 gm
      - Yogurt: ₹150 per kg
      - Ghee: ₹1000 per kg
      - When a customer says bye or thank you, wish them well and invite them to visit again.

      Always answer based on these details. If the query is unrelated to dairy products, reply with:
      "Please ask about dairy-related products like milk, cheese, butter, etc."
    """;

    String finalPrompt = "$initialContext \n\nUser's Query: $prompt";
    final content = [Content.text(finalPrompt)];

    try {
      final response = await model.generateContent(content);
      setState(() {
        _messages.removeWhere((msg) => msg.id == typingMessage.id);
      });

      final replyText = types.TextMessage(
        author: _bot,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: response.text ?? "Sorry, I couldn't understand.",
      );

      _addMessage(replyText);
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg.id == typingMessage.id);
        _addMessage(types.TextMessage(
          author: _bot,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: "Error: Unable to generate response.",
        ));
      });
    }
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Chatbot"),
          backgroundColor: GlobalColors.primary,
          foregroundColor: GlobalColors.textColor,
          elevation: 0,
        ),
        body: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
          theme: DefaultChatTheme(
            inputBackgroundColor: GlobalColors.primary, // Input field color
            inputTextColor: Colors.white, // Text color inside input field
            sendButtonIcon: const Icon(Icons.send, color: Colors.white), // Send button color
          ),
        ),
      );
}
