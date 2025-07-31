import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'main.dart'; // To access the ServiceRequest model

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<Map<String, int>> _serviceCounts;

  @override
  void initState() {
    super.initState();
    _serviceCounts = _fetchServiceCounts();
  }

  Future<Map<String, int>> _fetchServiceCounts() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('staysync').select('servicetype');

    final Map<String, int> counts = {};
    for (final item in response) {
      final serviceType = item['servicetype'] as String;
      counts[serviceType] = (counts[serviceType] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Analytics'),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _serviceCounts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available to display.'));
          }

          final serviceData = snapshot.data!;
          final chartData = serviceData.entries.map((entry) {
            return BarChartGroupData(
              x: serviceData.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.indigo,
                  width: 16,
                ),
              ],
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Most Popular Services',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: serviceData.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
                      barGroups: chartData,
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < serviceData.keys.length) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Text(
                                    serviceData.keys.elementAt(index),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 38,
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: true),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
