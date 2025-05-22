import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color(0xFFD9EDF1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/avatar-2.png'),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Text(
                'Make new friends with ease',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Allowing you to make new Friends is our Number one priority.....',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/onboarding3');
                },
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006D77),
                  minimumSize: Size(double.infinity, 50),
                  foregroundColor: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Skip'),
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sign_in');
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(color: Color(0xFF006D77)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
