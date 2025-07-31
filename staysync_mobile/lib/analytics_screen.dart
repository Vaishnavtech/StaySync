import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Service Analytics'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<Map<String, int>>(
              future: _serviceCounts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available to display.', style: TextStyle(color: Colors.white70)));
                }

                final serviceData = snapshot.data!;
                final chartData = serviceData.entries.map((entry) {
                  return BarChartGroupData(
                    x: serviceData.keys.toList().indexOf(entry.key),
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: Colors.blueAccent,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
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
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: BlurryContainer(
                          blur: 8,
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.all(16),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: serviceData.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
                              barGroups: chartData,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  ),
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
                                              color: Colors.white,
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
                              gridData: FlGridData(
                                show: true,
                                getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
                                getDrawingVerticalLine: (value) => const FlLine(color: Colors.white12, strokeWidth: 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
