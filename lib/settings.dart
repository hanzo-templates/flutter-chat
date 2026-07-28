import 'package:flutter/material.dart';

import 'hanzo.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = Hanzo.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Field(label: 'API base', initial: h.base, onChanged: (v) => h.base = v),
          _Field(label: 'Model', initial: h.model, onChanged: (v) => h.model = v),
          _Field(
            label: 'API key',
            initial: h.key,
            obscure: true,
            hint: 'Held in memory only. Persist it with flutter_secure_storage before you ship.',
            onChanged: (v) => h.key = v,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.initial,
    required this.onChanged,
    this.obscure = false,
    this.hint,
  });

  final String label, initial;
  final String? hint;
  final bool obscure;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: initial,
              obscureText: obscure,
              autocorrect: false,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: obscure ? 'sk-…' : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(hint!, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ],
        ),
      );
}
