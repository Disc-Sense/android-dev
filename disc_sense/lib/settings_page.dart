import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _playerController = TextEditingController();
  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Cloud Storage',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _playerController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Connection String',
              prefixIcon: Icon(Icons.cloud_upload),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Privacy Settings',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings Saved')),
              );
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}


