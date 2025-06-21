// widgets/alerte_card.dart
import 'package:flutter/material.dart';

class AlerteCard extends StatefulWidget {
  final String title;
  final String message;
  final String time;
  final AlertType type;
  final bool isRead;

  const AlerteCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.type = AlertType.warning,
    this.isRead = false,
  });


  @override
  AlerteCardState createState() => AlerteCardState();
}

class AlerteCardState extends State<AlerteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    final IconData icon;

    switch (widget.type) {
      case AlertType.error:
        backgroundColor = Colors.red.withAlpha((0.1 * 255).toInt());
        textColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case AlertType.warning:
        backgroundColor = Colors.orange.withAlpha((0.1 * 255).toInt());
        textColor = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;
      case AlertType.info:
        backgroundColor = Colors.blue.withAlpha((0.1 * 255).toInt());
        textColor = Colors.blue;
        icon = Icons.info_outline;
        break;
      case AlertType.success:
        backgroundColor = Colors.green.withAlpha((0.1 * 255).toInt());
        textColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: textColor.withAlpha((0.2 * 255).toInt()),
            width: 1,
          ),
        ),
        color: backgroundColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Marquer comme lu
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: textColor.withAlpha((0.2 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: textColor, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          if (!widget.isRead) ...[
                            SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: textColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.time,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

enum AlertType { error, warning, info, success }
