import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait 3.5 seconds to show animation, then go to Home
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive sizing
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Lottie Animation
            SizedBox(
              height: size.width * 0.6, // Responsive size (60% of screen width)
              width: size.width * 0.6,
              child: Lottie.asset(
                'assets/animations/splash_anim.json',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // 2. App Name "Voxa"
            Text(
              "Voxa",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                letterSpacing: 1.5,
                fontSize: 32,
              ),
            ),

            const SizedBox(height: 10),

            // 3. Tagline
            Text(
              "Your Voice. Your Notes.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}