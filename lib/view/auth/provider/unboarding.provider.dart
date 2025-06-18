import 'package:expenser/view/auth/model/unboarding_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Demo data for our Onboarding screen
List<OnboardingModel> demoData = [
  OnboardingModel(
    title: "Track Every Expense",
    description:
        "Monitor all your spending in one place.\nCategorize expenses and stay within budget\nwith smart insights and analytics.",
    imagePath: "",
  ),
  OnboardingModel(
    title: "Multi-Currency Support",
    description:
        "Convert currencies instantly with real-time\nexchange rates. Perfect for international\ntravelers and global spending tracking.",
    imagePath: "",
  ),
  OnboardingModel(
    title: "Smart VAT Calculator",
    description:
        "Automatically calculate VAT and taxes\non your purchases. Generate detailed\nreports for business and personal use.",
    imagePath: "",
  ),
];


// Provider that exposes the demoData list as a read-only value
final onboardingListProvider = Provider<List<OnboardingModel>>((ref) => demoData);
