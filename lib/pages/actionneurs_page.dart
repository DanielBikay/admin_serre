// Fichier : actionneurs_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/actionneur_card.dart';

class ActionneursPage extends StatefulWidget {
  const ActionneursPage({super.key});

  @override
  State<ActionneursPage> createState() => _ActionneursPageState();
}

class _ActionneursPageState extends State<ActionneursPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('serre/actionneurs');
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      final available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) => _handleVoiceCommand(result.recognizedWords),
          listenFor: const Duration(seconds: 5),
        );
        await _tts.speak("Dites votre commande");
      }
    }
  }

  Future<void> _handleVoiceCommand(String command) async {
    command = command.toLowerCase();
    String? actionneurId;
    bool? newState;

    if (command.contains('allumer')) {
      newState = true;
      if (command.contains('pompe') && command.contains('eau')) {
        actionneurId = 'pompe_eau';
      } else if (command.contains('pompe') && command.contains('secours')) {
        actionneurId = 'pompe_secours';
      } else if (command.contains('ventilateur')) {
        actionneurId = 'ventilateur';
      } else if (command.contains('chauffage')) {
        actionneurId = 'chauffage';
      } else if (command.contains('éclairage') || command.contains('lumières')) {
        actionneurId = 'led_eclairage';
      } else if (command.contains('trappe')) {
        actionneurId = 'trappe';
      }
    } else if (command.contains('éteindre')) {
      newState = false;
      if (command.contains('pompe') && command.contains('eau')) {
        actionneurId = 'pompe_eau';
      } else if (command.contains('pompe') && command.contains('secours')) {
        actionneurId = 'pompe_secours';
      } else if (command.contains('ventilateur')) {
        actionneurId = 'ventilateur';
      } else if (command.contains('chauffage')) {
        actionneurId = 'chauffage';
      } else if (command.contains('éclairage') || command.contains('lumières')) {
        actionneurId = 'led_eclairage';
      } else if (command.contains('trappe')) {
        actionneurId = 'trappe';
      }
    }

    if (actionneurId != null && newState != null) {
      await _toggleActionneur(actionneurId, newState);
      final actionneurName = _getActionneurName(actionneurId);
      await _tts.speak(newState ? "$actionneurName allumé" : "$actionneurName éteint");
    }
  }

  String _getActionneurName(String id) {
    switch (id) {
      case 'pompe_eau': return 'La pompe à eau';
      case 'pompe_secours': return 'La pompe de secours';
      case 'ventilateur': return 'Le ventilateur';
      case 'chauffage': return 'Le chauffage';
      case 'led_eclairage': return 'L\'éclairage LED';
      case 'trappe': return 'La trappe';
      default: return 'L\'actionneur';
    }
  }

  Widget _buildModeToggle() {
    final modeRef = _databaseRef.child('mode');

    return StreamBuilder<DatabaseEvent>(
      stream: modeRef.onValue,
      builder: (context, snapshot) {
        bool isAuto = false;

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final value = snapshot.data!.snapshot.value;
          isAuto = value == true;
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Mode manuel", style: TextStyle(fontSize: 16)),
            Switch(
              value: isAuto,
              onChanged: (value) async {
                await modeRef.set(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mode ${value ? "automatique" : "manuel"} activé')),
                );
                await _tts.speak(value ? "Mode manuel activé" : "Mode automatique activé");
              },
              activeColor: Colors.green,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildModeToggle(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildActionneurStream('pompe_eau', "Pompe à eau", Icons.opacity, Colors.blue),
                    _buildActionneurStream('pompe_secours', "Pompe de secours", Icons.emergency, Colors.red),
                    _buildActionneurStream('ventilateur', "Ventilateur", Icons.wind_power, Colors.teal),
                    _buildActionneurStream('chauffage', "Chauffage", Icons.fireplace, Colors.orange),
                    _buildActionneurStream('led_eclairage', "LED éclairage", Icons.lightbulb, Colors.yellow),
                    _buildActionneurStream('trappe', "Trappe", Icons.open_in_full, Colors.green),
                  ].map((widget) {
                    return SizedBox(
                      width: constraints.maxWidth < 600 ? constraints.maxWidth * 0.9 : 280,
                      child: widget,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleListening,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        backgroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
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
          isActive = data['statut'] == true;
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
        'statut': newState,
        'timestamp': DateTime.now().toIso8601String(),
        if (newState) 'derniere_activation': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
      await _tts.speak("Erreur lors de la commande");
    }
  }
}
