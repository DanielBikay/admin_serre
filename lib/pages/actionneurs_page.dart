// Fichier : actionneurs_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/actionneur_card.dart';

class ActionneursPage extends StatefulWidget {
  const ActionneursPage({super.key});

  @override
  State<ActionneursPage> createState() => _ActionneursPageState();
}

class _ActionneursPageState extends State<ActionneursPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('serre/actionneurs');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // Pompes
          _buildActionneurStream('pompe_eau', "Pompe à eau", Icons.opacity, Colors.blue),
          _buildActionneurStream('pompe_secours', "Pompe de secours", Icons.emergency, Colors.red),
          
          // Ventilation
          _buildActionneurStream('ventilateur', "Ventilateur", Icons.wind_power, Colors.teal),
          
          // Température
          _buildActionneurStream('chauffage', "Chauffage", Icons.fireplace, Colors.orange),
          
          // Éclairage
          _buildActionneurStream('led_eclairage', "LED éclairage", Icons.lightbulb, Colors.yellow),
          
          // Trappe
          _buildActionneurStream('trappe', "Trappe", Icons.open_in_full, Colors.green),
        ],
      ),
    );
  }

  Widget _buildActionneurStream(String actionneurId, String title, IconData icon, Color color) {
    return StreamBuilder<DatabaseEvent>(
      stream: _databaseRef.child(actionneurId).child('actuelle').onValue,
      builder: (context, snapshot) {
        bool isActive = false;
        
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          isActive = data['statut'] == 'on';
        }

        return ActionneurCard(
          title: title,
          icon: icon,
          color: color,
          isActive: isActive,
          onToggle: (newState) => _toggleActionneur(actionneurId, newState),
        );
      },
    );
  }

  Future<void> _toggleActionneur(String actionneurId, bool newState) async {
    try {
      await _databaseRef.child(actionneurId).child('actuelle').update({
        'statut': newState ? 'on' : 'off',
        'timestamp': DateTime.now().toIso8601String(),
        if (newState) 'derniere_activation': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
}