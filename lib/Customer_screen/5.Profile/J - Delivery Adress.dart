// K - Delivery Address Screen
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'K - Delivery Adress - Add New Address.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  int? _selectedIndex;
  List<Map<String, dynamic>> addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (uid.isEmpty) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('CUSTOMERS')
        .doc(uid)
        .collection('ADDRESSES')
        .orderBy('createdAt', descending: false)
        .get();

    setState(() {
      addresses = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "title": data["title"] ?? "",
          "address": data["address"] ?? "",
          "lat": data["lat"] ?? 0.0,
          "lng": data["lng"] ?? 0.0,
        };
      }).toList();
    });
  }

  Future<void> _deleteAddress(int index) async {
    if (uid.isEmpty) return;
    final docId = addresses[index]["id"];
    await FirebaseFirestore.instance
        .collection('CUSTOMERS')
        .doc(uid)
        .collection('ADDRESSES')
        .doc(docId)
        .delete();
    setState(() {
      addresses.removeAt(index);
      if (_selectedIndex == index) _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Positioned(
            top: 35,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Delivery Address",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),
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
                  child: Column(
                    children: [
                      // ✅ الخريطة
                      if (_selectedIndex != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 180,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  addresses[_selectedIndex!]["lat"],
                                  addresses[_selectedIndex!]["lng"],
                                ),
                                initialZoom: 15,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.nimah_app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        addresses[_selectedIndex!]["lat"],
                                        addresses[_selectedIndex!]["lng"],
                                      ),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.deepOrange,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (_selectedIndex != null) const SizedBox(height: 15),

                      Expanded(
                        child: addresses.isEmpty
                            ? const Center(child: Text("No addresses yet"))
                            : ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            return _addressCard(index);
                          },
                        ),
                      ),

                      if (_selectedIndex != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                addresses[_selectedIndex!]["address"],
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Confirm Address",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddAddressScreen(),
                              ),
                            );
                            if (result != null && uid.isNotEmpty) {
                              final docRef = await FirebaseFirestore.instance
                                  .collection('CUSTOMERS')
                                  .doc(uid)
                                  .collection('ADDRESSES')
                                  .add({
                                "title": result["title"],
                                "address": result["address"],
                                "lat": result["lat"],
                                "lng": result["lng"],
                                "createdAt": FieldValue.serverTimestamp(),
                              });
                              setState(() {
                                addresses.add({
                                  "id": docRef.id,
                                  ...Map<String, dynamic>.from(result),
                                });
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Add New Address",
                            style: TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addressCard(int index) {
    final item = addresses[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.deepOrange, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.deepOrange : Colors.black,
                    ),
                  ),
                  Text(
                    item["address"],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteAddress(index),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.deepOrange : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}