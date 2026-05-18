import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordSettingsScreen extends StatefulWidget {
  const PasswordSettingsScreen({super.key});

  @override
  State<PasswordSettingsScreen> createState() => _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState extends State<PasswordSettingsScreen> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool showCurrent = true;
  bool showNew = true;
  bool showConfirm = true;
  bool _isLoading = false;

  Future<void> _changePassword() async {
    final current = _currentController.text.trim();
    final newPass = _newController.text.trim();
    final confirm = _confirmController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showMsg("Please fill all fields ⚠️", Colors.orange);
      return;
    }

    if (newPass != confirm) {
      _showMsg("New passwords don't match ❌", Colors.red);
      return;
    }

    // ✅ تحقق من طول وكلمات المرور المعقدة
    final passwordRegEx = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*]).{8,}$');
    if (!passwordRegEx.hasMatch(newPass)) {
      _showMsg(
        "Password should be at least 8 chars, include upper, lower, number & symbol ⚠️",
        Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email!;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: current,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass);

      _showMsg("Password changed successfully ✅", Colors.green);

      _currentController.clear();
      _newController.clear();
      _confirmController.clear();

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showMsg("Current password is incorrect ❌", Colors.red);
      } else {
        _showMsg("Error: ${e.message}", Colors.red);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Positioned(
            top: 35,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              const Text(
                "Password Setting",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text("Current Password",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _currentController,
                        obscure: showCurrent,
                        onToggle: () =>
                            setState(() => showCurrent = !showCurrent),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?",
                              style: TextStyle(color: Colors.amber)),
                        ),
                      ),

                      const Text("New Password",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _newController,
                        obscure: showNew,
                        onToggle: () => setState(() => showNew = !showNew),
                      ),

                      const SizedBox(height: 20),

                      const Text("Confirm New Password",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _confirmController,
                        obscure: showConfirm,
                        onToggle: () =>
                            setState(() => showConfirm = !showConfirm),
                      ),

                      const Spacer(),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding:
                            const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _isLoading ? null : _changePassword,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            "Change Password",
                            style: TextStyle(
                                color: Colors.white, fontSize: 16),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5CB58),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.brown,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}