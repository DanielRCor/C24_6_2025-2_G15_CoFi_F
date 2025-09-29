import 'package:flutter/material.dart';
import '../onboarding/onboarding_template.dart';

class Onboarding2View extends StatelessWidget {
  const Onboarding2View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OnboardingTemplate(
      imagePath: 'assets/images/onboarding2.png',
      title: 'Administra tus gastos fácilmente',
      description: 'Registra tus ingresos y gastos para mantener un control financiero claro',
      nextRoute: '/onboarding3',
    );
  }
}
