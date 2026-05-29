import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Customer_screen/1.Launch/launch_welcome_screen.dart';
import 'driver_request_page.dart';
import '../Admin_screen/FeedbackPage.dart';
import '../Language/app_strings.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DriverStatsTab(),
    const DriverRequestsTab(),
    const DriverProfileTab(),
  ];

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LaunchWelcomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            top: 40,
            right: 15,
            child: IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: Colors.red, size: 28),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==========================================
// 1. Stats / Dashboard Tab
// ==========================================
class DriverStatsTab extends StatelessWidget {
  const DriverStatsTab({super.key});

  Future<Map<String, dynamic>> _loadStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final now = DateTime.now();
    final months =
    List.generate(6, (i) => DateTime(now.year, now.month - 5 + i));

    final ordersSnap = await FirebaseFirestore.instance
        .collection('ORDERS')
        .where('Driver_ID', isEqualTo: uid)
        .get();

    List<double> earningsPerMonth = List.filled(6, 0);
    List<double> deliveriesPerMonth = List.filled(6, 0);

    for (var doc in ordersSnap.docs) {
      final data = doc.data();
      final date = (data['Order_Date'] as Timestamp?)?.toDate();
      if (date == null) continue;
      for (int i = 0; i < 6; i++) {
        if (date.year == months[i].year &&
            date.month == months[i].month) {
          deliveriesPerMonth[i]++;
          earningsPerMonth[i] +=
          ((data['Total_Price'] ?? 0).toDouble() * 0.1); // 10% commission
        }
      }
    }

    // Ratings from FEEDBACK
    List<double> ratingPerMonth = List.filled(6, 0);
    List<int> ratingCountPerMonth = List.filled(6, 0);

    final feedbackSnap = await FirebaseFirestore.instance
        .collection('FEEDBACK')
        .where('Driver_ID', isEqualTo: uid)
        .get();

    for (var doc in feedbackSnap.docs) {
      final data = doc.data();
      final date = (data['Date'] as Timestamp?)?.toDate();
      final double rating = (data['Rating'] ?? 0).toDouble();
      if (date == null) continue;
      for (int i = 0; i < 6; i++) {
        if (date.year == months[i].year && date.month == months[i].month) {
          ratingPerMonth[i] += rating;
          ratingCountPerMonth[i]++;
        }
      }
    }

    List<double> avgRatingPerMonth = List.generate(6, (i) {
      if (ratingCountPerMonth[i] == 0) return 0;
      return ratingPerMonth[i] / ratingCountPerMonth[i];
    });

    return {
      'months': months.map((m) {
        const names = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return names[m.month - 1];
      }).toList(),
      'earnings': earningsPerMonth,
      'deliveries': deliveriesPerMonth,
      'ratings': avgRatingPerMonth,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            "Driver Dashboard",
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.brown),
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
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.deepOrange));
                  }
                  final stats = snapshot.data as Map<String, dynamic>;
                  final months = List<String>.from(stats['months']);

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Welcome card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5CB58),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.delivery_dining,
                                    color: Colors.brown, size: 32),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Welcome, Captain! 🚗",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown)),
                                  SizedBox(height: 4),
                                  Text("Here's your performance overview",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.brown)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildChartCard(
                          title: "Earnings (JD)",
                          icon: Icons.payments,
                          color: Colors.deepOrange,
                          months: months,
                          values: List<double>.from(stats['earnings']),
                          suffix: " JD",
                        ),
                        const SizedBox(height: 20),
                        _buildChartCard(
                          title: "Deliveries",
                          icon: Icons.delivery_dining,
                          color: Colors.blueAccent,
                          months: months,
                          values: List<double>.from(stats['deliveries']),
                          suffix: "",
                        ),
                        const SizedBox(height: 20),
                        _buildChartCard(
                          title: AppStrings.ratingLabel,
                          icon: Icons.star,
                          color: Colors.amber,
                          months: months,
                          values: List<double>.from(stats['ratings']),
                          suffix: "/5",
                          minY: 0,
                          maxY: 5,
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
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final safeMax = (maxY != null) ? maxY : (maxVal == 0 ? 10.0 : maxVal);
    final interval = ((safeMax - (minY ?? 0)) / 4).ceilToDouble();

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
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY ?? 0,
                maxY: safeMax * (maxY != null ? 1.0 : 1.3),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${months[spot.x.toInt()]}\n${spot.y.toStringAsFixed(1)}$suffix',
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
                          child: Text(months[index],
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.brown,
                                  fontWeight: FontWeight.bold)),
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
                        return Text(value.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.brown));
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
                      color: Colors.brown.withOpacity(0.2), strokeWidth: 1),
                  getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.brown.withOpacity(0.1), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                        values.length,
                            (i) => FlSpot(i.toDouble(), values[i])),
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
                        show: true, color: color.withOpacity(0.15)),
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

// ==========================================
// 2. Orders / Requests Tab
// ==========================================
class DriverRequestsTab extends StatefulWidget {
  const DriverRequestsTab({super.key});

  @override
  State<DriverRequestsTab> createState() => _DriverRequestsTabState();
}

class _DriverRequestsTabState extends State<DriverRequestsTab> {
  // نفس منطق DriverRequestsPage القديمة لكن مدمجة هنا
  // (اتركيها كـ placeholder أو استوردي الـ widget الكامل)
  @override
  Widget build(BuildContext context) {
    return const DriverRequestsPage();
  }
}

// ==========================================
// 3. Profile Tab
// ==========================================
class DriverProfileTab extends StatelessWidget {
  const DriverProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            "My Profile",
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.brown),
          ),
          const SizedBox(height: 30),
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
              child: uid.isEmpty
                  ? const Center(child: Text("Please login first"))
                  : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('DRIVERS')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.data()
                  as Map<String, dynamic>? ??
                      {};

                  final String name = data['name'] ?? 'N/A';
                  final String email = data['email'] ?? 'N/A';
                  final String phone = data['phone'] ?? 'N/A';
                  final String city = data['city'] ?? 'N/A';
                  final String carModel = data['carModel'] ?? 'N/A';
                  final String carPlate = data['carPlate'] ?? 'N/A';
                  final String carYear = data['carYear'] ?? 'N/A';
                  final String experience = data['experience'] ?? 'N/A';
                  final String license = data['driverLicense'] ?? 'N/A';

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFFF5CB58),
                          child: Icon(Icons.person,
                              size: 60, color: Colors.brown),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "DRIVER",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrangeAccent),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Personal Info
                        _sectionTitle("Personal Info"),
                        _infoTile(Icons.email, "Email", email),
                        const Divider(),
                        _infoTile(Icons.phone, "Phone", phone),
                        const Divider(),
                        _infoTile(
                            Icons.location_on, "City", city),
                        const Divider(),
                        _infoTile(Icons.badge, "License", license),

                        const SizedBox(height: 20),

                        // Vehicle Info
                        _sectionTitle("Vehicle Info"),
                        _infoTile(Icons.directions_car,
                            "Car Model", carModel),
                        const Divider(),
                        _infoTile(Icons.pin, "Plate", carPlate),
                        const Divider(),
                        _infoTile(Icons.calendar_today,
                            "Car Year", carYear),
                        const Divider(),
                        _infoTile(
                            Icons.work, "Experience", "$experience yrs"),

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
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrangeAccent),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(label),
      subtitle: Text(value),
      contentPadding: EdgeInsets.zero,
    );
  }
}