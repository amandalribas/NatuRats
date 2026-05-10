import 'package:flutter/material.dart';
import 'package:naturats/components/group/gallery_image_picker.dart';
import 'package:naturats/components/group/group_textfield.dart';
import 'package:naturats/controller/group_controller.dart';
import 'package:naturats/theme/app_colors.dart';

class GroupFormPage extends StatefulWidget {
  const GroupFormPage({super.key});

  @override
  State<GroupFormPage> createState() => _GroupFormPageState();
}

class _GroupFormPageState extends State<GroupFormPage> {
  final GroupController _groupController = GroupController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _imageBase64 = '';
  bool _isPublic = false;

  void _onImageSelected(String base64Image) {
    setState(() {
      _imageBase64 = base64Image;
    });
  }

  void _handleCreateGroup() {
    final name = _nameController.text;
    final description = _descriptionController.text;

    if (name.isEmpty || description.isEmpty || _imageBase64.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    _groupController.createGroup(
      name: name,
      description: description,
      imageBase64: _imageBase64,
      isPublic: _isPublic,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Grupo", style: TextStyle(color: AppColors.branco)),
        backgroundColor: AppColors.bgVerde,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          GroupTextField(
            label: "Nome do Grupo",
            controller: _nameController,
          ),
          const SizedBox(height: 20),
          GroupTextField(
            label: "Descrição do Grupo",
            controller: _descriptionController,
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text("Grupo Público"),
            value: _isPublic,
            onChanged: (value) {
              setState(() {
                _isPublic = value;
              });
            },
          ),
          const SizedBox(height: 20),
          GalleryImagePicker(
            onImageSelected: _onImageSelected,
          ),
          const SizedBox(height: 20),
          const Spacer(),
          ElevatedButton(
            onPressed: _handleCreateGroup,
            child: const Text('Criar Grupo'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

