import 'package:expenser/core/constants/imageconstants.dart';
import 'package:expenser/models/onboarding_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingProvider = Provider<List<OnboardingModel>>((ref) => [
  OnboardingModel(
    title: "Track Every Expense",
    description:
        "Monitor all your spending in one place.\nCategorize expenses and stay within budget\nwith smart insights and analytics.",
    imagePath: Imageconstants.expensesImage,
  ),
  OnboardingModel(
    title: "Multi-Currency Support",
    description:
        "Convert currencies instantly with real-time\nexchange rates. Perfect for international\ntravelers and global spending tracking.",
    imagePath: Imageconstants.currencyConvertor,
  ),
  OnboardingModel(
    title: "Smart VAT Calculator",
    description:
        "Automatically calculate VAT and taxes\non your purchases. Generate detailed\nreports for business and personal use.",
    imagePath: Imageconstants.taxImage,
  ),
]);
