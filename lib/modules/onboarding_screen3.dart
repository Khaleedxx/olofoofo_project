import 'package:flutter/material.dart';

class OnboardingScreen3 extends StatelessWidget {
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
                      child: Image.asset('assets/avatar-3.png'),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Text(
                'Express yourself to the world',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Let your voice be heard on the internet through the OFOFO features on the App without restrictions',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Continue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006D77),
                  minimumSize: Size(double.infinity, 50),
                  foregroundColor: Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 60),
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
