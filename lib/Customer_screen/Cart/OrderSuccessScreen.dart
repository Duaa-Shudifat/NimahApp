import 'package:flutter/material.dart';
import '../4.Home Page/HomePage.dart';
import 'DeliveryTime.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId; // ✅ أضف هاي
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // ✅ أمان
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DeliveryTimeScreen(
            orderId: widget.orderId, // ✅ مرره هون
          ),
        ),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 120, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Order Confirmed!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}