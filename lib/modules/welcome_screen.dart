import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Central avatar with celebratory elements
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9EDF1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(Icons.person, size: 80, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Icon(
                      Icons.celebration,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 10,
                    child: Icon(Icons.star, color: Colors.amber, size: 24),
                  ),
                ],
              ),
              SizedBox(height: 40),
              // Small decorations around
              Wrap(
                spacing: 50,
                runSpacing: 50,
                children: List.generate(6, (index) {
                  return Container(
                    width: index % 3 == 0 ? 24 : 20,
                    height: index % 3 == 0 ? 24 : 20,
                    decoration: BoxDecoration(
                      color:
                          index % 2 == 0
                              ? Color(0xFF006D77)
                              : Colors.transparent,
                      shape:
                          index % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius:
                          index % 3 != 0 ? BorderRadius.circular(4) : null,
                    ),
                    child:
                        index % 5 == 0
                            ? Icon(
                              Icons.star,
                              color: Color(0xFF006D77),
                              size: 24,
                            )
                            : null,
                  );
                }),
              ),
              SizedBox(height: 40),
              Text(
                'Welcome',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the home screen or login
                  // For now, just reset to splash
                  Navigator.pushReplacementNamed(context, '/splash');
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
            ],
          ),
        ),
      ),
    );
  }
}
