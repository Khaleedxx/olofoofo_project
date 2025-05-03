import 'package:flutter/material.dart';
import 'modules/splash_screen.dart';
import 'modules/onboarding_screen1.dart';
import 'modules/onboarding_screen2.dart';
import 'modules/onboarding_screen3.dart';
import 'modules/signup_screen.dart';
import 'modules/information_screen.dart';
import 'modules/personal_information_screen.dart';
import 'modules/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OFOFO App',
      theme: ThemeData(
        primaryColor: Color(0xFF006D77),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding1': (context) => OnboardingScreen1(),
        '/onboarding2': (context) => OnboardingScreen2(),
        '/onboarding3': (context) => OnboardingScreen3(),
        '/signup': (context) => SignupScreen(),
        '/information': (context) => InformationScreen(),
        '/personal_information': (context) => PersonalInformationScreen(),
        '/welcome': (context) => WelcomeScreen(),
      },
    );
  }
}
