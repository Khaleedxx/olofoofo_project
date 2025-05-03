import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String selectedCountry = "Nigeria";
  String selectedCountryCode = "+234";

  final List<Map<String, dynamic>> countries = [
    {"name": "Ghana", "code": "+233"},
    {"name": "Cameroon", "code": "+237"},
    {"name": "Niger", "code": "+227"},
    {"name": "Nigeria", "code": "+234"},
    {"name": "America", "code": "+1"},
    {"name": "Canada", "code": "+1"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 20),
              Text(
                'Phone',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Enter your phone number',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 20,
                      color: Colors.green,
                      child: Center(
                        child: Text('🇳🇬', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      selectedCountryCode,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone number',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    return ListTile(
                      leading: Text(
                        country["name"] == "Nigeria" ? '🇳🇬' : '🏳️',
                        style: TextStyle(fontSize: 24),
                      ),
                      title: Text(country["name"]),
                      trailing: Text(country["code"]),
                      selected: selectedCountry == country["name"],
                      selectedTileColor: Color(0xFF006D77).withOpacity(0.1),
                      onTap: () {
                        setState(() {
                          selectedCountry = country["name"];
                          selectedCountryCode = country["code"];
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/information');
                },
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006D77),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
