import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/category_tag.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/theme/app_colors.dart';

class ActiveChallengeBox extends StatefulWidget {
  final Challenge challenge;

  final int currentProgress;
  final int goal;

  final VoidCallback onTap;
  final VoidCallback onRegister;
  final Future<void> Function() onFinish;

  const ActiveChallengeBox({
    super.key,
    required this.challenge,
    required this.currentProgress,
    required this.goal,
    required this.onTap,
    required this.onRegister,
    required this.onFinish,
  });

  @override
  State<ActiveChallengeBox> createState() => _ActiveChallengeBoxState();
}

class _ActiveChallengeBoxState extends State<ActiveChallengeBox> {
  bool _clicked = false;

  double get progress => widget.currentProgress / widget.goal;

  bool get canFinish => widget.currentProgress >= widget.goal - 1;

  String get progressText =>
      "${widget.currentProgress}/${widget.goal} concluído";

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),

      decoration: BoxDecoration(
        color: AppColors.branco,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(
          color: AppColors.bgCinza,
          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: widget.onTap,

          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 6, 16),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  height: 54,
                  width: 54,

                  decoration: BoxDecoration(
                    color: widget.challenge.type.color,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Icon(
                    widget.challenge.type.icon,
                    size: 28,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        widget.challenge.title,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        widget.challenge.description,

                        style: TextStyle(
                          fontSize: 12,
                          height: 1.25,
                          color: Colors.grey.shade700,
                        ),

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        progressText,

                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.challenge.type.color,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),

                              child: LinearProgressIndicator(
                                value: progress > 1 ? 1 : progress,

                                minHeight: 7,

                                backgroundColor: Colors.grey.shade200,

                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.challenge.type.color,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "${(progress * 100).toInt()}%",

                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          CategoryTag(category: widget.challenge.duration),

                          const SizedBox(width: 6),

                          CategoryTag(category: widget.challenge.type),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  width: 58,

                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_clicked) return;

                          _clicked = true;

                          try {
                            if (canFinish) {
                              await widget.onFinish(); 
                            } else {
                              widget.onRegister();
                            }
                          } finally {
                            _clicked = false;
                          }
                        },

                        child: Container(
                          height: 40,
                          width: 40,

                          decoration: BoxDecoration(
                            color: canFinish
                                ? Colors.green.shade100
                                : const Color(0xFFF1F7F1),

                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            canFinish ? Icons.check : Icons.add,

                            color: Colors.green.shade700,

                            size: 24,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        canFinish ? "Finalizar" : "Registrar",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}