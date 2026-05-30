import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            "Drivers",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tab("Requests", 0, Colors.deepOrange),
              const SizedBox(width: 40),
              _tab("Approved", 1, Colors.green),
            ],
          ),
          const SizedBox(height: 10),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('DRIVERS')
                    .where('VerificationStatus',
                    isEqualTo: selectedIndex == 0 ? 'pending' : 'accepted')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        selectedIndex == 0
                            ? "No pending requests"
                            : "No approved drivers",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildDriver(doc.id, data);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String title, int index, Color activeColor) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: selectedIndex == index ? activeColor : Colors.brown,
            ),
          ),
          if (selectedIndex == index)
            Container(height: 3, width: 80, color: activeColor),
        ],
      ),
    );
  }

  Widget _buildDriver(String docId, Map<String, dynamic> d) {
    final bool isBlocked = d['blocked'] ?? false;
    final String status = d['VerificationStatus'] ?? 'pending';
    final String name = d['name'] ?? 'Unknown';
    final String email = d['email'] ?? '';
    final String phone = d['phone'] ?? '';
    final String carModel = d['carModel'] ?? '';
    final String carPlate = d['carPlate'] ?? '';
    final String carYear = d['carYear'] ?? '';
    final String vehicleType = d['vehicleType'] ?? '';
    final String city = d['city'] ?? '';
    final String driverLicense = d['driverLicense'] ?? '';
    final String experience = d['experience'] ?? '';
    final String logoUrl = d['logoUrl'] ?? '';
    final String orders = d['orders']?.toString() ?? '0';
    final String earnings = d['earnings'] ?? '0 JD';
    final String rating = d['rating']?.toString() ?? '0';

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                if (logoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      logoUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.person, size: 40),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isBlocked
                        ? Colors.red
                        : (status == 'accepted'
                        ? Colors.green
                        : Colors.orange),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isBlocked ? "BLOCKED" : status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(email),
            Text("📱 $phone"),
            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.directions_car, size: 16, color: Colors.blue),
                const SizedBox(width: 5),
                Text("$vehicleType - $carModel ($carYear) | $carPlate"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 5),
                Text(city),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.badge, size: 16, color: Colors.purple),
                const SizedBox(width: 5),
                Text("License: $driverLicense | Exp: $experience yrs"),
              ],
            ),

            if (status == 'accepted') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16),
                  const SizedBox(width: 5),
                  Text("Orders: $orders"),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.green),
                  const SizedBox(width: 5),
                  Text("Earnings: $earnings",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.orange),
                  const SizedBox(width: 5),
                  Text("Rating: $rating / 100"),
                ],
              ),
            ],

            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'pending')
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('DRIVERS')
                          .doc(docId)
                          .update({
                        'VerificationStatus': 'accepted',
                        'hasSeenAcceptedScreen': false,
                        'rejectionReason': null,
                      });
                    },
                  ),

                if (status == 'pending')
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      final reasonController = TextEditingController();
                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Rejection Reason"),
                          content: TextField(
                            controller: reasonController,
                            decoration: const InputDecoration(
                              hintText: "Enter reason...",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('DRIVERS')
                                    .doc(docId)
                                    .update({
                                  'VerificationStatus': 'rejected',
                                  'rejectionReason': reasonController.text.trim(),
                                  'hasSeenAcceptedScreen': false,
                                });
                                Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text("Reject",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                IconButton(
                  icon: Icon(
                    isBlocked ? Icons.lock_open : Icons.block,
                    color: Colors.orange,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('DRIVERS')
                        .doc(docId)
                        .update({'blocked': !isBlocked});
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}