//acceuil_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'dart:math';
//import 'package:flutter/foundation.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('serre/capteurs');
  Map<String, dynamic> _sensorData = {};

  @override
  void initState() {
    super.initState();
    _setupDatabaseListener();
  }

  void _setupDatabaseListener() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          _sensorData = _parseFirebaseData(data);
        });
      }
    }, onError: (error) {
      debugPrint('Firebase error: $error');
    });
  }

  Map<String, dynamic> _parseFirebaseData(Map<dynamic, dynamic> data) {
    try {
      return data.map<String, dynamic>((key, value) {
        final stringKey = key.toString();
        dynamic parsedValue = value;
        
        if (value is Map) {
          parsedValue = _parseFirebaseData(value);
        }
        
        return MapEntry(stringKey, parsedValue);
      });
    } catch (e) {
      debugPrint('Error parsing Firebase data: $e');
      return {};
    }
  }

  double _getSensorValue(String sensorName) {
    try {
      final value = _sensorData[sensorName]?['actuelle']?['valeur'];
      return value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;
    } catch (e) {
      debugPrint('Error reading $sensorName: $e');
      return 0;
    }
  }

  String _getSensorUnit(String sensorName) {
    return _sensorData[sensorName]?['actuelle']?['unite']?.toString() ?? '';
  }

  String _getSensorStatus(String sensorName) {
    return _sensorData[sensorName]?['actuelle']?['statut']?.toString() ?? 'normal';
  }

  List<FlSpot> _getHistoricalTemperatureSpots() {
    try {
      final history = _sensorData['temperature']?['historique'];
      if (history == null || !(history is Map)) return [];

      final entries = (history as Map).entries.toList()
        ..sort((a, b) {
          final timeA = DateTime.parse((a.value as Map)['timestamp'].toString());
          final timeB = DateTime.parse((b.value as Map)['timestamp'].toString());
          return timeB.compareTo(timeA);
        });

      return entries
          .take(7)
          .toList()
          .reversed
          .toList()
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
      debugPrint('Error parsing temperature history: $e');
      return [];
    }
  }

  double _getMinYValue() {
    final spots = _getHistoricalTemperatureSpots();
    if (spots.isEmpty) return 0;
    return spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) - 2;
  }

  double _getMaxYValue() {
    final spots = _getHistoricalTemperatureSpots();
    if (spots.isEmpty) return 30;
    return spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 2;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: isSmallScreen ? 150 : 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco,
                        size: isSmallScreen ? 40 : 50,
                        color: Colors.white,
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 16),
                      Text(
                        "Serre Intelligente",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Statistiques en temps réel",
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 16, 
              vertical: isSmallScreen ? 8 : 0
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: isSmallScreen ? 8 : 16,
                crossAxisSpacing: isSmallScreen ? 8 : 16,
                childAspectRatio: isSmallScreen ? 1.1 : 1.3,
                mainAxisExtent: isSmallScreen ? 140 : 160,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildStatCard(context, index, isSmallScreen),
                childCount: 4,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
            sliver: SliverToBoxAdapter(
              child: Text(
                "Historique des températures",
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 8 : 16, 
              vertical: isSmallScreen ? 8 : 0
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: isSmallScreen ? 180 : 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: _getHistoricalTemperatureSpots().isEmpty
                    ? Center(child: Text("Chargement des données..."))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 6,
                          minY: _getMinYValue(),
                          maxY: _getMaxYValue(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getHistoricalTemperatureSpots(),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 4,
                              belowBarData: BarAreaData(
                                show: true,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, int index, bool isSmallScreen) {
    if (_sensorData.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final List<Map<String, dynamic>> stats = [
      {
        "title": "Température", 
        "value": "${_getSensorValue('temperature').toStringAsFixed(1)}${_getSensorUnit('temperature')}", 
        "icon": Icons.thermostat, 
        "color": Colors.redAccent,
        "status": _getSensorStatus('temperature')
      },
      {
        "title": "Humidité de l'air", 
        "value": "${_getSensorValue('humidite').toStringAsFixed(0)}${_getSensorUnit('humidite')}", 
        "icon": Icons.water_drop, 
        "color": Colors.blue,
        "status": _getSensorStatus('humidite')
      },
      {
        "title": "Luminosité", 
        "value": "${_getSensorValue('luminosite').toStringAsFixed(0)} ${_getSensorUnit('luminosite')}", 
        "icon": Icons.wb_sunny, 
        "color": Colors.amber,
        "status": _getSensorStatus('luminosite')
      },
      {
        "title": "Humidité du sol", 
        "value": "${_getSensorValue('humidite_sol').toStringAsFixed(0)}${_getSensorUnit('humidite_sol')}", 
        "icon": Icons.grass, 
        "color": Colors.green,
        "status": _getSensorStatus('humidite_sol')
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: stats[index]["color"].withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stats[index]["icon"],
                    color: stats[index]["color"],
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: isSmallScreen ? 2 : 4
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(stats[index]["status"]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(stats[index]["status"]),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 16),
            Text(
              stats[index]["title"],
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              stats[index]["value"],
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'danger':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'danger':
        return 'Danger';
      case 'warning':
        return 'Attention';
      default:
        return 'Normal';
    }
  }
}