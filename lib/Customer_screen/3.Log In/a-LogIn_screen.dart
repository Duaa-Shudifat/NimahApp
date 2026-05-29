import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../Admin_screen/AdminHome.dart';
import '../../Driver_screen/driver_dashboard.dart';
import '../../Driver_screen/driver_verification_screen.dart';
import '../../Provider_screen/provider_varification_screen.dart';
import '../../language/app_strings.dart';
import '../1.Launch/launch_welcome_screen.dart';
import '../4.Home Page/HomePage.dart';
import '../4.Home Page/back_icon.dart';
import 'b-signup_screen.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordHidden = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    const String adminEmail = 'admin@nimah.com';
    const String adminPassword = 'admin123';

    if (_emailController.text.trim() == adminEmail &&
        _passwordController.text.trim() == adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHome()),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      final token = await FirebaseMessaging.instance.getToken();
      print("FCM TOKEN = $token");

      DocumentSnapshot customer = await FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(uid)
          .get();

      if (customer.exists) {
        if (token != null) {
          await FirebaseFirestore.instance
              .collection('CUSTOMERS')
              .doc(uid)
              .set({
            'fcmToken': token,
          }, SetOptions(merge: true));
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        return;
      }

      DocumentSnapshot provider = await FirebaseFirestore.instance
          .collection('FOOD_PROVIDERS')
          .doc(uid)
          .get();

      if (provider.exists) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProviderVerificationScreen(),
          ),
        );
        return;
      }

      DocumentSnapshot driver = await FirebaseFirestore.instance
          .collection('DRIVERS')
          .doc(uid)
          .get();

      if (driver.exists) {
        final driverData = driver.data() as Map<String, dynamic>;
        final bool isBlocked = driverData['blocked'] ?? false;

        if (isBlocked) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Your account has been blocked. Please contact support.',
              ),
              backgroundColor: Colors.red,
            ),
          );

          await FirebaseAuth.instance.signOut();
          return;
        }

        final String driverStatus =
            driverData['VerificationStatus'] ?? 'new';

        if (token != null) {
          await FirebaseFirestore.instance
              .collection('DRIVERS')
              .doc(uid)
              .set({
            'fcmToken': token,
          }, SetOptions(merge: true));

          print("Driver FCM token saved = $token");
        } else {
          print("Driver FCM token is null");
        }

        if (!mounted) return;

        if (driverStatus == 'accepted') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverDashboard(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverVerificationScreen(),
            ),
          );
        }

        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account not found. Please sign up.')),
      );
    } on FirebaseAuthException catch (e) {
      print("ERROR CODE: ${e.code}");

      String message;

      switch (e.code) {
        case 'user-not-found':
        case 'user-disabled':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Wrong password. Please try again.';
          break;

        case 'invalid-email':
          message = 'Invalid email format.';
          break;

        case 'invalid-credential':
          final emailExists =
          await _checkEmailInFirestore(_emailController.text.trim());

          message = emailExists
              ? 'Wrong password. Please try again.'
              : 'No account found with this email.';
          break;

        default:
          message = 'An error occurred. Please try again.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkEmailInFirestore(String email) async {
    final collections = ['CUSTOMERS', 'DRIVERS', 'FOOD_PROVIDERS'];

    for (String col in collections) {
      final query = await FirebaseFirestore.instance
          .collection(col)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
      AppStrings.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5CB58),
        body: Stack(
          children: [
            BackButtonPositioned(
              targetPage: const LaunchWelcomeScreen(),
            ),
            Column(
              children: [
                const SizedBox(height: 60),
                Text(
                  AppStrings.login,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          Center(
                            child: Text(
                              AppStrings.welcomeBack,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hint: Text(
                                AppStrings.email,
                                style: const TextStyle(color: Colors.brown),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5CB58),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: _passwordController,
                            obscureText: isPasswordHidden,
                            decoration: InputDecoration(
                              hint: Text(
                                AppStrings.password,
                                style: const TextStyle(color: Colors.brown),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5CB58),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.brown,
                                ),
                                onPressed: () => setState(
                                      () => isPasswordHidden = !isPasswordHidden,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const ForgetPasswordScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppStrings.forgetPassword,
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Center(
                            child: SizedBox(
                              height: 50,
                              width: 200,
                              child: _isLoading
                                  ? const Center(
                                child: CircularProgressIndicator(),
                              )
                                  : ElevatedButton(
                                onPressed: _loginUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.deepOrangeAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.login,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF3E9B5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppStrings.dontHaveAccount),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppStrings.signUp,
                                  style: const TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}