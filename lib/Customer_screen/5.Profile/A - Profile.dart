import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart'; // أضفنا هاد
import 'package:cloud_firestore/cloud_firestore.dart'; // وأضفنا هاد
import '../../language/app_strings.dart';
import '../1.Launch/launch_welcome_screen.dart';
import 'I - My profile.dart';
import 'J - Delivery Adress.dart';
import 'L - Payment Methods.dart';
import 'M - Add Card.dart';
import 'N - Contact Us.dart';
import 'O - Help & FAQs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. الحصول على الـ User الحالي من Firebase
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
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
          // 2. استخدام StreamBuilder لجلب البيانات الحقيقية
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('CUSTOMERS') // تأكدي إن الكولكشن نفس اللي بالـ SignUp
                .doc(currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              // إذا ما في بيانات (مثلاً مستخدم مش زبون أو لسا ما تخزن)
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return _buildHeader("Guest User", "No Email", null);
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String name = userData['name'] ?? "No Name";
              String email = userData['email'] ?? "No Email";
              String? logoUrl = userData['logoUrl']; // إذا كان بروفايدر مثلاً

              return _buildHeader(name, email, logoUrl);
            },
          ),

          const SizedBox(height: 20),

          // ===== ITEMS =====
          buildItem(context, 'assets/icons/icon_p_2.svg', AppStrings.myProfile, const MyProfileScreen()),
          buildItem(context, 'assets/icons/icon_p_3.svg', AppStrings.deliveryAddress, const DeliveryAddressScreen()),
          buildItem(context, 'assets/icons/icon_p_4.svg', AppStrings.paymentMethods, const PaymentMethodsScreen()),
          buildItem(context, 'assets/icons/icon_p_5.svg', AppStrings.contactUs, const ContactUsScreen()),
          buildItem(context, 'assets/icons/icon_p_6.svg', AppStrings.helpFaq, const HelpFaqScreen()),

          const Spacer(),

          // زر تسجيل الخروج
          buildItem(context, 'assets/icons/icon_p_8.svg', AppStrings.logout, const LaunchWelcomeScreen()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء الهيدر (عشان الكود يكون أنظف)
  Widget _buildHeader(String name, String email, String? imageUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
              ? NetworkImage(imageUrl) as ImageProvider
              : const AssetImage('assets/images/profile_photo.png'),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            Text(
              email,
              style: const TextStyle(fontSize: 12, color: Colors.brown),
            ),
          ],
        ),
      ],
    );
  }

  // ===== ITEM WITH NAVIGATION (نفس الكود تبعك) =====
  Widget buildItem(BuildContext context, String iconPath, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () async {
          if (title == AppStrings.logout) {
            await FirebaseAuth.instance.signOut();
          }
          if (page is MyProfileScreen) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            Navigator.pop(context); // ✅
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          }
        },
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Center(child: SvgPicture.asset(iconPath, width: 20, height: 20)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.deepOrange, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}