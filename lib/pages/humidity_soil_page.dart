// humidity_soil_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SoilMoisturePage extends StatefulWidget {
  @override
  _SoilMoisturePageState createState() => _SoilMoisturePageState();
}

class _SoilMoisturePageState extends State<SoilMoisturePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('serre/capteurs/humidite_sol');
  late SensorData _currentData;
  List<SensorData> _historyData = [];
  bool _isLoading = true;
  int _minThreshold = 35;
  int _maxThreshold = 75;

  @override
  void initState() {
    super.initState();
    _currentData = SensorData(
      date: DateTime.now(),
      value: 0,
      status: "normal",
      unit: "%",
    );
    _setupFirebaseListeners();
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
            unit: "%",
          );
          _minThreshold = (data['seuil_min'] ?? 35).toInt();
          _maxThreshold = (data['seuil_max'] ?? 75).toInt();
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
            unit: "%",
          ));
        });
        setState(() {
          _historyData = temp..sort((a, b) => a.date.compareTo(b.date));
        });
      }
    });
  }

  Color _getMoistureColor(double moisture) {
    if (moisture < _minThreshold) return Colors.red;
    if (moisture > _maxThreshold) return Colors.orange;
    return Colors.green;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "warning":
        return Colors.orange;
      case "danger":
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case "warning":
        return "Alerte";
      case "danger":
        return "Danger";
      default:
        return "Normal";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Humidité du Sol'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentValueCard(),
                  SizedBox(height: 20),
                  _buildThresholdInfo(),
                  SizedBox(height: 20),
                  Expanded(child: _buildHistorySection()),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentValueCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Humidité actuelle',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getMoistureColor(_currentData.value).withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _getMoistureColor(_currentData.value),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${_currentData.value}${_currentData.unit}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getMoistureColor(_currentData.value),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Statut: ${_translateStatus(_currentData.status)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _getStatusColor(_currentData.status),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_currentData.date),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThresholdInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seuils de référence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildThresholdIndicator('Minimum', _minThreshold, Colors.blue),
                _buildThresholdIndicator('Maximum', _maxThreshold, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdIndicator(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Expanded(
          child: _historyData.isEmpty
              ? Center(child: Text('Aucune donnée historique disponible'))
              : Column(
                  children: [
                    Expanded(flex: 2, child: _buildHistoryChart()),
                    SizedBox(height: 20),
                    Expanded(flex: 3, child: _buildHistoryList()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryChart() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, _) {
                  if (value.toInt() >= 0 && value.toInt() < _historyData.length) {
                    final date = _historyData[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('HH:mm').format(date),
                        style: TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: _historyData
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(
                        entry.key.toDouble(),
                        entry.value.value,
                      ))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.builder(
        itemCount: _historyData.length,
        itemBuilder: (context, index) {
          final data = _historyData.reversed.toList()[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: Icon(Icons.calendar_today, size: 20),
              title: Text(
                '${data.value}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getMoistureColor(data.value),
                ),
              ),
              subtitle: Text(
                DateFormat('dd/MM/yyyy HH:mm').format(data.date),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(data.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _translateStatus(data.status),
                  style: TextStyle(
                    color: _getStatusColor(data.status),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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