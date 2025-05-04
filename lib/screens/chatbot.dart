import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animations
import '../utils/colors.dart';
import '../widgets/navbar.dart';

class ChatMessage {
  final bool isUser;
  final String message;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.isUser,
    required this.message,
    required this.timestamp,
    this.isLoading = false,
  });
}

class ChatController extends GetxController {
  // API Configuration
  static const String apiKey = "AIzaSyBnDXrMCoHX50LumJ9wgFRHegawxG6r6co"; // Replace with valid API key
  late final GenerativeModel _model;

  // Observable state
  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final inputController = TextEditingController();

  // For error handling
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeModel();
  }

    Future<void> initializeModel() async {
      try {

        _model = GenerativeModel(
          model: 'gemini-1.5-flash-latest',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1000,
          ),
        );
      } catch (e) {
        hasError.value = true;
        errorMessage.value = 'Failed to initialize AI model: ${e.toString()}';
      }
    }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(
      isUser: true,
      message: text,
      timestamp: DateTime.now(),
    ));

    // Clear input
    inputController.clear();

    // Show loading indicator
    isLoading.value = true;
    messages.add(ChatMessage(
      isUser: false,
      message: "AgriBot is thinking...",
      timestamp: DateTime.now(),
      isLoading: true,
    ));

    try {
      final prompt = """
You are AgriBot, an expert assistant specializing in agriculture and farming. 
You provide helpful advice about crops, plants, farming techniques, soil management, pest control, and agricultural best practices.

User question: $text

Respond in a helpful, educational manner with practical advice. If the question is about a specific crop or plant, 
provide detailed cultivation instructions. If the question is about farming techniques or problems, 
provide specific solutions. Keep your response clear and organized.

If you don't know the answer or the question is unrelated to farming/agriculture, politely explain that you specialize in agriculture 
and redirect the conversation back to farming topics.
""";

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      // Remove loading message
      messages.removeWhere((msg) => msg.isLoading);

      // Add bot response
      if (response.text != null && response.text!.isNotEmpty) {
        messages.add(ChatMessage(
          isUser: false,
          message: response.text!,
          timestamp: DateTime.now(),
        ));
      } else {
        messages.add(ChatMessage(
          isUser: false,
          message: "I couldn't generate a response. Please try again.",
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      // Remove loading message
      messages.removeWhere((msg) => msg.isLoading);

      // Add error message
      messages.add(ChatMessage(
        isUser: false,
        message: "I encountered an error: ${e.toString().split('\n').first}. Please try again.",
        timestamp: DateTime.now(),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void clearChat() {
    messages.clear();
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final ChatController controller = Get.put(ChatController());

    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.whiteColor,
        elevation: 8,
        shadowColor: AppColors.shadowColorDark,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              "AgriBot",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.clearChat,
            tooltip: 'Clear chat',
          ),
        ],
        toolbarHeight: MediaQuery.of(context).size.height / 15,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.85),
              BlendMode.dstATop,
            ),
            image: const AssetImage('assets/images/chatimage.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: Obx(() => controller.messages.isEmpty
                  ? _buildEmptyState()
                  : _buildChatList(controller),
              ),
            ),

            // Input area
            _buildInputArea(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 80,
            color: AppColors.secondary.withOpacity(0.7),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 20),
          Text(
            "Welcome to AgriBot",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Ask me anything about farming, crops, or agriculture!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
          ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildChatList(ChatController controller) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return _buildMessageBubble(message, context);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.secondary
                    : AppColors.whiteColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message.isLoading
                      ? _buildLoadingIndicator()
                      : Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: message.isUser
                          ? AppColors.whiteColor
                          : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: message.isUser
                          ? AppColors.whiteColor.withOpacity(0.7)
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: 300.ms,
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.eco,
        size: 20,
        color: AppColors.secondary,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.person,
        size: 20,
        color: AppColors.whiteColor,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Thinking", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        ...List.generate(
          3,
              (index) => Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.secondaryText,
                shape: BoxShape.circle,
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).fadeIn(
              duration: 600.ms,
              delay: Duration(milliseconds: index * 200),
            ).fadeOut(delay: Duration(milliseconds: 400 + index * 200)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea(ChatController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColorDark,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textField,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.agriculture,
                      color: AppColors.secondary,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.inputController,
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about farming...',
                        hintStyle: TextStyle(color: AppColors.placeholder),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (!controller.isLoading.value) {
                          controller.sendMessage(text);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: controller.isLoading.value
                    ? [AppColors.divider, AppColors.divider]
                    : AppColors.buttonGradient,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: controller.isLoading.value
                      ? Colors.transparent
                      : AppColors.secondary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: controller.isLoading.value
                    ? null
                    : () => controller.sendMessage(controller.inputController.text),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    controller.isLoading.value
                        ? Icons.hourglass_empty
                        : Icons.send,
                    color: controller.isLoading.value
                        ? AppColors.placeholder
                        : AppColors.whiteColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}