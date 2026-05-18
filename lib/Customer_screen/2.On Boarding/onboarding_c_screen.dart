import 'package:flutter/material.dart';
import 'package:nimah_app/Customer_screen/4.Home%20Page/HomePage.dart';
import '../../language/app_strings.dart';
import '../3.Log In/b-signup_screen.dart';
import 'OnBoardingWidget.dart';
import 'onboarding_b_screen.dart';

class OnboardingCScreen extends StatelessWidget {
  const OnboardingCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      image: 'assets/images/food_3.png',
      icon: 'assets/icons/driver.svg',
      title: AppStrings.fastDelivery3,
      description: AppStrings.fastDeliveryDesc3,
      buttonText: AppStrings.getStarted3,
      backPage: const OnboardingBScreen(),
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      },
    );
  }
}