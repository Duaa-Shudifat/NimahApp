import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../4.Home Page/BottomNavBar.dart';
import '../4.Home Page/HomePage.dart';
import '../4.Home Page/back_icon.dart';

class DeliveryTimeScreen extends StatefulWidget {
  final String orderId; // ✅ أضف هاي فقط
  const DeliveryTimeScreen({super.key, required this.orderId});

  @override
  State<DeliveryTimeScreen> createState() => _DeliveryTimeScreenState();
}

class _DeliveryTimeScreenState extends State<DeliveryTimeScreen> {
  LatLng? _driverLocation;
  StreamSubscription? _orderSub;
  final MapController _mapController = MapController();
  final LatLng _customerLocation = const LatLng(32.5568, 35.8469);

  @override
  void initState() {
    super.initState();
    _listenToDriver();
  }

  void _listenToDriver() {
    _orderSub = FirebaseFirestore.instance
        .collection('ORDERS')
        .doc(widget.orderId)
        .snapshots()
        .listen((doc) {
      final data = doc.data();
      if (data == null) return;
      final lat = data['Driver_Lat'];
      final lng = data['Driver_Lng'];
      if (lat != null && lng != null) {
        final newLocation = LatLng(lat.toDouble(), lng.toDouble());
        setState(() => _driverLocation = newLocation);
        _mapController.move(newLocation, 15);
      }
    });
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: const Color(0xFFF5CB58),
          elevation: 0,
          leading: BackButtonPositioned(targetPage: const HomePage()),
          title: const Text(
            "Delivery Time",
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                "Shipping Address",
                style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE082),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "778 Locust View Drive Oakland, CA",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 15),

              // الخريطة
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 220,
                  child: _driverLocation == null
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.deepOrange),
                        SizedBox(height: 10),
                        Text("Waiting for driver location..."),
                      ],
                    ),
                  )
                      : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _driverLocation!,
                      initialZoom: 14,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'nimah.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _driverLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.deepOrange,
                              size: 35,
                            ),
                          ),
                          Marker(
                            point: _customerLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.home,
                              color: Colors.brown,
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Delivery Time",
                style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(height: 5),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Estimated Delivery",
                      style: TextStyle(color: Colors.grey)),
                  Text("25 mins",
                      style: TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              timelineItem("Your order has been accepted", "2 min"),
              timelineItem("The restaurant is preparing your order", "5 min"),
              timelineItem("The delivery is on his way", "10 min"),
              timelineItem("Your order has been delivered", "8 min"),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  static Widget timelineItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 10, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
              child: Text(title,
                  style: const TextStyle(color: Colors.black87))),
          Text(time, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}