import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Customer_screen/1.Launch/launch_welcome_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LaunchWelcomeScreen()),
          (route) => false,
    );
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - 5 + i);
      return m;
    });

    final ordersSnap = await FirebaseFirestore.instance.collection('ORDERS').get();
    final customersSnap = await FirebaseFirestore.instance.collection('CUSTOMERS').get();

    List<double> ordersPerMonth = List.filled(6, 0);
    List<double> cancelledPerMonth = List.filled(6, 0);
    List<double> revenuePerMonth = List.filled(6, 0);

    for (var doc in ordersSnap.docs) {
      final data = doc.data();
      final date = (data['Order_Date'] as Timestamp?)?.toDate();
      if (date == null) continue;

      for (int i = 0; i < 6; i++) {
        if (date.year == months[i].year && date.month == months[i].month) {
          ordersPerMonth[i]++;
          revenuePerMonth[i] += (data['Total_Price'] ?? 0).toDouble();
          if (data['Status'] == 'Cancelled' || data['Status'] == 'Canceled') {
            cancelledPerMonth[i]++;
          }
        }
      }
    }

    List<double> usersData = List.generate(6, (i) => customersSnap.docs.length.toDouble());

    return {
      'months': months.map((m) => _monthName(m.month)).toList(),
      'orders': ordersPerMonth,
      'cancelled': cancelledPerMonth,
      'revenue': revenuePerMonth,
      'users': usersData,
    };
  }

  String _monthName(int month) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Admin Dashboard",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: FutureBuilder(
                    future: _loadStats(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                      }
                      final stats = snapshot.data as Map<String, dynamic>;
                      final months = List<String>.from(stats['months']);

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildChartCard(
                              title: "Users Overview",
                              icon: Icons.people,
                              chart: _buildLineChart(
                                months: months,
                                values: List<double>.from(stats['users']),
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildChartCard(
                              title: "Orders",
                              icon: Icons.shopping_cart,
                              chart: _buildLineChart(
                                months: months,
                                values: List<double>.from(stats['orders']),
                                color: Colors.green,
                                extraValues: List<double>.from(stats['cancelled']),
                                extraColor: Colors.red,
                                mainLabel: "Completed",
                                extraLabel: "Cancelled",
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildChartCard(
                              title: "Revenue (JD)",
                              icon: Icons.attach_money,
                              chart: _buildLineChart(
                                months: months,
                                values: List<double>.from(stats['revenue']),
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 40,
            right: 15,
            child: IconButton(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout, color: Colors.red, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Widget chart,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5CB58),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.brown, size: 26),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart({
    required List<String> months,
    required List<double> values,
    required Color color,
    List<double>? extraValues,
    Color? extraColor,
    String? mainLabel,
    String? extraLabel,
  }) {
    final maxVal = [...values, ...(extraValues ?? [0.0])].reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal == 0 ? 10.0 : maxVal;
    final interval = (safeMax / 4).ceilToDouble();

    final List<LineChartBarData> lines = [
      LineChartBarData(
        spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
        isCurved: true,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color,
          ),
        ),
        belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
      ),
      if (extraValues != null)
        LineChartBarData(
          spots: List.generate(extraValues.length, (i) => FlSpot(i.toDouble(), extraValues[i])),
          isCurved: true,
          color: extraColor ?? Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: extraColor ?? Colors.red,
            ),
          ),
          belowBarData: BarAreaData(show: true, color: (extraColor ?? Colors.red).withOpacity(0.1)),
        ),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: safeMax * 1.3,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= months.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(months[index], style: const TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) return const SizedBox();
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.brown));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.brown.withOpacity(0.2), strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: Colors.brown.withOpacity(0.1), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: lines,
      ),
    );
  }
}