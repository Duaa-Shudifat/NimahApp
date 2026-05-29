import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  const OrderDetailsScreen({super.key, required this.orderData});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.orderData['status'];
  }

  void updateStatus() {
    setState(() {
      if (currentStatus == "accepted") currentStatus = "picked up";
      else if (currentStatus == "picked up") currentStatus = "on the way";
      else if (currentStatus == "on th\e way") currentStatus = "delivered";
      widget.orderData['status'] = currentStatus; // تحديث البيانات الأصلية [32، 42]
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      appBar: AppBar(
        title: Text("Order ID: ${widget.orderData['id']}"),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: Column(
        children: [
          // قسم الموقع (📍)
          Container(
            width: double.infinity, margin: const EdgeInsets.all(15), padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 10),
              Text(widget.orderData['locationName'], style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ),
          Expanded(
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35))),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- إرجاع بيانات الزبون (Customer Details) --- [34، 43]
                    const Text("👤 Customer Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildInfoRow("Name", widget.orderData['customer']),
                    _buildInfoRow("Phone", widget.orderData['customerPhone']),

                    const Divider(height: 40),

                    // --- إرجاع قائمة الأصناف (Items List) --- [1]
                    const Text("🍔 Ordered Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...List.generate(
                      widget.orderData['items'].length,
                          (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(children: [
                          const Icon(Icons.fiber_manual_record, size: 10, color: Colors.orange),
                          const SizedBox(width: 10),
                          Text(widget.orderData['items'][index], style: const TextStyle(fontSize: 16)),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 40),
                    // زر الحالات التفاعلي
                    SizedBox(
                      width: double.infinity, height: 60,
                      child: ElevatedButton(
                        onPressed: currentStatus == "delivered" ? null : updateStatus,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: Text(_getBtnText(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("$label: $value", style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }

  String _getBtnText() {
    if (currentStatus == "accepted") return "Confirm Pickup at Restaurant";
    if (currentStatus == "picked up") return "Start Driving to Customer";
    if (currentStatus == "on the way") return "Confirm Order Delivered";
    return "Mission Accomplished ✅";
  }
}
