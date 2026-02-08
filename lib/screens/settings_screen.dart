import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restrictions.dart';
import '../services/restriction_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.store});

  static const routeName = '/settings';

  final RestrictionStore store;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveRestrictions(RestrictionsModel model) async {
    setState(() {
      _isSaving = true;
    });
    await widget.store.saveRestrictions(model.restrictions);
    setState(() {
      _isSaving = false;
    });
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restrictions saved for offline use.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RestrictionsModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Dietary Restrictions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add allergies, ingredients, or dietary rules (e.g., peanuts, gluten, vegan, halal).',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'New restriction',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      model.addRestriction(value);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    model.addRestriction(_controller.text);
                    _controller.clear();
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: model.restrictions
                  .map(
                    (restriction) => Chip(
                      label: Text(restriction),
                      onDeleted: () => model.removeRestriction(restriction),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : () => _saveRestrictions(model),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save restrictions offline'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
