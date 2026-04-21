import 'package:expenser/core/utils/theme/buttons.dart';
import 'package:expenser/viewmodels/onboarding_viewmodel.dart';
import 'package:expenser/viewmodels/settings_viewmodel.dart';
import 'package:expenser/views/onboarding/widgets/dot_indicator.dart';
import 'package:expenser/views/onboarding/widgets/onboard_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final demoData = ref.watch(onboardingProvider);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Expanded(
              flex: 14,
              child: PageView.builder(
                itemCount: demoData.length,
                onPageChanged: (value) => setState(() => currentPage = value),
                itemBuilder: (context, index) => OnboardContent(
                  illustration: demoData[index].imagePath,
                  title: demoData[index].title,
                  text: demoData[index].description,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                demoData.length,
                (index) => DotIndicator(isActive: index == currentPage),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
              child: CustomisedElevatedButton(
                text: "Get Started",
                onPressed: () async {
                  await ref
                      .read(settingsProvider.notifier)
                      .markOnboardingComplete();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
