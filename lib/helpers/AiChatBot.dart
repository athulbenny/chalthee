
import 'package:flutter/material.dart';

class ChatAlertDialog extends StatefulWidget {
  const ChatAlertDialog({super.key});

  @override
  State<ChatAlertDialog> createState() => _ChatAlertDialogState();
}

class _ChatAlertDialogState extends State<ChatAlertDialog> {
  // final model =
  // FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isWaitingForAI = false;

  Future<String> getAIResponse(String userMessage) async {
    // final response = await model.generateContent([Content.text(userMessage)]);
    return "AI says: I received '";
  }

  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isWaitingForAI = true;
    });

    String aiResponse = await getAIResponse(text);

    setState(() {
      _messages.add(ChatMessage(text: aiResponse, isUser: false));
      _isWaitingForAI = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(8),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // adjust height as needed
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length + (_isWaitingForAI ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isWaitingForAI && index == 0) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "AI is typing...",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  final message = _messages[_isWaitingForAI ? index - 1 : index];
                  return Align(
                    alignment:
                    message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isUser ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isWaitingForAI ? null : _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}


class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}