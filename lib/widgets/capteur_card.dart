// widgets/capteur_card.dart
import 'package:flutter/material.dart';

class CapteurCard extends StatelessWidget {
  final String title;
  final String value;

  final IconData icon;
  final Color color;
  final double progress;

  const CapteurCard({
    super.key,
    required this.title,
    required this.value,

    required this.icon,
    this.color = Colors.blue,
    this.progress = 0.5,

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.2 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Dernière mise à jour: il y a 2 min",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 4),
                
                
              ],
            ),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                color: _getProgressColor(progress),
                minHeight: 6,
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Min: ${_getMinValue(title)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "Max: ${_getMaxValue(title)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _getMinValue(String title) {
    switch (title) {
      case "Température": return "15°C";
      case "Humidité": return "30%";
      case "Luminosité": return "200 lux";
      case "CO₂": return "300 ppm";
      default: return "0";
    }
  }

  String _getMaxValue(String title) {
    switch (title) {
      case "Température": return "35°C";
      case "Humidité": return "80%";
      case "Luminosité": return "2000 lux";
      case "CO₂": return "1000 ppm";
      default: return "100";
    }
  }
}