import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPopup extends StatefulWidget {
  @override
  _SettingsPopupState createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  String? _selectedProvider;
  final TextEditingController _modelNameController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();

  // Model providers with associated icons
  final Map<String, IconData> _modelProviders = {
    'Free': Icons.free_breakfast_rounded,
    'Ollama': Icons.cloud_upload_rounded,
    'LLM Studio': Icons.build_circle_rounded,
  };

  // Default base URLs for providers
  final Map<String, String> _defaultBaseUrls = {
    'Ollama': 'http://localhost:11434',
    'LLM Studio': '',
  };

  // Load saved data when the widget initializes
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Load saved data from SharedPreferences
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedProvider = prefs.getString('selectedProvider') ?? 'Free';
      _modelNameController.text = prefs.getString('modelName') ?? '';
      _baseUrlController.text = prefs.getString('baseUrl') ??
          (_selectedProvider != null && _defaultBaseUrls[_selectedProvider] != null
              ? _defaultBaseUrls[_selectedProvider]!
              : '');
    });
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedProvider', _selectedProvider!);
    await prefs.setString('modelName', _modelNameController.text);
    await prefs.setString('baseUrl', _baseUrlController.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Settings',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Model Provider Dropdown with Icons
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Model Provider',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.anchor_outlined, color: Colors.blue),
              ),
              value: _selectedProvider,
              items: _modelProviders.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(entry.value, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(entry.key),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProvider = newValue;
                  // Set default base URL if available
                  if (_defaultBaseUrls.containsKey(newValue)) {
                    _baseUrlController.text = _defaultBaseUrls[newValue]!;
                  } else {
                    _baseUrlController.clear();
                  }
                });
              },
            ),
            SizedBox(height: 16),

            // Conditional Fields for Ollama and LLM Studio
            if (_selectedProvider != 'Free')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure ${_selectedProvider} Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),

                  // Model Name Field
                  TextFormField(
                    controller: _modelNameController,
                    decoration: InputDecoration(
                      labelText: 'Model Name',
                      hintText: 'Enter the name of the model',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.model_training_rounded, color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Base URL Field
                  TextFormField(
                    controller: _baseUrlController,
                    decoration: InputDecoration(
                      labelText: 'Base URL',
                      hintText: 'Enter the base URL for the API',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link_rounded, color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Save the data
            await _saveData();
            // Print the saved values for debugging
            print('Selected Provider: $_selectedProvider');
            print('Model Name: ${_modelNameController.text}');
            print('Base URL: ${_baseUrlController.text}');
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}