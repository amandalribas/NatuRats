import 'package:flutter/material.dart';
import 'package:naturats/controller/profile_controller.dart';
import 'medal_card.dart';

class MedalsView extends StatelessWidget {
  const MedalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController(context);
    final medals = controller.getMedals();

    return GridView.builder(
      padding: const EdgeInsets.all(4.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: medals.length,
      itemBuilder: (context, index) {
        final medal = medals[index];
        return MedalCard(
          medal: medal,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}