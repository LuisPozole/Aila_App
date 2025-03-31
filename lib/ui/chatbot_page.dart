import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  File? profileImage;

  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final username = await storage.read(key: "username");
      if (username == null) return;

      final base64Image = await storage.read(key: 'profile_image_$username');
      if (base64Image != null && base64Image.isNotEmpty) {
        final bytes = base64Decode(base64Image);
        final tempDir = await Directory.systemTemp.createTemp();
        final file = File('${tempDir.path}/profile_image.png');
        await file.writeAsBytes(bytes);

        setState(() {
          profileImage = file;
        });
      }
    } catch (e) {
      print('Error al cargar imagen: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "text": message});
    });

    String apiKey = "AIzaSyDSPU3HTfAB_jnIwi--8yhBGzUtUVs5N6U";
    String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey";

    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [{"text": message}]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String botResponse = data["candidates"][0]["content"]["parts"][0]["text"];

      setState(() {
        _messages.add({"role": "bot", "text": botResponse});
      });
    } else {
      setState(() {
        _messages.add({"role": "bot", "text": "Error al obtener respuesta."});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatea con Aila"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var msg = _messages[index];
                bool isUser = msg["role"] == "user";
                String roleLabel = isUser ? "Yo" : "Aila";

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment:
                        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          roleLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUser ? Colors.blueAccent : Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment:
                            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isUser)
                            CircleAvatar(
                              backgroundImage: AssetImage("assets/mascota2.png"),
                              radius: 20,
                            ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.all(12),
                            constraints: BoxConstraints(maxWidth: 250),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blueAccent : Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg["text"]!,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (isUser)
                            CircleAvatar(
                              backgroundImage: profileImage != null
                                  ? FileImage(profileImage!)
                                  : AssetImage("assets/placeholder.png") as ImageProvider,
                              radius: 20,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}