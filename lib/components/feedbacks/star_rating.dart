import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 40,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        IconData icon;
        if (rating >= starValue) {
          icon = Icons.star;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        final star = Icon(icon, color: AppColors.buttomVerde, size: size);

        if (!interactive) return star;

        return GestureDetector(
          onTapDown: (details) {
            final halfWidth = size / 2;
            final newRating = details.localPosition.dx < halfWidth
                ? starValue - 0.5
                : starValue;
            onRatingChanged?.call(newRating);
          },
          child: star,
        );
      }),
    );
  }
}