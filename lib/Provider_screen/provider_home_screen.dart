import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../Customer_screen/1.Launch/launch_welcome_screen.dart';
import '../Customer_screen/Notification/notification_service.dart';
import '../Admin_screen/FeedbackPage.dart';
import '../Language/app_strings.dart';

// ==========================================
// Cloudinary Config
// ==========================================
const String cloudinaryCloudName = 'dasrhmmgz';
const String cloudinaryUploadPreset = 'f19cagom';

Future<String?> uploadToCloudinary(File file) async {
  try {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseData = await response.stream.toBytes();
    final jsonData = json.decode(String.fromCharCodes(responseData));

    if (response.statusCode == 200) {
      return jsonData['secure_url'];
    } else {
      debugPrint('Cloudinary Error: $jsonData');
      return null;
    }
  } catch (e) {
    debugPrint('Upload Exception: $e');
    return null;
  }
}

// ==========================================
// Provider Home Screen
// ==========================================
class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const OrdersTab(),
    const MenuTab(),
    const ProfileTab(),
  ];

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LaunchWelcomeScreen(),
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==========================================
// 1. Dashboard Tab
// ==========================================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Future<Map<String, dynamic>> _loadStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - 5 + i));

    // جيب طلبات المطعم بس
    final ordersSnap = await FirebaseFirestore.instance
        .collection('ORDERS')
        .where('Provider_ID', isEqualTo: uid)
        .get();

    // جيب عدد الوجبات بالمنيو
    final menuSnap = await FirebaseFirestore.instance
        .collection('FOOD_PROVIDERS')
        .doc(uid)
        .collection('MENU')
        .get();

    List<double> salesPerMonth = List.filled(6, 0);
    List<double> revenuePerMonth = List.filled(6, 0);
    List<double> completedPerMonth = List.filled(6, 0);

    for (var doc in ordersSnap.docs) {
      final data = doc.data();
      final date = (data['Order_Date'] as Timestamp?)?.toDate();
      if (date == null) continue;

      for (int i = 0; i < 6; i++) {
        if (date.year == months[i].year && date.month == months[i].month) {
          salesPerMonth[i]++;
          revenuePerMonth[i] += (data['Total_Price'] ?? 0).toDouble();
          if (data['Status'] == 'Delivered' || data['Status'] == 'Completed') {
            completedPerMonth[i]++;
          }
        }
      }

      // احسب متوسط التقييم
      double totalRating = 0;
      int ratingCount = 0;
      List<double> ratingPerMonth = List.filled(6, 0);
      List<int> ratingCountPerMonth = List.filled(6, 0);

      final feedbackSnap = await FirebaseFirestore.instance
          .collection('FEEDBACK')
          .where('Provider_ID', isEqualTo: uid)
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

// احسب المتوسط لكل شهر
      List<double> avgRatingPerMonth = List.generate(6, (i) {
        if (ratingCountPerMonth[i] == 0) return 0;
        return ratingPerMonth[i] / ratingCountPerMonth[i];
      });
    }

    return {
      'months': months.map((m) {
        const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        return names[m.month - 1];
      }).toList(),
      'sales': salesPerMonth,
      'revenue': revenuePerMonth,
      'completed': completedPerMonth,
      'menuCount': List.filled(6, menuSnap.docs.length.toDouble()),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text("Provider Dashboard",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown)),
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
                          title: "Total Sales",
                          icon: Icons.attach_money,
                          color: Colors.blueAccent,
                          months: months,
                          values: List<double>.from(stats['sales']),
                          suffix: "",
                        ),
                        const SizedBox(height: 20),
                        _buildChartCard(
                          title: "Revenue (JD)",
                          icon: Icons.account_balance_wallet,
                          color: Colors.green,
                          months: months,
                          values: List<double>.from(stats['revenue']),
                          suffix: "JD ",
                        ),
                        const SizedBox(height: 20),
                        _buildChartCard(
                          title: "Completed Orders",
                          icon: Icons.shopping_cart,
                          color: Colors.deepOrange,
                          months: months,
                          values: List<double>.from(stats['completed']),
                          suffix: "",
                        ),
                        const SizedBox(height: 20),
                        _buildChartCard(
                          title: "Meals in Menu",
                          icon: Icons.restaurant,
                          color: Colors.brown,
                          months: months,
                          values: List<double>.from(stats['menuCount']),
                          suffix: "",
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
  }) {
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal == 0 ? 10.0 : maxVal;
    final interval = (safeMax / 4).ceilToDouble();

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
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: safeMax * 1.3,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${months[spot.x.toInt()]}\n$suffix${spot.y.toStringAsFixed(1)}',
                          TextStyle(color: color, fontWeight: FontWeight.bold),
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
                lineBarsData: [
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
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.15)),
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
// استبدل OrdersTab في provider_home_screen.dart بهاي الكلاس
// ==========================================

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5CB58),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Orders Tracking",
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.deepOrangeAccent,
            labelColor: Colors.brown,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "New", icon: Icon(Icons.new_releases)),
              Tab(text: "Ongoing", icon: Icon(Icons.timer)),
              Tab(text: "History", icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
          ),
          child: TabBarView(
            children: [
              _ProviderOrdersList(providerUid: uid, statusFilter: "Pending"),
              _ProviderOrdersList(providerUid: uid, statusFilter: "Ongoing"),
              _ProviderOrdersList(providerUid: uid, statusFilter: "History"),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widget مشترك لعرض الطلبات حسب الحالة
// ─────────────────────────────────────────
class _ProviderOrdersList extends StatelessWidget {
  final String providerUid;
  final String statusFilter;

  const _ProviderOrdersList({
    required this.providerUid,
    required this.statusFilter,
  });

  // الحالات المرتبطة بكل تبويب
  List<String> get _statuses {
    if (statusFilter == "Pending") return ["Pending"];
    if (statusFilter == "Ongoing") return ["Accepted", "Preparing", "On the Way"];
// جديد
    return ["Delivered", "Completed", "Cancelled"];  }

  @override
  Widget build(BuildContext context) {
    if (providerUid.isEmpty) {
      return const Center(child: Text("Please login first"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ORDERS')
          .where('Provider_ID', isEqualTo: providerUid)
          .where('Status', whereIn: _statuses)
          .orderBy('Order_Date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text(
                  "No orders here yet",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final doc = orders[index];
            final data = doc.data() as Map<String, dynamic>;
            return _ProviderOrderCard(
              orderId: doc.id,
              data: data,
              statusFilter: statusFilter,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// كرت الطلب للمطعم — يعرض كل التفاصيل
// ─────────────────────────────────────────
class _ProviderOrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> data;
  final String statusFilter;

  const _ProviderOrderCard({
    required this.orderId,
    required this.data,
    required this.statusFilter,
  });

  String _getNotificationTitle(String status) {
    switch (status) {
      case "Accepted":
        return "Order Accepted ✅";
      case "Preparing":
        return "Your Order is Ready 🍽️";
      case "On the Way":
        return "Order On The Way 🚗";
      case "Delivered":
        return "Order Delivered ✅";
      case "Cancelled":
        return "Order Cancelled ❌";
      default:
        return "Order Update";
    }
  }

  String _getNotificationBody(String status) {
    switch (status) {
      case "Accepted":
        return "Your order has been accepted by the restaurant.";
      case "Preparing":
        return "Your order is ready and waiting for a driver.";
      case "On the Way":
        return "Your order is on the way.";
      case "Delivered":
        return "Your order has been delivered.";
      case "Cancelled":
        return "Sorry, your order was cancelled.";
      default:
        return "Your order status has been updated.";
    }
  }


  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('ORDERS')
        .doc(docId)
        .update({'Status': newStatus});

    final orderDoc = await FirebaseFirestore.instance
        .collection('ORDERS')
        .doc(docId)
        .get();

    final orderData = orderDoc.data();
    if (orderData == null) return;

    // =========================
    // 1) إشعار الزبون
    // =========================
    final String customerId = orderData['Customer_ID'] ?? '';

    if (customerId.isNotEmpty) {
      final customerDoc = await FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(customerId)
          .get();

      final customerData = customerDoc.data();
      final String? customerToken = customerData?['fcmToken'];

      await FirebaseFirestore.instance.collection('USER_NOTIFICATIONS').add({
        'userId': customerId,
        'title': _getNotificationTitle(newStatus),
        'body': _getNotificationBody(newStatus),
        'type': "order",
        'orderId': docId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (customerToken != null && customerToken.isNotEmpty) {
        await NotificationService.sendNotification(
          fcmToken: customerToken,
          title: _getNotificationTitle(newStatus),
          body: _getNotificationBody(newStatus),
          orderId: docId,
          type: "order",
        );

        print("Customer notification sent");
      } else {
        print("Customer has no fcmToken");
      }
    }

    // =========================
    // 2) إشعار الدرايفر فقط لما المطعم يقبل
    // =========================
    if (newStatus == 'Accepted') {
      final String orderCity = (orderData['City'] ?? '')
          .toString()
          .replaceAll(', Jordan', '')
          .replaceAll(',Jordan', '')
          .trim()
          .toLowerCase();

      print("ORDER CITY: '$orderCity'");

      final driversSnap = await FirebaseFirestore.instance
          .collection('DRIVERS')
          .get();

      for (var driverDoc in driversSnap.docs) {
        final driverData = driverDoc.data();

        final String driverCity = (driverData['city'] ?? '')
            .toString()
            .replaceAll(', Jordan', '')
            .replaceAll(',Jordan', '')
            .trim()
            .toLowerCase();

        final String? driverToken = driverData['fcmToken'];

        print("DRIVER: ${driverData['name']} | CITY: '$driverCity' | TOKEN: $driverToken");

        if (driverCity == orderCity) {
          if (driverToken != null && driverToken.isNotEmpty) {
            await NotificationService.sendNotification(
              fcmToken: driverToken,
              title: "New Delivery Available 🚗",
              body: "A new order is ready for pickup in $orderCity.",
              orderId: docId,
              type: "delivery",
            );

            print("Driver notification sent");
          } else {
            print("Driver ${driverData['name']} has no fcmToken");
          }
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final String status = data['Status'] ?? 'Pending';
    final List items = data['Items'] ?? [];
    final String address = data['Address'] ?? 'N/A';
    final String payment = data['Payment_Method'] ?? 'N/A';
    final String notes = data['Notes'] ?? '';
    final double total = (data['Total_Price'] ?? 0).toDouble();

    // جلب اسم الزبون من Firestore بشكل async
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(data['Customer_ID'])
          .get(),
      builder: (context, customerSnap) {
        String customerName = "Loading...";
        if (customerSnap.hasData && customerSnap.data!.exists) {
          final cData = customerSnap.data!.data() as Map<String, dynamic>;
          customerName = cData['name'] ?? 'Unknown';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7E0),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _statusColor(status).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: رقم الطلب + الحالة ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${orderId.substring(0, 6).toUpperCase()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.brown,
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const Divider(height: 20),

              // ── اسم الزبون والعنوان ──
              _infoRow(Icons.person, "Customer", customerName),
              _infoRow(Icons.location_on, "Address", address),
              _infoRow(Icons.payment, "Payment", payment),
              if (notes.isNotEmpty) _infoRow(Icons.note, "Notes", notes),

              const SizedBox(height: 10),

              // ── الأصناف ──
              const Text(
                "🍽️ Items:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 6),
              ...items.map((item) {
                final name = item['Product_ID'] ?? '';
                final qty = item['Quantity'] ?? 1;
                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text("$name  ×$qty",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 10),

              // ── السعر الإجمالي ──
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Total: ${total.toStringAsFixed(2)} JD",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.deepOrange,
                  ),
                ),
              ),

              // ── أزرار الإجراء (فقط للمطعم) ──
              if (statusFilter == "Pending") ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // رفض
                    Expanded(
                      child: OutlinedButton.icon(
        onPressed: () => _updateStatus(orderId, "Cancelled"),
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 16),
                        label: const Text("Reject",
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // قبول
                    Expanded(
                      child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(orderId, "Accepted"),
                        icon: const Icon(Icons.check, color: Colors.white, size: 16),
                        label: const Text("Accept",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (statusFilter == "Ongoing" && status == "Accepted") ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
        onPressed: () => _updateStatus(orderId, "Preparing"),
                    icon: const Icon(Icons.restaurant, color: Colors.white, size: 16),
                    label: const Text("Mark as Done",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.deepOrange),
          const SizedBox(width: 6),
          Text("$label: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Pending": return Colors.orange;
      case "Accepted": return Colors.blue;
      case "Preparing": return Colors.deepOrange;
      case "On the Way": return Colors.purple;
      case "Delivered": return Colors.green;
      case "Cancelled": return Colors.red;
      default: return Colors.grey;
    }
  }
}

// ─────────────────────────────────────────
// Badge صغير للحالة
// ─────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case "Pending": return Colors.orange;
      case "Accepted": return Colors.blue;
      case "Preparing": return Colors.deepOrange;
      case "On the Way": return Colors.purple;
      case "Delivered": return Colors.green;
      case "Cancelled": return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
// ==========================================
// 3. Menu Tab
// ==========================================
class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<void> _addMealDialog() async {
    final picker = ImagePicker();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final availableController = TextEditingController(text: "10");
    final descriptionController = TextEditingController();
    XFile? pickedImage;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ضروري للسماح للـ BottomSheet بالارتفاع الكامل
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          // Padding الديناميكي لمنع التداخل مع لوحة المفاتيح
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20, // دفع المحتوى فوق الكيبورد
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView( // حل مشكلة الـ Overlap (التداخل)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add New Meal",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () async {
                    final picked = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );
                    if (picked != null) {
                      pickedImage = picked;
                      setModalState(() {});
                    }
                  },
                  child: Container(
                    height: 100, width: 100,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15)),
                    child: pickedImage == null
                        ? const Icon(Icons.add_a_photo, size: 30)
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                    ),
                  ),
                ),
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Meal Name")
                ),
                TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Price"),
                    keyboardType: TextInputType.number
                ),
                TextField(
                    controller: availableController,
                    decoration: const InputDecoration(labelText: "Available Quantity"),
                    keyboardType: TextInputType.number
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Notes / Description (Optional)"),
                  maxLines: 2,
                ),

                // مسافة إضافية لرفع زر الحفظ
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a meal name!")),
                        );
                        return;
                      }

                      String imageUrl = 'https://cdn-icons-png.flaticon.com/512/3170/3170733.png';

                      if (pickedImage != null) {
                        final uploaded = await uploadToCloudinary(File(pickedImage!.path));
                        if (uploaded != null) imageUrl = uploaded;
                      }

                      if (uid.isNotEmpty) {
                        final mealData = {
                          'name': nameController.text.trim(),
                          'price': priceController.text.trim().isEmpty ? "0" : priceController.text.trim(),
                          'imageUrl': imageUrl,
                          'available': int.tryParse(availableController.text.trim()) ?? 0,
                          'description': descriptionController.text.trim(),
                          'Provider_ID': uid,
                        };

// ✅ احفظ بالـ MENU
                        await FirebaseFirestore.instance
                            .collection('FOOD_PROVIDERS')
                            .doc(uid)
                            .collection('MENU')
                            .add(mealData);

// ✅ احفظ بالـ PRODUCT كمان
                        await FirebaseFirestore.instance
                            .collection('PRODUCT')
                            .add({
                          'Name': nameController.text.trim(),
                          'Price': double.tryParse(priceController.text.trim()) ?? 0,
                          'image': imageUrl,
                          'Provider_ID': uid,
                          'category': '',
                          'Description': descriptionController.text.trim(),
                        });
                      }

                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text("Save Meal", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                // مسافة أمان أخيرة
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }




  Future<void> _editMealDialog(String docId, String oldName, String oldPrice,
      int oldAvailable, String currentImg, String oldDescription) async {
    final nameController = TextEditingController(text: oldName);
    final priceController = TextEditingController(text: oldPrice);
    final availableController = TextEditingController(text: oldAvailable.toString());
    final descriptionController = TextEditingController(text: oldDescription);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Edit Meal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    if (uid.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('FOOD_PROVIDERS')
                          .doc(uid)
                          .collection('MENU')
                          .doc(docId)
                          .delete();
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Meal Name")),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: availableController, decoration: const InputDecoration(labelText: "Available Quantity"), keyboardType: TextInputType.number),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Notes / Description"),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                if (uid.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('FOOD_PROVIDERS')
                      .doc(uid)
                      .collection('MENU')
                      .doc(docId)
                      .update({
                    'name': nameController.text.trim(),
                    'price': priceController.text.trim(),
                    'available': int.tryParse(availableController.text.trim()) ?? 0,
                    'description': descriptionController.text.trim(),
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Update Meal", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text("My Menu",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
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
                  : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('FOOD_PROVIDERS')
                    .doc(uid)
                    .collection('MENU')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  var meals = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      var meal = meals[index];
                      Map<String, dynamic> data = meal.data() as Map<String, dynamic>;
                      String mealDesc = data.containsKey('description') ? data['description'] : '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              meal['imageUrl'],
                              width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.fastfood),
                            ),
                          ),
                          title: Text(meal['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("\$${meal['price']} • Available: ${meal['available']}"),
                              if (mealDesc.isNotEmpty)
                                Text(mealDesc,
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              _editMealDialog(
                                meal.id,
                                meal['name'],
                                meal['price'].toString(),
                                meal['available'],
                                meal['imageUrl'],
                                mealDesc,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMealDialog,
        backgroundColor: Colors.deepOrangeAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Meal", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ==========================================
// 4. Profile Tab (Updated to show Name and Type)
// ==========================================
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  String restaurantName = "";

  void _navigateToFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackPage(providerName: restaurantName),
      ),
    );
  }

  Future<void> _updateProfileImage() async {
    final pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedImage != null && uid.isNotEmpty) {
      setState(() => _isUploading = true);

      try {
        final newImageUrl = await uploadToCloudinary(File(pickedImage.path));

        if (newImageUrl != null) {
          await FirebaseFirestore.instance
              .collection('FOOD_PROVIDERS')
              .doc(uid)
              .set({'logoUrl': newImageUrl}, SetOptions(merge: true));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile image updated successfully! ✅')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload failed ❌')),
            );
          }
        }
      } catch (e) {
        debugPrint("Upload Error: $e");
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) return const Center(child: Text("Please login first"));

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text("My Profile",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown)),
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
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('FOOD_PROVIDERS')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  var userData = snapshot.data!.data() as Map<String, dynamic>?;
                  if (userData == null)
                    return const Center(child: Text("No data found"));

                  // جلب البيانات المطلوبة
                  String imageUrl = userData['logoUrl'] ?? "";
                  String name = userData['name'] ?? 'N/A';
                  String providerType = userData['providerType'] ?? 'N/A';
                  String email = userData['email'] ?? 'N/A';
                  String phone = userData['phone'] ?? 'N/A';
                  String location = userData['city'] ?? 'N/A';

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _isUploading ? null : _updateProfileImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                                child: imageUrl.isEmpty
                                    ? const Icon(Icons.store, size: 60, color: Colors.grey)
                                    : null,
                              ),
                              if (_isUploading)
                                const Positioned.fill(
                                  child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
                                ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.deepOrangeAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ✅ عرض اسم المطعم (ثابت)
                        Text(
                          name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                        ),

                        // ✅ عرض نوع النشاط (ثابت)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            providerType.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
                          ),
                        ),

                        const SizedBox(height: 30),
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.brown),
                          title: const Text("Email"),
                          subtitle: Text(email),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.brown),
                          title: const Text("Phone"),
                          subtitle: Text(phone),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.brown),
                          title: const Text("City"),
                          subtitle: Text(location),
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
}