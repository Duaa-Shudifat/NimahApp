import 'package:flutter/material.dart';
import 'package:nimah_app/Customer_screen/3.Log%20In/b-signup_screen.dart';

import '../../language/app_strings.dart';
import '../2.On Boarding/onboarding_a_screen.dart';
import '../3.Log In/a-LogIn_screen.dart';

class LaunchWelcomeScreen extends StatefulWidget {
  const LaunchWelcomeScreen({super.key});

  @override
  State<LaunchWelcomeScreen> createState() => _LaunchWelcomeScreenState();
}

class _LaunchWelcomeScreenState extends State<LaunchWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: AppStrings.isArabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5CB58),
          body: Stack(
            children: [

          Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5CB58),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Image.asset(
                        'assets/images/nimah_logo1.png',
                        width: 500,
                      ),

                      const SizedBox(height: 5),

                      SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3E9B5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: Text(
                            AppStrings.login,
                            style: const TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3E9B5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: Text(
                            AppStrings.signUp,
                            style: const TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Positioned(
          //   top: 40,
          //   right: 10,
          //   child: IconButton(
          //     iconSize: 35,
          //     icon: const Icon(Icons.language),
          //     onPressed: () {
          //       setState(() {
          //         AppStrings.isArabic = !AppStrings.isArabic;
          //       });
          //     },
          //   ),
          // ),

        ],
      ),
    ));
  }
}