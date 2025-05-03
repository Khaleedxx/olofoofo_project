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
                    // Central avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFFD9EDF1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.face, size: 60, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Small avatars around
                    Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                index % 2 == 0
                                    ? Color(0xFF006D77)
                                    : Color(0xFFD9EDF1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 20,
                              color: Colors.grey[300],
                            ),
                          ),
                        );
                      }),
                    ),
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
                    onPressed: () {},
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
