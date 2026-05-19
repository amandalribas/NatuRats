import 'dart:convert';
import 'dart:typed_data';

Uint8List? decodeBase64Image(String value) {
  if (value.isEmpty) {
    return null;
  }

  final normalizedValue = value.contains(',') ? value.split(',').last : value;

  try {
    return base64Decode(normalizedValue);
  } catch (_) {
    return null;
  }
}