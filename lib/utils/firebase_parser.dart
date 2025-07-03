//utils/firebase_parser.dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:fl_chart/fl_chart.dart';  // For FlSpot

class FirebaseParser {
  static Map<String, dynamic>? parseMap(Map<dynamic, dynamic>? data) {
    if (data == null) return null;
    
    return data.map((key, value) {
      // Convert all keys to String
      final stringKey = key.toString();
      
      // Recursive processing of nested Maps
      dynamic parsedValue = value;
      if (value is Map) {
        parsedValue = parseMap(value as Map<dynamic, dynamic>);
      } 
      // Add other conversions here if needed (List, etc.)
      
      return MapEntry(stringKey, parsedValue);
    });
  }

  static List<FlSpot> parseTemperatureHistory(Map<String, dynamic>? sensorData) {
    final history = sensorData?['temperature']?['historique'];
    if (history == null || !(history is Map)) return [];

    try {
      final entries = (history as Map).entries.toList()
        ..sort((a, b) {
          final timeA = DateTime.parse((a.value as Map)['timestamp'].toString());
          final timeB = DateTime.parse((b.value as Map)['timestamp'].toString());
          return timeB.compareTo(timeA); // Descending sort
        });

      // Take last 7 entries (after sorting descending) and convert to chronological order
      final lastSevenEntries = entries.take(7).toList().reversed.toList();

      return lastSevenEntries
          .asMap()
          .entries
          .map((entry) {
            final value = (entry.value.value as Map)['valeur'];
            return FlSpot(
              entry.key.toDouble(), // X-axis position (0-6)
              (value is num ? value : double.tryParse(value.toString()) ?? 0).toDouble(),
            );
          })
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing temperature history: $e');
      }
      return [];
    }
  }
}