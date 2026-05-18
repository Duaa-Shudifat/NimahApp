import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../1.Launch/launch_welcome_screen.dart';
import '../4.Home Page/SettingsBar.dart';
import '../4.Home Page/back_icon.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final passwordController = TextEditingController();
    bool isHidden = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Confirm your password"),
          content: TextField(
            controller: passwordController,
            obscureText: isHidden,
            decoration: InputDecoration(
              hintText: "Enter your password",
              filled: true,
              fillColor: const Color(0xFFF5CB58),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.brown,
                ),
                onPressed: () => setState(() => isHidden = !isHidden),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      String uid = user.uid;

      await FirebaseFirestore.instance.collection('CUSTOMERS').doc(uid).delete();
      await FirebaseFirestore.instance.collection('DRIVERS').doc(uid).delete();
      await FirebaseFirestore.instance.collection('FOOD_PROVIDERS').doc(uid).delete();

      await user.delete();

      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      _showSuccessDialog(context);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _showErrorSnackBar(context, "Wrong password. Please try again.");
      } else {
        _showErrorSnackBar(context, "Error: ${e.message}");
      }
    } catch (e) {
      _showErrorSnackBar(context, "Something went wrong: $e");
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Success"),
          ],
        ),
        content: const Text("Your account has been permanently deleted."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LaunchWelcomeScreen()),
                    (route) => false,
              );
            },
            child: const Text("OK", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showDeleteConfirmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE5E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 15),
              const Text(
                "Delete Account?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
              ),
              const SizedBox(height: 10),
              const Text(
                "This action is permanent and cannot be undone.\nAll your data will be removed permanently.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _handleDeleteAccount(context),
                      child: const Text("Delete", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
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
          BackButtonPositioned(
            targetPage: const SettingsScreen(),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Delete Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 90, color: Colors.red),
                      const SizedBox(height: 20),
                      const Text(
                        "We are sad to see you go \nDo you really want to delete your account?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.brown),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () => _showDeleteConfirmSheet(context),
                          child: const Text(
                            "Continue Delete",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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