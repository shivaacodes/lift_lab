import 'package:flutter/material.dart';
import 'package:lift_lab/theme_provider.dart';
import 'package:lift_lab/main_navigation_shell.dart';

class PageModel {
  final String title;
  final String subtitle;
  final String imagePath;

  PageModel({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class IntroPagerScreen extends StatefulWidget {
  const IntroPagerScreen({super.key});

  @override
  State<IntroPagerScreen> createState() => _IntroPagerScreenState();
}

class _IntroPagerScreenState extends State<IntroPagerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<PageModel> _pages = [
    PageModel(
      title: 'Track Your Progress',
      subtitle: 'Monitor your workouts and diet with ease.',
      imagePath: 'assets/onboarding_1.png',
    ),
    PageModel(
      title: 'Personalized Plans',
      subtitle: 'Get routines tailored to your goals.',
      imagePath: 'assets/onboarding_2.png',
    ),
    PageModel(
      title: 'Welcome to Fitness app!',
      subtitle: 'Your journey to a healthier lifestyle starts here.',
      imagePath: 'assets/onboarding_3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], index == _pages.length - 1);
            },
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(PageModel page, bool isLastPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textColor.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          const Spacer(),
          Hero(
            tag: 'illustration',
            child: Image.asset(
              page.imagePath,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          if (isLastPage)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: _buildStartButton(),
            )
          else
            const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SwipeToStart(
      onSwipeCompleted: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationShell()),
        );
      },
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppTheme.primaryColor : Colors.grey[700],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class SwipeToStart extends StatefulWidget {
  final VoidCallback onSwipeCompleted;
  const SwipeToStart({super.key, required this.onSwipeCompleted});

  @override
  State<SwipeToStart> createState() => _SwipeToStartState();
}

class _SwipeToStartState extends State<SwipeToStart> {
  double _position = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double handleSize = 65.0;
      double slideRange = maxWidth - handleSize - 10;

      return Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: AppTheme.fabColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            Center(
              child: Opacity(
                opacity: 0.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Start!',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_double_arrow_right_rounded, color: AppTheme.textColor, size: 20),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 5 + _position,
              top: 5,
              bottom: 5,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position += details.delta.dx;
                    if (_position < 0) _position = 0;
                    if (_position > slideRange) _position = slideRange;
                  });
                },
                onPanEnd: (details) {
                  if (_position >= slideRange * 0.9) {
                    setState(() => _position = slideRange);
                    widget.onSwipeCompleted();
                  } else {
                    setState(() => _position = 0);
                  }
                },
                child: Container(
                  width: handleSize,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '>>>',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
