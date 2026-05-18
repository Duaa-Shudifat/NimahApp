import 'package:flutter/material.dart';
import '../../language/app_strings.dart';
import 'OnBoardingWidget.dart';
import 'onboarding_a_screen.dart';
import 'onboarding_c_screen.dart';

class OnboardingBScreen extends StatelessWidget {
  const OnboardingBScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      image: 'assets/images/food_2.png',
      icon: 'assets/icons/card.svg',
      title: AppStrings.easyPayment1,
      description: AppStrings.easyPaymentDesc1,
      buttonText: AppStrings.next,
      backPage: const OnboardingAScreen(),
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingCScreen()),
        );
      },
    );
  }
}