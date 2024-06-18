import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proteus/chat_screen.dart';
import 'package:proteus/constants.dart';
import 'package:proteus/input_bay.dart';
import 'package:proteus/target_menu.dart';

// Conditional imports
import 'platform_interaction_stub.dart'
    if (dart.library.html) 'platform_interaction_web.dart'
    if (dart.library.io) 'platform_interaction_mobile.dart'
    as platform_interaction;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ).copyWith(
        textTheme: GoogleFonts.ralewayTextTheme(),
      ),
      themeMode: ThemeMode.dark, // Set default theme mode to dark
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String pageContent = "";
  final GlobalKey<ChatScreenState> _chatScreenKey =
      GlobalKey<ChatScreenState>();

  @override
  void initState() {
    super.initState();
    platform_interaction.initializePlatformListener((content) {
      setState(() {
        pageContent = content;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: Text(
          'PROTEUS',
          style: GoogleFonts.raleway(
            fontSize: 16,
            textStyle: const TextStyle(
              letterSpacing: 3.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
          const SizedBox(
            width: 4,
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              GradientOne.purple,
              GradientOne.blurple,
              GradientOne.blue,
              GradientOne.green,
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: AppBar().preferredSize.height,
            ),
            Expanded(
              child: ChatScreen(key: _chatScreenKey),
            ),
            Container(
              color: Colors.white10,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const TargetMenu(),
                    const SizedBox(height: 16.0),
                    InputBay(
                      onSendMessage: (message) {
                        _chatScreenKey.currentState?.addMessage(message);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
