import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingTemplate extends StatelessWidget {
  final String image;
  final String icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onNext;
  final Widget backPage;

  const OnboardingTemplate({
    super.key,
    required this.image,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onNext,
    required this.backPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [

          // 🔥 TOP IMAGE
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            width: double.infinity,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),

          // 🔙 BACK BUTTON
          Positioned(
            top: 40,
            left: 15,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.deepOrange,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => backPage),
                );
              },
            ),
          ),

          // 🟡 BOTTOM BOX
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(60, 40, 60, 80),
              decoration: const BoxDecoration(
                color: Color(0xFFF5CB58),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  SvgPicture.asset(
                    icon,
                    width: 60,
                    height: 60,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.brown,
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3E9B5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.deepOrange,
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
    );
  }
}