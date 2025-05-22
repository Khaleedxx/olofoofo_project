import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/chat_models.dart';
import 'modules/splash_screen.dart';
import 'modules/onboarding_screen1.dart';
import 'modules/onboarding_screen2.dart';
import 'modules/onboarding_screen3.dart';
import 'modules/signup_screen.dart';
import 'modules/information_screen.dart';
import 'modules/personal_information_screen.dart';
import 'modules/welcome_screen.dart';
import 'modules/sign_in_screen.dart';
import 'modules/forgot_password_screen.dart';
import 'modules/otp_screen.dart';
import 'modules/new_password_screen.dart';
import 'modules/add_status_screen.dart';
import 'modules/post_comments_screen.dart';
import 'modules/notifications_screen.dart';
import 'modules/chat_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
        '/sign_in': (context) => SignInScreen(),
        '/forgot_password': (context) => ForgotPasswordScreen(),
        '/otp': (context) => OtpScreen(),
        '/new_password': (context) => NewPasswordScreen(),
        '/add_status': (context) => AddStatusScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/post_comments': (context) => PostCommentsScreen(),
        '/chat': (context) => ChatScreen(
              currentUserId:
                  'current_user_id', // You'll need to pass the actual user ID
              otherUser: ChatUser(
                id: 'other_user_id', // You'll need to pass the actual other user ID
                name: 'Other User', // You'll need to pass the actual user name
                profileImage:
                    null, // You'll need to pass the actual profile image URL if available
              ),
            ),
      },
    );
  }
}
