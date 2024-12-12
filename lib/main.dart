import 'package:app/firebase_options.dart';
import 'package:app/home_screen.dart';
import 'package:app/pages/account_settings.dart';
import 'package:app/pages/add_children.dart';
import 'package:app/pages/description_page.dart';
import 'package:app/pages/editProfile.dart';
import 'package:app/pages/error_page.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/pages/schedulepage.dart';
import 'package:app/pages/therapist_appointment_view.dart';
import 'package:app/pages/therapist_profilepage.dart';
import 'package:app/pages/therapist_progresspage.dart';
import 'package:app/pages/welcome_screen.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/auth/login_screen.dart';
import 'package:app/auth/signup_screen.dart';
import 'package:app/provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final userProvider = UserProvider();
  await userProvider.initializeUser();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..initializeUser()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      initialRoute: '/welcomeScreen',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/homescreen': (context) => HomeScreen(),
        '/dashboard': (context) => HomePage(),
        '/addchildren': (context) => AddChildren(),
        '/settings': (context) => AccountSettings(),
        '/description': (context) => DescriptionPage(),
        '/therapisteditprofile': (context) => TherapistProfilePage(),
        '/editprofile': (context) => TherapistProfilePage(),
        '/welcomeScreen': (context) => WelcomeScreen(),
        '/progresspage': (context) => TherapistProgressPage(),
        '/schedulepage': (context) => SchedulePage(),
        '/therapistappointment': (context) => TherapistAppointmentView(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => Error404Screen());
      },
    );
  }
}
