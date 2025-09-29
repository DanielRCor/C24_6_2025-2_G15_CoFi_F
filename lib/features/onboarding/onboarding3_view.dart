import 'package:flutter/material.dart';
import '../onboarding/onboarding_template.dart';

class Onboarding3View extends StatelessWidget {
  const Onboarding3View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OnboardingTemplate(
      imagePath: 'assets/images/onboarding3.png',
      title: 'Crea grupos y alcanza metas',
      description: 'Ahorra en equipo y logra tus objetivos compartidos con mayor facilidad',
      nextRoute: '/login',
    );
  }
}
