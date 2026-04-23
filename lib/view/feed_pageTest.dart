import 'package:flutter/material.dart';
import 'package:naturats/shared/components/post_card.dart';
import 'package:naturats/theme/app_colors.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: SizedBox(
                width: 360,

                child: Column(
                  children: [
                    PostCard(
                      userName: 'Isabella',
                      message:
                          'Plantei uma árvore hoje no parque da cidade aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa🌱',
                    ),

                    const SizedBox(height: 16),

                    PostCard(
                      userName: 'Marina',
                      message:
                          'Comecei a separar lixo reciclável em casa ♻️',
                      imageUrl:   'https://super.abril.com.br/wp-content/uploads/2016/09/super_imgarvore_genia.jpg?quality=70&strip=info&w=624&h=417&crop=1',
                    ),

                    const SizedBox(height: 16),

                    PostCard(
                      userName: 'Ana',
                      message:
                          'Troquei sacolas plásticas por ecobags 🛍️',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}