import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Customer_screen/Notification/notification_service.dart';
import '../Customer_screen/1.Launch/launch_welcome_screen.dart';
import 'package:geolocator/geolocator.dart';

class DriverRequestsPage extends StatefulWidget {
  const DriverRequestsPage({super.key});

  @override
  State<DriverRequestsPage> createState() => _DriverRequestsPageState();
}

class _DriverRequestsPageState extends State<DriverRequestsPage> {
  int selectedIndex = 0;
  final String driverUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  StreamSubscription<Position>? _locationSubscription;
  String _driverCity = '';

  @override
  void initState() {
    super.initState();
    _loadDriverCity();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDriverCity() async {
    final doc = await FirebaseFirestore.instance
        .collection('DRIVERS')
        .doc(driverUid)
        .get();

    final rawCity = doc['city'] ?? '';
    setState(() {
      _driverCity = rawCity
          .toString()
          .replaceAll(', Jordan', '')
          .replaceAll(',Jordan', '')
          .trim();
    });
  }

  Future<void> _startLocationTracking(String orderId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      FirebaseFirestore.instance.collection('ORDERS').doc(orderId).update({
        'Driver_Lat': position.latitude,
        'Driver_Lng': position.longitude,
      });
    });
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Query get _query {
    final base = FirebaseFirestore.instance.collection('ORDERS');
    if (selectedIndex == 0) {
      return base
          .where('Status', isEqualTo: 'Accepted')
          .where('Driver_ID', isEqualTo: '')
          .orderBy('Order_Date', descending: true);
    } else if (selectedIndex == 1) {
      return base
          .where('Status', isEqualTo: 'On the Way')
          .where('Driver_ID', isEqualTo: driverUid)
          .orderBy('Order_Date', descending: true);
    } else {
      return base
          .where('Status', whereIn: ['Delivered', 'Cancelled'])
          .where('Driver_ID', isEqualTo: driverUid)
          .orderBy('Order_Date', descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5CB58),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            "Delivery Orders",
            style: TextStyle(
                color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.deepOrangeAccent,
            labelColor: Colors.brown,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "New", icon: Icon(Icons.new_releases)),
              Tab(text: "My Tasks", icon: Icon(Icons.timer)),
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
          child: _driverCity.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            children: [
              _DriverOrdersList(
                driverUid: driverUid,
                tabIndex: 0,
                driverCity: _driverCity,
                onAccepted: _startLocationTracking,
                onDelivered: _stopLocationTracking,
              ),
              _DriverOrdersList(
                driverUid: driverUid,
                tabIndex: 1,
                driverCity: _driverCity,
                onAccepted: _startLocationTracking,
                onDelivered: _stopLocationTracking,
              ),
              _DriverOrdersList(
                driverUid: driverUid,
                tabIndex: 2,
                driverCity: _driverCity,
                onAccepted: _startLocationTracking,
                onDelivered: _stopLocationTracking,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widget مشترك لعرض الطلبات حسب التبويب
// ─────────────────────────────────────────
class _DriverOrdersList extends StatelessWidget {
  final String driverUid;
  final int tabIndex;
  final String driverCity;
  final Function(String orderId) onAccepted;
  final VoidCallback onDelivered;

  const _DriverOrdersList({
    required this.driverUid,
    required this.tabIndex,
    required this.driverCity,
    required this.onAccepted,
    required this.onDelivered,
  });

  Query get _query {
    final base = FirebaseFirestore.instance.collection('ORDERS');
    if (tabIndex == 0) {
      return base
          .where('Status', isEqualTo: 'Accepted')
          .where('Driver_ID', isEqualTo: '')
          .orderBy('Order_Date', descending: true);
    } else if (tabIndex == 1) {
      return base
          .where('Status', isEqualTo: 'On the Way')
          .where('Driver_ID', isEqualTo: driverUid)
          .orderBy('Order_Date', descending: true);
    } else {
      return base
          .where('Status', whereIn: ['Delivered', 'Cancelled'])
          .where('Driver_ID', isEqualTo: driverUid)
          .orderBy('Order_Date', descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text(
                  tabIndex == 0
                      ? "No new orders available"
                      : "Nothing here yet",
                  style:
                  TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
              ],
            ),
          );
        }

        // فلتر المدينة للتبويب الأول فقط
        final orders = tabIndex == 0
            ? snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final city = (data['City'] ?? '')
              .toString()
              .replaceAll(', Jordan', '')
              .replaceAll(',Jordan', '')
              .trim()
              .toLowerCase();
          return city == driverCity.toLowerCase();
        }).toList()
            : snapshot.data!.docs;

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delivery_dining,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text(
                  "No orders in your city yet",
                  style:
                  TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final doc = orders.elementAt(index);
            final data = doc.data() as Map<String, dynamic>;
            return _DriverOrderCard(
              orderId: doc.id,
              data: data,
              driverUid: driverUid,
              tabIndex: tabIndex,
              onAccepted: onAccepted,
              onDelivered: onDelivered,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// كرت الطلب للدرايفر
// ─────────────────────────────────────────
class _DriverOrderCard extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> data;
  final String driverUid;
  final int tabIndex;
  final Function(String orderId) onAccepted;
  final VoidCallback onDelivered;

  const _DriverOrderCard({
    required this.orderId,
    required this.data,
    required this.driverUid,
    required this.tabIndex,
    required this.onAccepted,
    required this.onDelivered,
  });

  @override
  State<_DriverOrderCard> createState() => _DriverOrderCardState();
}

class _DriverOrderCardState extends State<_DriverOrderCard> {
  bool _isLoading = false;

  Future<void> _acceptOrder() async {
    setState(() => _isLoading = true);
    try {
      final docRef = FirebaseFirestore.instance
          .collection('ORDERS')
          .doc(widget.orderId);
      final orderSnap = await docRef.get();
      final orderData = orderSnap.data() as Map<String, dynamic>;
      final customerId = orderData['Customer_ID'];

      if (orderData['Driver_ID'] != '') {
        throw Exception("Order already taken");
      }

      await docRef.update({
        'Driver_ID': widget.driverUid,
        'Status': 'On the Way',
      });

      final customerDoc = await FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(customerId)
          .get();
      final fcmToken = customerDoc['fcmToken'];

      if (fcmToken != null) {
        await NotificationService.sendNotification(
          fcmToken: fcmToken,
          title: "Delivery on the way",
          body: "The driver has picked up your order.",
          orderId: widget.orderId,
          type: "delivery",
        );
        await FirebaseFirestore.instance
            .collection('USER_NOTIFICATIONS')
            .add({
          'userId': customerId,
          'title': "Delivery on the way",
          'body': "The driver has picked up your order.",
          'type': "delivery",
          'orderId': widget.orderId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      widget.onAccepted(widget.orderId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _markDelivered() async {
    final docRef = FirebaseFirestore.instance
        .collection('ORDERS')
        .doc(widget.orderId);
    final orderSnap = await docRef.get();
    final orderData = orderSnap.data() as Map<String, dynamic>;
    final customerId = orderData['Customer_ID'];

    await docRef.update({'Status': 'Delivered'});

    final customerDoc = await FirebaseFirestore.instance
        .collection('CUSTOMERS')
        .doc(customerId)
        .get();
    final fcmToken = customerDoc['fcmToken'];

    if (fcmToken != null) {
      await NotificationService.sendNotification(
        fcmToken: fcmToken,
        title: "Order delivered! Please rate us",
        body: "Enjoy your meal! Please leave your rating.",
        orderId: widget.orderId,
        type: "delivery",
      );
      await FirebaseFirestore.instance
          .collection('USER_NOTIFICATIONS')
          .add({
        'userId': customerId,
        'title': "Order delivered! Please rate us",
        'body': "Enjoy your meal! Please leave your rating.",
        'type': "delivery",
        'orderId': widget.orderId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    widget.onDelivered();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.blue;
      case "On the Way":
        return Colors.purple;
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = widget.data['Status'] ?? '';
    final List items = widget.data['Items'] ?? [];
    final String address = widget.data['Address'] ?? 'N/A';
    final String payment = widget.data['Payment_Method'] ?? 'N/A';
    final String notes = widget.data['Notes'] ?? '';
    final double total = (widget.data['Total_Price'] ?? 0).toDouble();
    final String city = (widget.data['City'] ?? 'N/A')
        .toString()
        .replaceAll(', Jordan', '')
        .trim();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(widget.data['Customer_ID'])
          .get(),
      builder: (context, customerSnap) {
        String customerName = "Loading...";
        if (customerSnap.hasData && customerSnap.data!.exists) {
          final cData =
          customerSnap.data!.data() as Map<String, dynamic>;
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${widget.orderId.substring(0, 6).toUpperCase()}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.brown),
                  ),
                  _StatusBadge(status: status),
                ],
              ),
              const Divider(height: 20),

              // Info rows
              _infoRow(Icons.person, "Customer", customerName),
              _infoRow(Icons.location_on, "Address", address),
              _infoRow(Icons.location_city, "City", city),
              _infoRow(Icons.payment, "Payment", payment),
              if (notes.isNotEmpty)
                _infoRow(Icons.note, "Notes", notes),

              const SizedBox(height: 10),

              // Items
              const Text(
                "🍽️ Items:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 6),
              ...items.map((item) {
                final name = item['Product_ID'] ?? '';
                final qty = item['Quantity'] ?? 1;
                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 6, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text("$name  ×$qty",
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 10),

              // Total
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Total: ${total.toStringAsFixed(2)} JD",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.deepOrange),
                ),
              ),

              // Action buttons
              if (widget.tabIndex == 0) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _acceptOrder,
                    icon: _isLoading
                        ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.delivery_dining,
                        color: Colors.white, size: 18),
                    label: Text(
                        _isLoading ? "Accepting..." : "Accept Order",
                        style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ] else if (widget.tabIndex == 1) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _markDelivered,
                    icon: const Icon(Icons.check_circle,
                        color: Colors.white, size: 18),
                    label: const Text("Mark as Delivered",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.brown)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
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
      case "Accepted":
        return Colors.blue;
      case "On the Way":
        return Colors.purple;
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
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
            color: _color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}