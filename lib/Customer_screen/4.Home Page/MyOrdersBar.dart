import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../language/app_strings.dart';
import 'BottomNavBar.dart';
import 'HomePage.dart';
import 'back_icon.dart';
import '../Cart/Rating.dart';

class ActiveOrdersEmptyScreen extends StatefulWidget {
  final int initialTab;
  const ActiveOrdersEmptyScreen({super.key, this.initialTab = 0});

  @override
  State<ActiveOrdersEmptyScreen> createState() =>
      _ActiveOrdersEmptyScreenState();
}

class _ActiveOrdersEmptyScreenState extends State<ActiveOrdersEmptyScreen> {
  late int selectedTab;

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
  }
  List<String> _getStatusFilter() {
    if (selectedTab == 0) return ["Pending", "Accepted", "Preparing", "On the Way"];
    if (selectedTab == 1) return ["Delivered"];
    return ["Cancelled", "Canceled"];
  }

  String _getEmptyMessage() {
    if (selectedTab == 0) return "No active orders";
    if (selectedTab == 1) return "No completed orders";
    return "No cancelled orders";
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Directionality(
      textDirection:
      AppStrings.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5CB58),
        body: Stack(
          children: [
            BackButtonPositioned(targetPage: const HomePage()),
            Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  AppStrings.myOrders,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
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
                    child: Column(
                      children: [
                        // TABS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _tabButton("Active", 0),
                            const SizedBox(width: 10),
                            _tabButton("Completed", 1),
                            const SizedBox(width: 10),
                            _tabButton("Canceled", 2),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('ORDERS')
                                .where('Customer_ID', isEqualTo: uid)
                                .where('Status', whereIn: _getStatusFilter())
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.deepOrange,
                                  ),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.receipt_long_outlined,
                                          size: 70,
                                          color: Colors.grey.shade300),
                                      const SizedBox(height: 16),
                                      Text(
                                        _getEmptyMessage(),
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final orders = snapshot.data!.docs;

                              return ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  final data = orders[index].data()
                                  as Map<String, dynamic>;
                                  final docId = orders[index].id;
                                  return _orderCard(data, docId);
                                },
                              );
                            },
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
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }

  // ===== ORDER CARD =====
  Widget _orderCard(Map<String, dynamic> data, String docId) {
    final status = data["Status"] ?? "Pending";
    final items = data["Items"] as List<dynamic>? ?? [];
    final total = (data["Total_Price"] ?? 0).toDouble();
    final note = data["Notes"] ?? "";
    final providerName = data["Provider_Name"] ?? data["Provider_ID"] ?? "";
    final providerImage = data["Provider_Image"] ?? "";
    final hasRated = data["Rating"] != null;

    Color statusColor;
    switch (status) {
      case "Pending": statusColor = Colors.orange; break;
      case "Accepted": statusColor = Colors.blue; break;
      case "Preparing": statusColor = Colors.deepOrange; break;
      case "On the Way": statusColor = Colors.purple; break;
      case "Delivered": statusColor = Colors.green; break;
      default: statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: providerImage.startsWith("http")
                    ? Image.network(
                  providerImage,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.fastfood,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
                )
                    : const Icon(
                  Icons.fastfood,
                  color: Colors.deepOrange,
                  size: 40,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${items.length} item(s)",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${total.toStringAsFixed(2)} JD",
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("📝 $note",
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],

          if (status == "Pending") ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _showCancelDialog(docId),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],

          if (status == "Delivered") ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: hasRated
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "Rated: ${data['Rating']} ⭐",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
                  : ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RatingScreen(orderId: docId),
                    ),
                  );
                },
                icon: const Icon(Icons.star_border,
                    color: Colors.white, size: 18),
                label: const Text(
                  "Rate Order",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelDialog(String docId) {
    final reasons = [
      "Changed my mind",
      "Ordered by mistake",
      "Too late delivery",
      "Other",
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Cancel Order"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((reason) {
            return ListTile(
              title: Text(reason),
              onTap: () async {
                await FirebaseFirestore.instance
                    .collection('ORDERS')
                    .doc(docId)
                    .update({
                  "Status": "Canceled",
                  "cancelReason": reason,
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
            isSelected ? Colors.deepOrange : Colors.orange.shade200,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.deepOrange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}