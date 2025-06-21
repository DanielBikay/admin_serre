//utils/firebase_parser.dart

class FirebaseParser {
  static Map<String, dynamic>? parseMap(Map<dynamic, dynamic>? data) {
    if (data == null) return null;
    
    return data.map((key, value) {
      // Convertit toutes les clés en String
      final stringKey = key.toString();
      
      // Traitement récursif des Maps imbriquées
      dynamic parsedValue = value;
      if (value is Map) {
        parsedValue = parseMap(value as Map<dynamic, dynamic>);
      } 
      // Ajoutez ici d'autres conversions si nécessaire (List, etc.)
      
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
          return timeB.compareTo(timeA); // Tri décroissant
        });

      return entries
          .take(7)
          .toList()
          .reversed // Pour ordre chronologique
          .asMap()
          .entries
          .map((entry) {
            final value = (entry.value.value as Map)['valeur'];
            return FlSpot(
              entry.key.toDouble(),
              (value is num ? value : double.tryParse(value.toString()) ?? 0).toDouble(),
            );
          })
          .toList();
    } catch (e) {
      debugPrint('Error parsing history: $e');
      return [];
    }
  }
}