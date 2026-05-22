import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:naturats/components/group/gallery_image_picker.dart';

class NewActivitySheet extends StatefulWidget {
  final Future<void> Function({
    required String title,
    required String description,
    required String missionType,
    String? imageBase64,
  }) onCreate;

  const NewActivitySheet({super.key, required this.onCreate});

  @override
  State<NewActivitySheet> createState() => _NewActivitySheetState();
}

class _NewActivitySheetState extends State<NewActivitySheet> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  String? missionType;
  String imageBase64Local = '';

  final List<String> missionTypes = [
    'biodiversidade', 'água', 'energia', 'resíduo', 'mobilidade'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              value: missionType,
              items: missionTypes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) => setState(() => missionType = val),
              decoration: InputDecoration(labelText: 'Tipo de missão'),
            ),
            const SizedBox(height: 12),
            GalleryImagePicker(
              onImageSelected: (base64Image) {
                setState(() => imageBase64Local = base64Image);
              },
            ),
            if (imageBase64Local.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.memory(
                  base64Decode(imageBase64Local),
                  height: 100, width: 100, fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || missionType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha título e tipo de missão')),
                  );
                  return;
                }
                widget.onCreate(
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  missionType: missionType!,
                  imageBase64: imageBase64Local.isNotEmpty ? imageBase64Local : null,
                );
                Navigator.pop(context);
              },
              child: const Text('Publicar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}