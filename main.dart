import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/feeds_screen.dart';
import 'screens/home_screen.dart';
import 'screens/course_feed_screen.dart';
import 'screens/comment_feed_screen.dart';

void main() {
  runApp(PPUFeedsApp());
}

class PPUFeedsApp extends StatelessWidget {
  const PPUFeedsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPU Feeds',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/feeds': (context) => FeedsScreen(),
        '/home': (context) => HomeScreen(),
        '/course_feed': (context) => CourseFeedScreen(),
        '/comment_feed': (context) => CommentFeedScreen(),
      },
    );
  }
}