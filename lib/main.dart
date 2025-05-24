import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'modules/home_screen.dart';
import 'modules/profile_screen.dart';
import 'modules/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase is ready to use');
  } catch (e) {
    print('Could not initialize Firebase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OFOFO App',
      theme: ThemeData(
        primaryColor: Color(0xFF006D77),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
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
        '/home': (context) => HomeScreen(),
        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return ProfileScreen(userId: args);
        },
        '/search': (context) => SearchScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUserId: args?['currentUserId'] ??
                  FirebaseAuth.instance.currentUser?.uid ??
                  'default_user_id',
              otherUser: args?['otherUser'] ??
                  ChatUser(
                    id: 'default_id',
                    name: 'User',
                    profileImage: null,
                  ),
            ),
          );
        }
        return null;
      },
    );
  }
}
