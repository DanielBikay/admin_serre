// pages/seuils_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SeuilsPage extends StatefulWidget {
  const SeuilsPage({super.key});

  @override
  State<SeuilsPage> createState() => _SeuilsPageState();
}

class _SeuilsPageState extends State<SeuilsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('serre/capteurs');
  final Map<String, Map<String, double>> _seuils = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeuils();
  }

  Future<void> _loadSeuils() async {
    try {
      final snapshot = await _databaseRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _seuils.clear();
          data.forEach((capteur, details) {
            if (details is Map && details['actuelle'] is Map) {
              final actuelle = details['actuelle'] as Map;
              _seuils[capteur.toString()] = {
                'min': actuelle['seuil_min']?.toDouble() ?? 0,
                'max': actuelle['seuil_max']?.toDouble() ?? 0,
              };
            }
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSeuil(String capteur, String type, double value) async {
    try {
      await _databaseRef
          .child('$capteur/actuelle/seuil_$type')
          .set(value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seuil mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de mise à jour: $e')),
      );
    }
  }

  String _getCapteurName(String key) {
    switch (key) {
      case 'temperature': return 'Température';
      case 'humidite': return 'Humidité';
      case 'luminosite': return 'Luminosité';
      case 'co2': return 'CO₂';
      case 'humidite_sol': return 'Humidité sol';
      default: return key;
    }
  }

  String _getUnite(String key) {
    switch (key) {
      case 'temperature': return '°C';
      case 'humidite': return '%';
      case 'luminosite': return 'lux';
      case 'co2': return 'ppm';
      case 'humidite_sol': return '%';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Seuils'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSeuils,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _seuils.entries.map((entry) {
                final capteur = entry.key;
                final seuils = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCapteurName(capteur),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _buildSeuilSlider(
                          label: 'Seuil minimum',
                          value: seuils['min']!,
                          min: 0,
                          max: seuils['max']! - 1,
                          unite: _getUnite(capteur),
                          onChanged: (value) => _updateSeuil(capteur, 'min', value),
                        ),
                        const SizedBox(height: 16),
                        _buildSeuilSlider(
                          label: 'Seuil maximum',
                          value: seuils['max']!,
                          min: seuils['min']! + 1,
                          max: _getMaxRange(capteur),
                          unite: _getUnite(capteur),
                          onChanged: (value) => _updateSeuil(capteur, 'max', value),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  double _getMaxRange(String capteur) {
    switch (capteur) {
      case 'temperature': return 50;
      case 'humidite': return 100;
      case 'luminosite': return 3000;
      case 'co2': return 2000;
      case 'humidite_sol': return 100;
      default: return 100;
    }
  }

  Widget _buildSeuilSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unite,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}$unite'),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(1),
          onChanged: (newValue) {
            setState(() {
              if (label.contains('minimum')) {
                _seuils.forEach((key, seuil) {
                  if (seuil['min'] == value) {
                    seuil['min'] = newValue;
                  }
                });
              } else {
                _seuils.forEach((key, seuil) {
                  if (seuil['max'] == value) {
                    seuil['max'] = newValue;
                  }
                });
              }
            });
            onChanged(newValue);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.toStringAsFixed(1)}$unite'),
            Text('${max.toStringAsFixed(1)}$unite'),
          ],
        ),
      ],
    );
  }
}