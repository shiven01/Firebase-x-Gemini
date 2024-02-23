import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase application
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCWMh2qdGf_ikLdJ4FchyxiefpuCC4nLqs",
      authDomain: "fir-x-gemini-c13cd.firebaseapp.com",
      projectId: "fir-x-gemini-c13cd",
      storageBucket: "fir-x-gemini-c13cd.appspot.com",
      messagingSenderId: "131366233798",
      appId: "1:131366233798:web:87c2e1564a9baacf9b19c7",
      measurementId: "G-PQ18H8Y5XM"
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Workshop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system, // Try changing theme to `light`
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text controller stores the data of the TextField it's assigned to
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat'), // Try changing AppBar title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Vertically centered column
          children: [
            // Expanded takes up the whole space
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('generate')
                    // .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Show error text on error
                  if (snapshot.hasError) {
                    return Center(child: Text('$snapshot.error'));
                  } else if (!snapshot.hasData) {
                    // Show circular loading indicator while loading
                    return const Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, i) {
                      final data = docs[i].data();

                      // Show two messages - user's prompt and Gemini's response
                      return Column(
                        children: [
                          ChatBubble(
                            isUser: true,
                            text: data['prompt'] ?? '',
                          ),
                          ChatBubble(
                            isUser: false,
                            text: data['response'] ?? '',
                            isLoading: data['response'] == null,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your message and hit Enter',
                ),
                onSubmitted: (String value) {
                  messageController.clear();
                  FirebaseFirestore.instance.collection('generate').add({
                    'prompt': value,
                    'timestamp': DateTime.now(),
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isUser; // is it user's message or AI's response?
  final String text; // message text
  final bool isLoading; // is the message loading?

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              // Take up to 80% of the screen
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), // Try changing this
              color: isUser
                  ? Colors.indigo
                  : Theme.of(context).colorScheme.onInverseSurface, // Play around with the color
            ),
            child: isLoading
                ? const CircularProgressIndicator()
                : Text(
                    text,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.onBackground, // Play around with the color
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
