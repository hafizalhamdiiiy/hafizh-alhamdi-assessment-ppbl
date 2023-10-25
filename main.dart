import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MaterialApp(
    home: PpblassessmentApp(),
  ));
}

class PpblassessmentApp extends StatefulWidget {
  @override
  _PpblassessmentAppState createState() => _PpblassessmentAppState();
}

class _PpblassessmentAppState extends State<PpblassessmentApp> {
  final String apiKey = 'https://api.polygon.io/v2/aggs/ticker/AAPL/range/1/month/2023-09-01/2023-10-01?adjusted=true&sort=asc&limit=120&apiKey=zmkYFiLgyMCpStbMXfOZlAVdoSQrdVfj';
  String stockSymbol = 'AAPL';
  List<double> data = [];
  bool evenNIM = false;

  @override
  void initState() {
    super.initState();
    determineChartStyle();
    fetchStockData();
  }

  void determineChartStyle() {

    final int angkatan = 2020;

    final String nim = '6701204091';

    if (angkatan == 2020) {

      evenNIM = nim.length % 2 == 0;
    } else if (angkatan == 2021) {
      // Warna merah muda
      evenNIM = nim.length % 2 == 0;
    }
  }

  Future<void> fetchStockData() async {
    final response = await http.get(Uri.parse('https://api.polygon.io/v2/aggs/ticker/AAPL/range/1/month/2023-09-01/2023-10-01?adjusted=true&sort=asc&limit=120&apiKey=zmkYFiLgyMCpStbMXfOZlAVdoSQrdVfj'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> results = jsonData['results'];

      final String kelas = '02';

      if (kelas == '01') {
        data = results.map((result) => result['o']).cast<double>().toList();
      } else if (kelas == '02') {
        data = results.map((result) => result['c']).cast<double>().toList();
      } else if (kelas == '03') {
        data = results.map((result) => result['h']).cast<double>().toList();
      } else if (kelas == '04' || kelas == '05') {
        data = results.map((result) => result['l']).cast<double>().toList();
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Kode Saham: $stockSymbol'),
            ElevatedButton(
              onPressed: () => fetchStockData(),
              child: Text('Refresh Data'),
            ),
            if (data.isNotEmpty)
              LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        final index = entry.key;
                        final value = entry.value;
                        return FlSpot(index.toDouble(), value);
                      }).toList(),
                      isCurved: evenNIM,
                      colors: [evenNIM ? Colors.pink : Colors.yellow],
                      isStrokeCapRound: !evenNIM,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: !evenNIM),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(showTitles: true),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
