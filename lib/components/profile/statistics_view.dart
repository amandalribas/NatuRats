import 'package:flutter/material.dart';
import 'package:naturats/theme/app_colors.dart';

class StatisticsView extends StatelessWidget {
  final int co2;
  final int recycled;
  final int water;
  final int km;

  const StatisticsView({
    super.key,
    required this.co2,
    required this.recycled,
    required this.water,
    required this.km});

  @override
  Widget build(BuildContext context) {
      return SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        _buildImpactCard(),
        const SizedBox(height: 30),
      ],
    ),
  );
  }

  Widget _buildImpactCard() {

    final co2InKg = (co2 / 1000).toStringAsFixed(1);
    final List<Map<String, dynamic>> impactItems = [
      
      {'value': '$co2InKg kg', 'label': 'CO2 evitado', 'color': AppColors.statCo2},
      {'value': '$water L', 'label': 'Água economizada', 'color': AppColors.staAgua},
      {'value': '$recycled', 'label': 'Itens reciclados', 'color': AppColors.statReciclado},
      {'value': '$km km', 'label': 'Transporte sustentável', 'color': AppColors.statTransporte},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.bgCinza.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.preto.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seu impacto ambiental',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: AppColors.preto,
            ),
          ),
          const SizedBox(height: 20),
   
          Row(
            children: [
              Expanded(
                child: _buildImpactItem(
                  impactItems[0]['value'] as String, 
                  impactItems[0]['label'] as String, 
                  impactItems[0]['color'] as Color
                ),
              ),
              Expanded(
                child: _buildImpactItem(
                  impactItems[1]['value'] as String, 
                  impactItems[1]['label'] as String, 
                  impactItems[1]['color'] as Color
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildImpactItem(
                  impactItems[2]['value'] as String, 
                  impactItems[2]['label'] as String, 
                  impactItems[2]['color'] as Color
                ),
              ),
              Expanded(
                child: _buildImpactItem(
                  impactItems[3]['value'] as String, 
                  impactItems[3]['label'] as String, 
                  impactItems[3]['color'] as Color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textCinza, 
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}