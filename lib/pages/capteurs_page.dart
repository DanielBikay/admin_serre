// Fichier : capteurs_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/capteur_card.dart';
import 'humidity_soil_page.dart'; // ou './soil_moisture_page.dart'
import 'temperature_page.dart';
import 'humidite_page.dart';
import 'luminosite_page.dart';
import 'co2_page.dart';

class CapteursPage extends StatefulWidget {
  const CapteursPage({super.key});

  @override
  State<CapteursPage> createState() => _CapteursPageState();
}

class _CapteursPageState extends State<CapteursPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('serre/capteurs');
  
  // Données des capteurs
  Map<String, dynamic> _capteursData = {
    'temperature': {'valeur': 0, 'unite': '°C', 'statut': 'normal', 'seuil_min': 0, 'seuil_max': 0},
    'humidite': {'valeur': 0, 'unite': '%', 'statut': 'normal', 'seuil_min': 0, 'seuil_max': 0},
    'luminosite': {'valeur': 0, 'unite': 'lux', 'statut': 'normal', 'seuil_min': 0, 'seuil_max': 0},
    'co2': {'valeur': 0, 'unite': 'ppm', 'statut': 'normal', 'seuil_min': 0, 'seuil_max': 0},
    'humidite_sol': {'valeur': 0, 'unite': '%', 'statut': 'normal', 'seuil_min': 0, 'seuil_max': 0},
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupFirebaseListeners();
  }

  void _setupFirebaseListeners() {
    // Écoute des données en temps réel pour chaque capteur
    _capteursData.forEach((capteurId, _) {
      _databaseRef.child('$capteurId/actuelle').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          setState(() {
            _capteursData[capteurId] = {
              'valeur': data['valeur'] ?? 0,
              'unite': data['unite'] ?? '',
              'statut': data['statut'] ?? 'normal',
              'seuil_min': data['seuil_min'] ?? 0,
              'seuil_max': data['seuil_max'] ?? 0,
            };
            _isLoading = false;
          });
        }
      });
    });
  }

  // Fonction pour naviguer vers la page dédiée du capteur
  void _navigateToSensorPage(BuildContext context, String sensorId) {
    switch (sensorId) {
      case 'temperature':
        Navigator.push(context, MaterialPageRoute(builder: (context) => TemperaturePage()));
        break;
      case 'humidite':
        Navigator.push(context, MaterialPageRoute(builder: (context) => HumiditePage()));
        break;
      case 'luminosite':
        Navigator.push(context, MaterialPageRoute(builder: (context) => LuminositePage()));
        break;
      case 'co2':
        Navigator.push(context, MaterialPageRoute(builder: (context) => CO2Page()));
        break;
      case 'humidite_sol':
        Navigator.push(context, MaterialPageRoute(builder: (context) => SoilMoisturePage()));
        break;
    }
  }

  // Fonction pour obtenir l'icône approprié pour chaque capteur
  IconData _getIconForSensor(String sensorId) {
    switch (sensorId) {
      case 'temperature':
        return Icons.thermostat;
      case 'humidite':
        return Icons.water_drop;
      case 'luminosite':
        return Icons.wb_sunny;
      case 'co2':
        return Icons.cloud;
      case 'humidite_sol':
        return Icons.grass;
      default:
        return Icons.error;
    }
  }

  // Fonction pour obtenir le titre en français
  String _getTitleForSensor(String sensorId) {
    switch (sensorId) {
      case 'temperature':
        return 'Température';
      case 'humidite':
        return 'Humidité';
      case 'luminosite':
        return 'Luminosité';
      case 'co2':
        return 'CO₂';
      case 'humidite_sol':
        return 'Humidité du sol';
      default:
        return sensorId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Capteurs")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _capteursData.entries.map((entry) {
                final sensorId = entry.key;
                final sensorData = entry.value;
                final progress = _calculateProgress(
                  sensorData['valeur'],
                  sensorData['seuil_min'],
                  sensorData['seuil_max'],
                );

                return GestureDetector(
                  onTap: () => _navigateToSensorPage(context, sensorId),
                  child: CapteurCard(
                    title: _getTitleForSensor(sensorId),
                    value: '${sensorData['valeur']}${sensorData['unite']}',
                    icon: _getIconForSensor(sensorId),
                    color: _getColorForSensor(sensorId),
                    progress: progress,
                  ),
                );
              }).toList(),
            ),
    );
  }

  double _calculateProgress(dynamic value, dynamic min, dynamic max) {
    final numValue = value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;
    final numMin = min is num ? min.toDouble() : double.tryParse(min.toString()) ?? 0;
    final numMax = max is num ? max.toDouble() : double.tryParse(max.toString()) ?? 1;

    if (numMax == numMin) return 0.5;
    return (numValue - numMin) / (numMax - numMin);
  }

  Color _getColorForSensor(String sensorId) {
    switch (sensorId) {
      case 'temperature':
        return Colors.red;
      case 'humidite':
        return Colors.blue;
      case 'luminosite':
        return Colors.yellow;
      case 'co2':
        return Colors.grey;
      case 'humidite_sol':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}