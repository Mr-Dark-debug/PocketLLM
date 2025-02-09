import 'package:flutter/material.dart';
import '../models/provider_settings.dart';

class SettingsDialog extends StatefulWidget {
  final Function(ProviderSettings) onSettingsChanged;

  const SettingsDialog({
    super.key,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  LLMProvider _selectedProvider = LLMProvider.local;
  String? _selectedModel;
  final TextEditingController _modelNameController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  List<Model> _localModels = [];

  @override
  void initState() {
    super.initState();
    _localModels = ProviderSettings.getLocalModels();
    if (_localModels.isNotEmpty) {
      _selectedModel = _localModels[0].id;
    }
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Widget _buildProviderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provider',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<LLMProvider>(
          segments: const [
            ButtonSegment(
              value: LLMProvider.local,
              label: Text('Local'),
            ),
            ButtonSegment(
              value: LLMProvider.ollama,
              label: Text('Ollama'),
            ),
            ButtonSegment(
              value: LLMProvider.llmStudio,
              label: Text('LLM Studio'),
            ),
          ],
          selected: {_selectedProvider},
          onSelectionChanged: (Set<LLMProvider> newSelection) {
            setState(() {
              _selectedProvider = newSelection.first;
              _selectedModel = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildModelSelection() {
    if (_selectedProvider == LLMProvider.local) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Model',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedModel,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            items: _localModels.map((model) {
              return DropdownMenuItem(
                value: model.id,
                child: Text(
                  model.id,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedModel = value;
              });
            },
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Model Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _modelNameController,
            decoration: InputDecoration(
              hintText: 'Enter model name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Base URL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _baseUrlController,
            decoration: InputDecoration(
              hintText: _selectedProvider == LLMProvider.ollama
                  ? 'http://localhost:11434/api'
                  : 'http://localhost:1234/v1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
        ],
      );
    }
  }

  void _saveSettings() {
    final settings = ProviderSettings(
      provider: _selectedProvider,
      modelName: _selectedProvider == LLMProvider.local
          ? _selectedModel!
          : _modelNameController.text,
      baseUrl: _selectedProvider != LLMProvider.local ? _baseUrlController.text : null,
    );
    widget.onSettingsChanged(settings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProviderSelection(),
            const SizedBox(height: 24),
            _buildModelSelection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 