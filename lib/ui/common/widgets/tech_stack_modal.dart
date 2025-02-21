import 'package:flutter/material.dart';

class TechStackModal extends StatelessWidget {
  final List<String> techStacks;
  final Function(String) onRemove;
  final Function(String) onAdd;

  const TechStackModal({
    Key? key,
    required this.techStacks,
    required this.onRemove,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Changed from builder to build
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage Tech Stack',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: techStacks
                .map((tech) => Chip(
                      label: Text(tech),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => onRemove(tech),
                      backgroundColor: Colors.grey[200],
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddTechStackDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add New Tech Stack'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTechStackDialog(BuildContext context) {
    String newTechStack = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Tech Stack'),
        content: TextField(
          onChanged: (value) => newTechStack = value,
          decoration: const InputDecoration(
            hintText: 'Enter tech stack name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newTechStack.isNotEmpty) {
                onAdd(newTechStack);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
