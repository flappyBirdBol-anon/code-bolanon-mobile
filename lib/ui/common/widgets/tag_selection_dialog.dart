import 'package:flutter/material.dart';

class TagSelectionDialog extends StatefulWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final int maxTags;

  const TagSelectionDialog({
    Key? key,
    required this.availableTags,
    required this.selectedTags,
    this.maxTags = 3,
  }) : super(key: key);

  @override
  _TagSelectionDialogState createState() => _TagSelectionDialogState();
}

class _TagSelectionDialogState extends State<TagSelectionDialog> {
  late Set<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = widget.selectedTags.toSet();
  }

  void _toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.remove(tag);
      });
    } else if (_selectedTags.length < widget.maxTags) {
      setState(() {
        _selectedTags.add(tag);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Course Tags'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose up to ${widget.maxTags} tags that best describe your course:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => _toggleTag(tag),
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedTags.toList()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
