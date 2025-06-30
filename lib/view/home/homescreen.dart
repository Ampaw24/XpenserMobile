import 'package:expenser/core/utils/theme/colors.dart';
import 'package:expenser/view/convertors/currency_convertor.dart';
import 'package:expenser/view/convertors/textcalculator.dart' show TaxCalculatorScreen;
import 'package:expenser/view/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State provider for navigation
final navigationProvider = StateProvider<int>((ref) => 0);
// Animation provider for smooth transitions
final animationProvider = StateProvider<bool>((ref) => false);



class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _buildCurrentPage(currentIndex),
      ),
      bottomNavigationBar: _buildFloatingBottomNavBar(currentIndex),
    );
  }

  Widget _buildCurrentPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(key: ValueKey('home'));
      case 1:
        return const SettingsScreen(key: ValueKey('settings'));
      case 2:
        return const CurrencyConverterScreen(key: ValueKey('currency'));
      case 3:
        return const TaxCalculatorScreen(key: ValueKey('tax'));
      default:
        return const HomeScreen(key: ValueKey('home'));
    }
  }

  Widget _buildFloatingBottomNavBar(int currentIndex) {
    return Container(
      margin: const EdgeInsets.all(1),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(32),
        color: Colors.white,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home', currentIndex),
              _buildNavItem(
                1,
                Icons.settings_rounded,
                'Settings',
                currentIndex,
              ),
              _buildNavItem(
                2,
                Icons.currency_exchange_rounded,
                'Convert',
                currentIndex,
              ),
              _buildNavItem(3, Icons.calculate_rounded, 'Tax', currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int currentIndex,
  ) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (currentIndex != index) {
            ref.read(navigationProvider.notifier).state = index;
            _animationController.reset();
            _animationController.forward();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.ACCENT.withValues(alpha:0.15)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.ACCENT : Colors.grey[600],
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.PRIMARY : Colors.grey[600],
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome Home',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your financial tools at your fingertips',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.currency_exchange_rounded,
                        title: 'Currency Converter',
                        subtitle: 'Convert between currencies',
                        color: Colors.green,
                        context: context,
                      ),
                      _buildFeatureCard(
                        icon: Icons.calculate_rounded,
                        title: 'Tax Calculator',
                        subtitle: 'Calculate your taxes',
                        color: Colors.orange,
                        context: context,
                      ),
                      _buildFeatureCard(
                        icon: Icons.analytics_rounded,
                        title: 'Analytics',
                        subtitle: 'View your stats',
                        color: Colors.purple,
                        context: context,
                      ),
                      _buildFeatureCard(
                        icon: Icons.history_rounded,
                        title: 'History',
                        subtitle: 'Recent activities',
                        color: Colors.blue,
                        context: context,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}



