import 'package:flutter/material.dart';
import '../models/provider_settings.dart';

class SettingsDialog extends StatefulWidget {
  final Function(ProviderSettings) onSettingsChanged;
  final ProviderSettings? currentSettings;

  const SettingsDialog({
    super.key,
    required this.onSettingsChanged,
    this.currentSettings,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late LLMProvider _selectedProvider;
  String? _selectedModel;
  final TextEditingController _modelNameController = TextEditingController();
  final TextEditingController _baseUrlController = TextEditingController();
  List<Model> _localModels = [];
  bool _isLoading = false;
  bool _isAdvancedMode = false;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.currentSettings?.provider ?? LLMProvider.local;
    _localModels = ProviderSettings.getLocalModels();
    _selectedModel = widget.currentSettings?.modelId ?? (_localModels.isNotEmpty ? _localModels[0].id : null);
    _baseUrlController.text = widget.currentSettings?.baseUrl ?? '';
    _modelNameController.text = widget.currentSettings?.modelName ?? '';
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildProviderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Model Provider'),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<LLMProvider>(
                  value: _selectedProvider,
                  decoration: InputDecoration(
                    labelText: 'Select Provider',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: LLMProvider.local,
                      child: _buildProviderOption(
                        Icons.computer,
                        'Local',
                        'Run models directly on your device',
                      ),
                    ),
                    DropdownMenuItem(
                      value: LLMProvider.ollama,
                      child: _buildProviderOption(
                        Icons.cloud,
                        'Ollama',
                        'Connect to Ollama server',
                      ),
                    ),
                    DropdownMenuItem(
                      value: LLMProvider.llmStudio,
                      child: _buildProviderOption(
                        Icons.science,
                        'LLM Studio',
                        'Connect to LLM Studio server',
                      ),
                    ),
                  ],
                  onChanged: (LLMProvider? value) {
                    if (value != null) {
                      setState(() {
                        _selectedProvider = value;
                        _selectedModel = null;
                      });
                    }
                  },
                ),
                if (_selectedProvider != LLMProvider.local) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _baseUrlController,
                    decoration: InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'http://localhost:11434',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderOption(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildModelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Model Selection'),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedProvider == LLMProvider.local)
                  _buildLocalModelSelection()
                else
                  _buildRemoteModelSelection(),
                if (_isAdvancedMode) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modelNameController,
                    decoration: InputDecoration(
                      labelText: 'Custom Model Name',
                      hintText: 'Enter custom model identifier',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocalModelSelection() {
    if (_localModels.isEmpty) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No local models found',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Please download a model first or switch to a remote provider.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedModel,
      decoration: InputDecoration(
        labelText: 'Select Model',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      items: _localModels.map((model) {
        return DropdownMenuItem(
          value: model.id,
          child: Text(model.id),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedModel = value;
        });
      },
    );
  }

  Widget _buildRemoteModelSelection() {
    return TextFormField(
      controller: _modelNameController,
      decoration: InputDecoration(
        labelText: 'Model Name',
        hintText: _selectedProvider == LLMProvider.ollama ? 'llama2' : 'model-name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: Icon(
                    _isAdvancedMode ? Icons.settings : Icons.settings_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isAdvancedMode = !_isAdvancedMode;
                    });
                  },
                  tooltip: 'Advanced Settings',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProviderSelection(),
                    const SizedBox(height: 24),
                    _buildModelSelection(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final settings = ProviderSettings(
                      provider: _selectedProvider,
                      modelId: _selectedModel,
                      modelName: _modelNameController.text.trim(),
                      baseUrl: _baseUrlController.text.trim(),
                    );
                    widget.onSettingsChanged(settings);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 