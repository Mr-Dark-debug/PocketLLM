import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'chat_interface.dart';

class HomeScreen extends StatelessWidget {
  void _openSettings() {
    // Handle settings press
    print('Settings pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appName: 'PocketLLM',
        onSettingsPressed: _openSettings,
      ),
      body: ChatInterface(),
    );
  }
}
