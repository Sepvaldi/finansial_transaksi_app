import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // lama fade in
      reverseDuration: const Duration(milliseconds: 600), // lama fade out
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // dipakai saat fade in
      reverseCurve: Curves.easeOut, // dipakai saat fade out
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _controller.forward(); // 1. fade in (2 dtk)
    await Future.delayed(const Duration(seconds: 2)); // 2. tahan (2 dtk)
    if (!mounted) return;
    await _controller.reverse(); // 3. fade out
    if (!mounted) return;

    // 4. pindah ke login dengan transisi fade
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/wave_atas.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            Positioned(
              bottom: -20,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/wave_bawah.png',
                fit: BoxFit.fitWidth,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', width: 150),
                  const SizedBox(height: 16),
                  const Text(
                    'WELCOME TO MBG\nMY BANK GUA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DaysOne',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
