import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final Map<String, Uint8List> _groupHeaderImageCache = {};

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
  final VoidCallback? onLeave;

  const GroupDetailsHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.people,
    required this.points,
    this.onInvite,
    this.onLeave,
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
      setState(() => _bytes = null);
      return;
    }

    if (_groupHeaderImageCache.containsKey(imageUrl)) {
      setState(() => _bytes = _groupHeaderImageCache[imageUrl]);
      return;
    }

    final isDataUri = imageUrl.startsWith('data:image');
    final isLikelyBase64 = isDataUri || imageUrl.length > 200;

    if (!isLikelyBase64) {
      setState(() => _bytes = null);
      return;
    }

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
        // IMAGEM
        SizedBox(
          height: 180,
          width: double.infinity,
          child: _bytes != null
              ? Image.memory(
            _bytes!,
            fit: BoxFit.cover,
            cacheWidth: 1200,
            filterQuality: FilterQuality.low,
            errorBuilder: (context, error, stack) =>
                Container(color: Colors.grey[300]),
          )
              : Container(color: Colors.grey[300]),
        ),

        // ESCURECER
        Container(
          height: 180,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.45),
          ),
        ),

        // BOTÕES
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Voltar
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              // Ações (convidar e menu)
              Row(
                children: [
                  if (widget.onInvite != null)
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      onPressed: widget.onInvite,
                    ),
                  if (widget.onLeave != null)
                    if (widget.onLeave != null)
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) => SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 5,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.exit_to_app, color: Colors.red),
                                      title: const Text('Sair do grupo',
                                          style: TextStyle(color: Colors.red)),
                                      onTap: () {
                                        Navigator.pop(ctx); 
                                        widget.onLeave!();  
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                ],
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
                  Text("${widget.people}",
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  const Icon(Icons.emoji_events, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text("${widget.points}",
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}