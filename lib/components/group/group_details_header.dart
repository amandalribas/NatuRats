import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

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
  final VoidCallback? onLeave;
  final VoidCallback? onViewMembers;

  /// Se não-nulo, exibe o ícone de denúncias (visível só para admins).
  final VoidCallback? onViewReports;

  /// Stream com a contagem de denúncias pendentes para o badge.
  /// Passa null se o usuário não for admin (ícone não será exibido).
  final Stream<int>? pendingReportsStream;

  const GroupDetailsHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.people,
    required this.points,
    this.onLeave,
    this.onViewMembers,
    this.onViewReports,
    this.pendingReportsStream,
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
    if (oldWidget.imageUrl != widget.imageUrl) _ensureImageDecoded();
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
      if (mounted) setState(() { _bytes = result; _decoding = false; });
    }).catchError((_) {
      if (mounted) setState(() { _bytes = null; _decoding = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Imagem de fundo ─────────────────────────────────────────────────
        SizedBox(
          height: 180,
          width: double.infinity,
          child: _bytes != null
              ? Image.memory(
                  _bytes!,
                  fit: BoxFit.cover,
                  cacheWidth: 1200,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[300]),
                )
              : Container(color: Colors.grey[300]),
        ),
        Container(
          height: 180,
          decoration:
              const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.45)),
        ),

        // ── Barra superior ──────────────────────────────────────────────────
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botão voltar
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),

              // Ícones do lado direito
              Row(
                children: [
                  // Ícone de denúncias (somente para admins)
                  if (widget.onViewReports != null)
                    StreamBuilder<int>(
                      stream: widget.pendingReportsStream ??
                          const Stream.empty(),
                      builder: (ctx, snap) {
                        final count = snap.data ?? 0;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.report_outlined,
                                  color: Colors.white),
                              tooltip: 'Denúncias',
                              onPressed: widget.onViewReports,
                            ),
                            if (count > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: IgnorePointer(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: AppColors.vermelho,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                        minWidth: 16, minHeight: 16),
                                    child: Text(
                                      count > 99 ? '99+' : '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                  if (widget.onViewMembers != null)
                    IconButton(
                      icon: const Icon(Icons.people, color: Colors.white),
                      onPressed: widget.onViewMembers,
                    ),
                  if (widget.onLeave != null)
                    IconButton(
                      icon: const Icon(Icons.exit_to_app,
                          color: Colors.white),
                      onPressed: widget.onLeave,
                    ),
                ],
              ),
            ],
          ),
        ),

        // ── Título e stats ──────────────────────────────────────────────────
        Positioned(
          left: 16,
          bottom: 30,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.group, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('${widget.people}',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  const Icon(Icons.emoji_events,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('${widget.points}',
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