import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Let's help recover your account"),
            const SizedBox(height: 30),

            // Username
            const TextField(decoration: InputDecoration(labelText: 'Username')),
            const SizedBox(height: 15),

            // Email
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 15),

            // Phone Number
            const TextField(
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 15),

            // Last remembered password
            const TextField(
              decoration: InputDecoration(
                labelText: 'Last Remembered password',
              ),
            ),
            const SizedBox(height: 30),

            // Button "Done"
            Center(
              child: SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/otp');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
