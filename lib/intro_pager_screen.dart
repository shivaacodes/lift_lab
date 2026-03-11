import 'package:flutter/material.dart';
import 'package:lift_lab/services/haptics_service.dart';

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
      title: 'Ready to Build Momentum?',
      subtitle: 'Start with a guided setup in under two minutes.',
      imagePath: 'assets/onboarding_3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              HapticsService.selection();
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
            top: 56,
            right: 20,
            child: TextButton(
              onPressed: () {
                HapticsService.light();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Skip'),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index, colors),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(PageModel page, bool isLastPage) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
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
                color: colors.onSurface.withValues(alpha: 0.72),
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
        HapticsService.success();
        Navigator.of(context).pushReplacementNamed('/login');
      },
    );
  }

  Widget _buildDot(int index, ColorScheme colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? colors.primary
            : colors.onSurface.withValues(alpha: 0.28),
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
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double handleSize = 65.0;
        double slideRange = maxWidth - handleSize - 10;

        return Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              colors.primary.withValues(alpha: 0.08),
              colors.surface,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
          ),
          child: Stack(
            children: [
              Center(
                child: Opacity(
                  opacity: 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start!',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.east_rounded,
                        color: colors.onSurface,
                        size: 20,
                      ),
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
                      HapticsService.light();
                      setState(() => _position = 0);
                    }
                  },
                  child: Container(
                    width: handleSize,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.35),
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
      },
    );
  }
}
