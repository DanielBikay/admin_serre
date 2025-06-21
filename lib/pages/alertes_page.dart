// Fichier : alertes_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/alerte_card.dart';

class AlertesPage extends StatefulWidget {
  const AlertesPage({super.key});

  @override
  State<AlertesPage> createState() => _AlertesPageState();
}

class _AlertesPageState extends State<AlertesPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('serre/alertes');
  List<Map<String, dynamic>> _alertes = [];

  @override
  void initState() {
    super.initState();
    _setupDatabaseListener();
  }

  void _setupDatabaseListener() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final List<Map<String, dynamic>> alertesList = [];
        
        data.forEach((key, value) {
          alertesList.add({
            'id': key,
            ...value,
          });
        });

        // Trier par timestamp (du plus récent au plus ancien)
        alertesList.sort((a, b) {
          final timeA = DateTime.parse(a['timestamp']);
          final timeB = DateTime.parse(b['timestamp']);
          return timeB.compareTo(timeA);
        });

        if (mounted) {
          setState(() {
            _alertes = alertesList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _alertes = [];
          });
        }
      }
    });
  }

  AlertType _getAlertTypeFromString(String niveau) {
    switch (niveau) {
      case 'error':
      case 'danger':
        return AlertType.error;
      case 'warning':
        return AlertType.warning;
      case 'info':
        return AlertType.info;
      case 'success':
        return AlertType.success;
      default:
        return AlertType.warning;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alertes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Forcer un rafraîchissement
              _databaseRef.get().then((snapshot) {
                final data = snapshot.value as Map<dynamic, dynamic>?;
                if (data != null) {
                  final List<Map<String, dynamic>> alertesList = [];
                  data.forEach((key, value) {
                    alertesList.add({
                      'id': key,
                      ...value,
                    });
                  });
                  setState(() {
                    _alertes = alertesList;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: _alertes.isEmpty
          ? const Center(
              child: Text(
                "Aucune alerte pour le moment",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _alertes.length,
              itemBuilder: (context, index) {
                final alerte = _alertes[index];
                return AlerteCard(
                  title: alerte['message'] ?? 'Alerte',
                  message: 'Valeur: ${alerte['valeur']} ${alerte['unite'] ?? ''}',
                  time: _formatTimestamp(alerte['timestamp']),
                  type: _getAlertTypeFromString(alerte['niveau'] ?? 'warning'),
                  isRead: alerte['lue'] ?? false,
                );
              },
            ),
    );
  }
}