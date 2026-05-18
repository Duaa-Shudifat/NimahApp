import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FeedbackPage.dart';

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({super.key});

  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Text("Providers",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown)),
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
                    .collection('FOOD_PROVIDERS')
                    .where('VerificationStatus',
                    isEqualTo:
                    selectedIndex == 0 ? 'pending' : 'accepted')
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
                            : "No approved providers",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _buildProvider(doc.id, data);
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

  Widget _buildProvider(String docId, Map<String, dynamic> p) {
    final bool isBlocked = p['blocked'] ?? false;
    final String status = p['VerificationStatus'] ?? 'pending';
    final String name = p['name'] ?? 'Unknown';
    final String email = p['email'] ?? '';
    final String phone = p['phone'] ?? '';
    final String city = p['city'] ?? '';
    final String logoUrl = p['logoUrl'] ?? '';
    final String rejectionReason = p['rejectionReason'] ?? '';

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
                      const Icon(Icons.store, size: 40),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
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
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 5),
                Text(city),
              ],
            ),

            // سبب الرفض
            if (status == 'rejected' && rejectionReason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    "Rejection Reason: $rejectionReason",
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ),

            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                // قبول
                if (status == 'pending')
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('FOOD_PROVIDERS')
                          .doc(docId)
                          .update({'VerificationStatus': 'accepted'});
                    },
                  ),

                // رفض
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
                                    .collection('FOOD_PROVIDERS')
                                    .doc(docId)
                                    .update({
                                  'VerificationStatus': 'rejected',
                                  'rejectionReason':
                                  reasonController.text.trim(),
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

                // Reapply - للبروفايدر المرفوض
                if (status == 'rejected')
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.deepOrange),
                    tooltip: "Allow Reapply",
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('FOOD_PROVIDERS')
                          .doc(docId)
                          .update({
                        'VerificationStatus': 'new',
                        'rejectionReason': null,
                      });
                    },
                  ),

                // بلوك/ان بلوك
                IconButton(
                  icon: Icon(
                    isBlocked ? Icons.lock_open : Icons.block,
                    color: Colors.orange,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('FOOD_PROVIDERS')
                        .doc(docId)
                        .update({'blocked': !isBlocked});
                  },
                ),

                // فيدباك
                IconButton(
                  icon: const Icon(Icons.feedback, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FeedbackPage(providerName: name),
                      ),
                    );
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