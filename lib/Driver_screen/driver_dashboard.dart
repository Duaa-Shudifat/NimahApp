import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Customer_screen/1.Launch/launch_welcome_screen.dart';
import 'driver_request_page.dart';
import '../Admin_screen/FeedbackPage.dart';
import '../Language/app_strings.dart';
class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LaunchWelcomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> months = ['Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May'];
    final List<double> earnings = [18, 22, 15, 30, 25, 28];
    final List<double> ratings = [4.5, 4.6, 4.4, 4.8, 4.7, 4.8];

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Driver Dashboard",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // الصورة والاسم
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFFF5CB58),
                          child: Icon(Icons.person, color: Colors.brown, size: 40),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Welcome, Captain!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Chart 1: Earnings
                        _buildChartCard(
                          title: "Earnings (JD)",
                          icon: Icons.payments,
                          color: Colors.deepOrange,
                          months: months,
                          values: earnings,
                          suffix: " JD",
                        ),
                        const SizedBox(height: 20),

                        // Chart 2: Rating
                        _buildChartCard(

                          title: AppStrings.ratingLabel, // استخدام كلمة "التقييم" من ملف اللغات [1]
                          icon: Icons.star,
                          color: Colors.amber,
                          months: months,
                          values: ratings,
                          suffix: "/5",
                          minY: 0,
                          maxY: 5,
                        ),
                        const SizedBox(height: 30),

                        // زر الطلبات
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const DriverRequestsPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5CB58),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text(
                              "Go to Active Requests",
                              style: TextStyle(
                                color: Colors.brown,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                            tileColor: Colors.amber.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            leading: const Icon(Icons.reviews_rounded, color: Colors.amber),
                            title: Text(AppStrings.feedbackTitle),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FeedbackPage(providerName: "Driver Name"),));
                            })],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // زر اللوقاوت
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
    required Color color,
    required List<String> months,
    required List<double> values,
    required String suffix,
    double? minY,
    double? maxY,
  }) {
    final calculatedMin = minY ?? 0;
    final calculatedMax = maxY ?? values.reduce((a, b) => a > b ? a : b) * 1.3;

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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: calculatedMin,
                maxY: calculatedMax,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${months[spot.x.toInt()]}\n${spot.y}$suffix',
                          TextStyle(
                              color: color, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= months.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            months[index],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (calculatedMax - calculatedMin) / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max) return const SizedBox();
                        return Text(
                          value.toStringAsFixed(suffix.isEmpty ? 1 : 0),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.brown),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.brown.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.brown.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      values.length,
                          (index) => FlSpot(index.toDouble(), values[index]),
                    ),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: color,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}