import 'package:flutter/material.dart';

class GroupOptionsSheet extends StatelessWidget {
  const GroupOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        
        children: [
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text("Criar novo grupo"),
            onTap: () => Navigator.pop(context, 'create_group'),
          ),
        ],
      ),
    );
  }
}