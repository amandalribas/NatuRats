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
          // opção de entrar num grupo com o ID
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Entrar com ID"),
            onTap: () => Navigator.pop(context),
          ),
          
          // oção de criar um novo grupo
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text("Criar novo grupo"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}