import 'package:flutter/material.dart';
import 'package:naturats/components/challenge/category_tag.dart';
import 'package:naturats/controller/profile_controller.dart';
import 'package:naturats/model/challenge.dart';
import 'package:naturats/view/finish_challenge_dialog.dart';

class ActiveChallengeBox extends StatelessWidget {
  final Challenge challenge;

  final int currentProgress;
  final int goal;

  final VoidCallback onTap;
  final VoidCallback onRegister;
  final VoidCallback onFinish;

  final VoidCallback onCompleteChallenge;
  const ActiveChallengeBox({
    super.key,
    required this.challenge,
    required this.currentProgress,
    required this.goal,
    required this.onTap,
    required this.onRegister,
    required this.onFinish,
    required this.onCompleteChallenge,  
    });

  double get progress => currentProgress / goal;

  bool get isFinished => currentProgress >= goal;

  String get progressText =>
      "$currentProgress/$goal concluído";


  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

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
          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 6, 16),

            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Container(
                  height: 54,
                  width: 54,

                  decoration: BoxDecoration(
                    color: challenge.type.color,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: Icon(
                    challenge.type.icon,
                    size: 28,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        challenge.title,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        challenge.description,

                        style: TextStyle(
                          fontSize: 12,
                          height: 1.25,
                          color: Colors.grey.shade700,
                        ),

                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        progressText,

                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                          color: challenge.type.color,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                      10),

                              child:
                                  LinearProgressIndicator(
                                value: progress > 1
                                    ? 1
                                    : progress,

                                minHeight: 7,

                                backgroundColor:
                                    Colors.grey.shade200,

                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  challenge.type.color,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "${(progress * 100).toInt()}%",

                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CategoryTag(
                            category: challenge.duration,
                          ),

                          const SizedBox(width: 6),

                          CategoryTag(
                            category: challenge.type,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // BOTAO MENOR

                SizedBox(
                  width: 58,

                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (isFinished) {
                            onFinish();

                            onCompleteChallenge();


                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) =>
                                  FinishChallengeDialog(
                                    challenge: challenge,
                                    points: challenge.duration.points,
                                  ),
                            );
                          } else {
                            onRegister();
                          }
                        },

                        child: Container(
                          height: 40,
                          width: 40,

                          decoration: BoxDecoration(
                            color: isFinished
                                ? Colors.green.shade100
                                : const Color(
                                    0xFFF1F7F1),

                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            isFinished
                                ? Icons.check
                                : Icons.add,

                            color:
                                Colors.green.shade700,

                            size: 24,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        isFinished
                            ? "Finalizar"
                            : "Registrar",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              Colors.green.shade700,
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


