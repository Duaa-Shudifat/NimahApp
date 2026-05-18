import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // إضافة المكتبة للربط
import '../../language/app_strings.dart'; // لترجمة العنوان

class FeedbackPage extends StatelessWidget {
  final String providerName;

  const FeedbackPage({super.key, required this.providerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),

      body: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            children: [
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.brown),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Center(
                  child: Text(
                    AppStrings.feedbackTitle, // استخدام النص المترجم "Customer Feedback" [1]
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              providerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
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

              // تعديل الـ ListView لتصبح StreamBuilder لجلب البيانات الحية [64، 69]
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('RATINGS')
                    .where('providerName', isEqualTo: providerName) // تصفية التقييمات حسب المزود [1]
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No feedback yet"));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return _feedbackCard(
                          data['comment'] ?? "",
                          data['ratingValue'] ?? 0,
                          data['driverName'] ?? "Unknown"
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard(String comment, int rating, String driverName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5CB58).withOpacity(0.25),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. عرض النجوم
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
              ),

              // 2. إظهار اسم السائق لكي يكتمل ربط التقييم بالأطراف الثلاثة [1]
              Text(
                driverName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            comment,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }}