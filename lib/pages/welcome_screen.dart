import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<void> checkUserLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    debugPrint('isLoggedIn value from SharedPreferences: $isLoggedIn');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/homescreen');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      checkUserLoginStatus();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Full white background
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 34,
                fontFamily: 'conf',
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(136, 0, 0, 0),
                fontStyle: FontStyle.italic,
                shadows: [
                  Shadow(
                    offset: Offset(1.5, 1.5), // Shadow offset
                    blurRadius: 3.0, // Shadow blur
                    color: Colors.grey, // Shadow color
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'to',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    'assets/images/decoration_images/vrlogo.jpg', // Replace with your image path
                    height: 58,
                    width: 58,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Auti',
                    style: const TextStyle(
                      fontSize: 28,
                      fontFamily: 'conf',
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 95, 103, 107),
                    ),
                    children: [
                      TextSpan(
                        text: 'Verse',
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: 'conf',
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              offset: Offset(1.5, 1.5),
                              blurRadius: 3.0,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(flex: 1),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/on_boarding_images/onboard.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'An immersive VR environment to help children with autism learn and grow.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'conf',
                fontSize: 12,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Track learning milestones and monitor activities seamlessly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'conf',
                fontSize: 12,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 2),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.transparent, width: 2),
                backgroundColor: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'conf',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.blue,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
