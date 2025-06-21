import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class LuminositePage extends StatefulWidget {
  @override
  _LuminositePageState createState() => _LuminositePageState();
}

class _LuminositePageState extends State<LuminositePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('serre/capteurs/luminosite');
  late SensorData _currentData;
  List<SensorData> _historyData = [];
  bool _isLoading = true;
  double _minThreshold = 200;
  double _maxThreshold = 2000;
  double _warningThreshold = 1800;

  @override
  void initState() {
    super.initState();
    _currentData = SensorData(
      date: DateTime.now(),
      value: 0,
      status: "normal",
      unit: "lux",
    );
    _setupFirebaseListeners();
    _loadThresholds();
  }

  void _setupFirebaseListeners() {
    // Écoute temps réel
    _dbRef.child('actuelle').onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          _currentData = SensorData(
            date: DateTime.parse(data['timestamp']),
            value: (data['valeur'] ?? 0).toDouble(),
            status: data['statut'] ?? "normal",
            unit: data['unite'] ?? "lux",
          );
          _isLoading = false;
        });
      }
    });

    // Écoute historique
    _dbRef.child('historique').onValue.listen((event) {
      final Map? history = event.snapshot.value as Map?;
      if (history != null) {
        List<SensorData> temp = [];
        history.forEach((key, value) {
          temp.add(SensorData(
            date: DateTime.parse(value['timestamp']),
            value: (value['valeur'] ?? 0).toDouble(),
            status: value['statut'] ?? "normal",
            unit: "lux",
          ));
        });
        setState(() {
          _historyData = temp..sort((a, b) => a.date.compareTo(b.date));
        });
      }
    });
  }

  Future<void> _loadThresholds() async {
    try {
      final thresholdsRef = FirebaseDatabase.instance.ref('serre/parametres/seuils_alertes/luminosite');
      final snapshot = await thresholdsRef.get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _warningThreshold = (data['warning'] ?? 1800).toDouble();
        });
      }

      final actuelleSnapshot = await _dbRef.child('actuelle').get();
      if (actuelleSnapshot.exists) {
        final actuelleData = actuelleSnapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _minThreshold = (actuelleData['seuil_min'] ?? 200).toDouble();
          _maxThreshold = (actuelleData['seuil_max'] ?? 2000).toDouble();
        });
      }
    } catch (e) {
      print('Erreur de chargement des seuils: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Luminosité'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadThresholds();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCurrentValueCard(),
          SizedBox(height: 20),
          _buildThresholdInfo(),
          SizedBox(height: 20),
          _buildHistoryChart(),
          SizedBox(height: 20),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildCurrentValueCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Luminosité Actuelle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '${_currentData.value.toStringAsFixed(0)} ${_currentData.unit}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getValueColor(_currentData.value),
              ),
            ),
            SizedBox(height: 10),
            Chip(
              label: Text(
                'Statut: ${_translateStatus(_currentData.status)}',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _getStatusColor(_currentData.status),
            ),
            SizedBox(height: 10),
            Text(
              'Dernière mise à jour: ${DateFormat('dd/MM/yyyy HH:mm').format(_currentData.date)}',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Seuils de luminosité', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildThresholdChip('Minimum', _minThreshold, Colors.blue),
                _buildThresholdChip('Maximum', _maxThreshold, Colors.red),
                _buildThresholdChip('Alerte', _warningThreshold, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdChip(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12)),
        Chip(
          label: Text('${value.toStringAsFixed(0)} lux'),
          backgroundColor: color.withOpacity(0.2),
          labelStyle: TextStyle(color: color),
        ),
      ],
    );
  }

  Widget _buildHistoryChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Historique (24h)', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _historyData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(), 
                                e.value.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.amber,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minY: 0,
                  maxY: 2500,
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final data = _historyData[spot.x.toInt()];
                          return LineTooltipItem(
                            '${data.value.toStringAsFixed(0)} lux\n${DateFormat('HH:mm').format(data.date)}',
                            TextStyle(color: Colors.black),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Dernières mesures', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _historyData.length,
              itemBuilder: (context, index) {
                final data = _historyData.reversed.toList()[index];
                return ListTile(
                  leading: Icon(Icons.wb_sunny, color: _getValueColor(data.value)),
                  title: Text('${data.value.toStringAsFixed(0)} lux'),
                  subtitle: Text(DateFormat('dd/MM HH:mm').format(data.date)),
                  trailing: Chip(
                    label: Text(_translateStatus(data.status)),
                    backgroundColor: _getStatusColor(data.status).withOpacity(0.2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getValueColor(double value) {
    if (value >= _maxThreshold) return Colors.red;
    if (value >= _warningThreshold) return Colors.orange;
    if (value <= _minThreshold) return Colors.blue;
    return Colors.green;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "warning": return Colors.orange;
      case "danger": return Colors.red;
      default: return Colors.green;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case "warning": return "Alerte";
      case "danger": return "Danger";
      default: return "Normal";
    }
  }
}

class SensorData {
  final DateTime date;
  final double value;
  final String status;
  final String unit;

  SensorData({
    required this.date,
    required this.value,
    required this.status,
    required this.unit,
  });
}