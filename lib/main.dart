import 'package:flutter/material.dart';
import 'component/splash_screen.dart';
import 'component/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketLLM',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: SplashLoader(),
    );
  }
}

class SplashLoader extends StatefulWidget {
  @override
  _SplashLoaderState createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<SplashLoader> {
  void _onAnimationComplete() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onAnimationComplete: _onAnimationComplete);
  }
}
