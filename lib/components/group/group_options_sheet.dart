import 'package:flutter/material.dart';
import 'package:naturats/view/group_form_page.dart';

class GroupOptionsSheet extends StatelessWidget {
  const GroupOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        
        children: [
          // oção de criar um novo grupo
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text("Criar novo grupo"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupFormPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}