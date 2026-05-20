import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Simple global cache to avoid re-decoding the same base64 repeatedly.
final Map<String, Uint8List> _groupHeaderImageCache = {};

// Top-level isolate-safe decoder for compute
Uint8List _decodeBase64Isolate(String data) {
  final comma = data.indexOf(',');
  final payload = comma != -1 ? data.substring(comma + 1) : data;
  return base64Decode(payload);
}

class GroupDetailsHeader extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int people;
  final int points;
  final VoidCallback? onInvite;

  const GroupDetailsHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.people,
    required this.points,
    this.onInvite,
  });

  @override
  State<GroupDetailsHeader> createState() => _GroupDetailsHeaderState();
}

class _GroupDetailsHeaderState extends State<GroupDetailsHeader> {
  Uint8List? _bytes;
  bool _decoding = false;

  @override
  void initState() {
    super.initState();
    _ensureImageDecoded();
  }

  @override
  void didUpdateWidget(covariant GroupDetailsHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _ensureImageDecoded();
    }
  }

  void _ensureImageDecoded() {
    final imageUrl = widget.imageUrl;
    if (imageUrl.isEmpty) {
      setState(() {
        _bytes = null;
      });
      return;
    }

    // If cached, use it immediately
    if (_groupHeaderImageCache.containsKey(imageUrl)) {
      setState(() {
        _bytes = _groupHeaderImageCache[imageUrl];
      });
      return;
    }

    final isDataUri = imageUrl.startsWith('data:image');
    final isLikelyBase64 = isDataUri || imageUrl.length > 200;

    if (!isLikelyBase64) {
      setState(() {
        _bytes = null;
      });
      return;
    }

    // decode in isolate
    if (_decoding) return;
    _decoding = true;
    compute(_decodeBase64Isolate, imageUrl).then((result) {
      _groupHeaderImageCache[imageUrl] = result;
      if (mounted) {
        setState(() {
          _bytes = result;
          _decoding = false;
        });
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _bytes = null;
          _decoding = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // IMAGEM (suporta URL ou base64). Usa cache e decode em isolate para evitar repaints/piscar.
        SizedBox(
          height: 180,
          width: double.infinity,
          child: _bytes != null
              ? Image.memory(
                  _bytes!,
                  fit: BoxFit.cover,
                  cacheWidth: 1200,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stack) => Container(color: Colors.grey[300]),
                )
              : Container(color: Colors.grey[300]),
        ),

        // ESCURECER
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.45),
          ),
        ),

        // BOTÃO VOLTAR + CONVIDAR
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              if (widget.onInvite != null)
                IconButton(
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  onPressed: widget.onInvite,
                ),
            ],
          ),
        ),

        // TEXTO
        Positioned(
          left: 16,
          bottom: 30,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  const Icon(Icons.group, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.people}",
                    style: const TextStyle(color: Colors.white),
                  ),

                  const SizedBox(width: 12),

                  const Icon(Icons.emoji_events, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.points}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}