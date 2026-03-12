import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ad_manager.dart';
import '../theme/colors.dart';
import 'guide_screen.dart';
import 'developer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showedPopup = false;

  final List<Widget> _screens = const [
    GuideScreen(),
    DeveloperScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_showedPopup) {
        _showedPopup = true;
        AdManager.instance.showStartupPopup();
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    final shown = await AdManager.instance.showExitInterstitial();
    if (!shown) {
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: AdropColors.white,
          indicatorColor: AdropColors.primary.withValues(alpha: 0.12),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Guide',
            ),
            NavigationDestination(
              icon: Icon(Icons.code_outlined),
              selectedIcon: Icon(Icons.code),
              label: 'Developer',
            ),
          ],
        ),
      ),
    );
  }
}
