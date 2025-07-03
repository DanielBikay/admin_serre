// voice_command_service.dart

import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_database/firebase_database.dart';

class VoiceCommandService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final DatabaseReference _database = FirebaseDatabase.instance.ref('serre/actionneurs');

  Future<bool> initialize() async {
    bool available = await _speech.initialize();
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.5);
    return available;
  }

  Future<void> listen() async {
    if (await initialize()) {
      await _speech.listen(
        onResult: (result) => _handleCommand(result.recognizedWords),
        listenFor: const Duration(seconds: 20),
      );
    }
  }

  Future<void> _handleCommand(String command) async {
    command = command.toLowerCase();
    
    if (command.contains('allumer')) {
      if (command.contains('pompe') || command.contains('eau')) {
        await _updateActuator('pompe_eau', 'on');
        await _speak('La pompe à eau a été allumée');
      } else if (command.contains('ventilateur')) {
        await _updateActuator('ventilateur', 'on');
        await _speak('Le ventilateur a été allumé');
      } else if (command.contains('chauffage')) {
        await _updateActuator('chauffage', 'on');
        await _speak('Le chauffage a été allumé');
      } else if (command.contains('éclairage') || command.contains('lumières')) {
        await _updateActuator('led_eclairage', 'on');
        await _speak('L\'éclairage LED a été allumé');
      }
    } else if (command.contains('éteindre')) {
      if (command.contains('pompe') || command.contains('eau')) {
        await _updateActuator('pompe_eau', 'off');
        await _speak('La pompe à eau a été éteinte');
      } else if (command.contains('ventilateur')) {
        await _updateActuator('ventilateur', 'off');
        await _speak('Le ventilateur a été éteint');
      } else if (command.contains('chauffage')) {
        await _updateActuator('chauffage', 'off');
        await _speak('Le chauffage a été éteint');
      } else if (command.contains('éclairage') || command.contains('lumières')) {
        await _updateActuator('led_eclairage', 'off');
        await _speak('L\'éclairage LED a été éteint');
      }
    } else {
      await _speak('Je n\'ai pas compris la commande');
    }
  }

  Future<void> _updateActuator(String actuator, String status) async {
    await _database.child(actuator).child('actuelle').update({
      'statut': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _speech.stop();
    await _tts.stop();
  }
}