import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PocketLLM',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'A lightweight AI-powered chatbot designed for seamless conversations.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}