import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../4.Home Page/MyOrdersBar.dart';

class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  List<Map<String, dynamic>> notifications = [];

  void removeNotification(Map<String, dynamic> data) {
    setState(() {
      notifications.remove(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    print("PANEL UID = $uid");

    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF1CC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(Icons.notifications, color: Colors.deepOrange),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  Text(
                    "Your latest updates",
                    style: TextStyle(fontSize: 12, color: Colors.brown),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('USER_NOTIFICATIONS')
                  .where('userId', isEqualTo: uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                notifications = snapshot.data!.docs
                    .map((doc) => {...(doc.data() as Map<String, dynamic>), 'docId': doc.id})
                    .toList();

                if (notifications.isEmpty) {
                  return const Center(
                    child: Text(
                      "No notifications",
                      style: TextStyle(color: Colors.brown),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final data = notifications[index];
                    return buildItem(context, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget buildItem(BuildContext context, Map<String, dynamic> data) {
    final title = data["title"] ?? "";
    final docId = data["docId"];
    final type = data["type"] ?? "";
    final orderId = data["orderId"] ?? "";

    return InkWell(
      onTap: () async {
        if (type == "delivery" && orderId.toString().isNotEmpty) {
          if (docId != null) {
            await FirebaseFirestore.instance
                .collection('USER_NOTIFICATIONS')
                .doc(docId)
                .update({'isRead': true});
          }
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ActiveOrdersEmptyScreen(initialTab: 1),
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/dish.svg",
                  width: 22,
                  height: 22,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () async {
                if (docId != null) {
                  await FirebaseFirestore.instance
                      .collection('USER_NOTIFICATIONS')
                      .doc(docId)
                      .delete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}