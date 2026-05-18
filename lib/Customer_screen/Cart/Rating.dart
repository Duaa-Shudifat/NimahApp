import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nimah_app/Customer_screen/4.Home%20Page/HomePage.dart';
import '../4.Home Page/back_icon.dart';

class RatingScreen extends StatefulWidget {
  final String orderId;
  const RatingScreen({super.key, required this.orderId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int selectedRating = 0;
  bool _isSubmitting = false;
  final TextEditingController noteController = TextEditingController();

  // ⭐ STAR WIDGET
  Widget buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          selectedRating = index;
        });
      },
      icon: Icon(
        Icons.star,
        size: 35,
        color: index <= selectedRating ? Colors.orange : Colors.grey.shade300,
      ),
    );
  }

  // ❌ ERROR DIALOG
  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "Please select rating first ⭐",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ حفظ التقييم في Firestore
  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('ORDERS')
          .doc(widget.orderId)
          .update({
        'Rating': selectedRating,
        'Feedback': noteController.text.trim(),
      });

      if (!mounted) return;
      _showThankYouDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving rating: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSubmitting = false);
  }

  // ✅ THANK YOU DIALOG
  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 70),
                  const SizedBox(height: 10),
                  const Text(
                    "Thank You!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Rating: $selectedRating ⭐",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    child: const Text("Done", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          BackButtonPositioned(targetPage: const HomePage()),

          Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                "Rate Your Order",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      const Text(
                        "How was your experience?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ⭐ STARS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) => buildStar(index + 1)),
                      ),

                      const SizedBox(height: 30),

                      // 📝 NOTE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5CB58),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: noteController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Write your feedback...",
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ✅ BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                            if (selectedRating == 0) {
                              showErrorDialog();
                              return;
                            }
                            _submitRating();
                          },
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
}