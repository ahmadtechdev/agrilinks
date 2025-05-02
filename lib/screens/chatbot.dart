
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';
import '../widgets/navbar.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userInput = TextEditingController();
  static const apiKey = "AIzaSyCgFagW7p8FXQueEXxg2lySg_RGA3I6F_8";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [];
  bool _isRequestInProgress = false;

  Future<void> sendMessage() async {
    final message = _userInput.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
      _isRequestInProgress = true;
    });

    final content = [
      Content.text(
        "GPT, upon receiving the name of a crop or plant, provide instructions for cultivation, including details on seed selection, planting, watering, fertilizing, and other required activities. "
            "The response should be in a structured format, consisting of instructions divided into sections. Each section can contain 2 to 10 lines of text without any additional information. "
            "The crop or plant is $message. If the input is not recognized, respond with 'Unrecognized crop or plant.'",
      )
    ];



    // Adding a temporary "GPT is writing" message
    setState(() {
      _messages.add(Message(isUser: false, message: "AgriBot  is typing...", date: DateTime.now(), isTemporary: true));
    });

    final response = await model.generateContent(content);

    setState(() {
      // Remove the temporary message
      _messages.removeWhere((msg) => msg.isTemporary);

      _messages.add(Message(isUser: false, message: response.text ?? "", date: DateTime.now()));
      _isRequestInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,

        foregroundColor: wColor,
        title: const Text(
          "AgriBot",
          style: TextStyle(
              color: wColor, fontSize: 25, fontWeight: FontWeight.w900),
        ),
        toolbarHeight: MediaQuery.of(context).size.height / 15, // Set your desired height here
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: const AssetImage('assets/images/chatimage.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Messages(
                    isUser: message.isUser,
                    message: message.message,
                    date: DateFormat('HH:mm').format(message.date),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        label: const Text('Enter crop or plant name', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: const EdgeInsets.all(12),
                    iconSize: 30,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(primaryColor),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(const CircleBorder()),
                    ),
                    onPressed: _isRequestInProgress ? null : sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;
  final bool isTemporary;

  Message({required this.isUser, required this.message, required this.date, this.isTemporary = false});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
          topRight: const Radius.circular(10),
          bottomRight: isUser ? Radius.zero : const Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 16, color: isUser ? Colors.white : Colors.black),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 10, color: isUser ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}
