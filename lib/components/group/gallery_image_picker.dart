import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class GalleryImagePicker extends StatefulWidget {
  const GalleryImagePicker({super.key, required this.onImageSelected});

  final Function(String base64Image) onImageSelected;

  @override
  State<GalleryImagePicker> createState() => _GalleryImagePickerState();
}

class _GalleryImagePickerState extends State<GalleryImagePicker> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;

  Uint8List _compressImage(Uint8List bytes) {
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) {
      return bytes;
    }

    final resizedImage = decodedImage.width > 1280
        ? img.copyResize(decodedImage, width: 1280)
        : decodedImage;

    final compressedBytes = img.encodeJpg(resizedImage, quality: 75);
    return Uint8List.fromList(compressedBytes);
  }

  Future<void> _openGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final compressedBytes = _compressImage(bytes);
    if (!mounted) return;

    setState(() {
      _imageBytes = compressedBytes;
    });

    final base64String = base64Encode(compressedBytes);

    widget.onImageSelected(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _openGallery,
          icon: const Icon(Icons.photo_library),
          label: const Text('Selecionar imagem da galeria'),
        ),
        const SizedBox(height: 12),
        if (_imageBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _imageBytes!,
              height: 180,
              fit: BoxFit.cover,
            ),
          )
        else
          const Text('Nenhuma imagem selecionada.'),
      ],
    );
  }
}

