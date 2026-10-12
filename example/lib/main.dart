import 'package:flutter/material.dart';
import 'package:video_walkthrough/video_walkthrough.dart';

void main() => runApp(const ExampleApp());

/// Shows a [VideoWalkThrough] and opens [HomeScreen] when the user taps Start.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  static const TextStyle _titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const List<Walkthrough> _pages = <Walkthrough>[
    Walkthrough(
      title: 'Welcome aboard',
      content: 'A looping video sets the mood while users learn the basics.',
      titleStyle: _titleStyle,
    ),
    Walkthrough(
      title: 'Swipe or tap Continue',
      content: 'Every page slides in with a subtle animation.',
      titleStyle: _titleStyle,
    ),
    Walkthrough(
      title: 'Make it yours',
      content: 'Colors, texts, styles, logo and dots are all configurable.',
      titleStyle: _titleStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'video_walkthrough example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: VideoWalkThrough(
        video: 'assets/intro.mp4',
        volume: 0,
        walkthroughList: _pages,
        smallImage: 'assets/logo.png',
        smallImageSize: 72,
        indicatorActiveColor: Colors.white,
        indicatorInActiveColor: Colors.white38,
        startBtnColor: const Color(0xFFF59E0B),
        replaceOnFinish: true,
        pageRoute: MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      ),
    );
  }
}

/// The screen users land on after the walkthrough.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Walkthrough finished.')),
    );
  }
}
