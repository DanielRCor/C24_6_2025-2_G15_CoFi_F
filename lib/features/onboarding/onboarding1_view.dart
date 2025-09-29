import 'package:flutter/material.dart';
import '../onboarding/onboarding_template.dart';

class Onboarding1View extends StatelessWidget {
  const Onboarding1View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OnboardingTemplate(
      imagePath: 'assets/images/onboarding1.png',
      title: 'Cumple tus metas de ahorro',
      description: 'Define objetivos financieros y visualiza tu progreso hasta alcanzarlos',
      nextRoute: '/onboarding2',
    );
  }
}
