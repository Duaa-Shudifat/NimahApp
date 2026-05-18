import 'package:flutter/material.dart';
import '../../language/app_strings.dart';import '../1.Launch/launch_welcome_screen.dart';

import 'OnBoardingWidget.dart';
import 'onboarding_b_screen.dart';

class OnboardingAScreen extends StatelessWidget {
  const OnboardingAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      image: 'assets/images/food_1.png',
      icon: 'assets/icons/order.svg',
      title: AppStrings.orderFood1,
      description: AppStrings.orderDesc1,
      buttonText: AppStrings.next,
      backPage: const LaunchWelcomeScreen(),
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingBScreen()),
        );
      },
    );
  }
}