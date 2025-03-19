// lib/screens/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // State variables for username and password
  String username = '';
  String password = '';

  // Function to handle login
  void _handleLogin() {
    // Define valid credentials and their designations
    final validUsers = {
      'Divyanshoo': {'password': '1234', 'designation': 'Nurse'},
      'Kashish': {'password': '1234', 'designation': 'Doctor'},
    };

    if (validUsers.containsKey(username) &&
        validUsers[username]!['password'] == password) {
      // Navigate to the Dashboard screen and pass the username and designation
      Navigator.pushNamed(
        context,
        '/dashboard',
        arguments: {
          'user': username,
          'designation': validUsers[username]!['designation'],
        },
      );
    } else {
      // Show an alert for invalid login
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(
              fontFamily: 'FunnelDisplay', // Use FunnelDisplay for the title
              fontWeight: FontWeight.bold, // Use bold weight
            ),
          ),
          content: Text(
            'Invalid username or password',
            style: TextStyle(
              fontFamily: 'FunnelDisplay', // Use FunnelDisplay for the content
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'FunnelDisplay', // Use FunnelDisplay for the button
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Function to handle sign-up navigation
  void _handleSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/sencare-high-resolution-logo.png',
                  width: 150,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),

                // Username Input
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      fontFamily: 'FunnelDisplay', // Use FunnelDisplay for the label
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      username = value;
                    });
                  },
                ),
                SizedBox(height: 10),

                // Password Input
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      fontFamily: 'FunnelDisplay', // Use FunnelDisplay for the label
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                SizedBox(height: 10),

                // Forgot Password Text
                Text(
                  'Forgot Username or Password?',
                  style: TextStyle(
                    color: Colors.blue,
                    fontFamily: 'FunnelDisplay', // Use FunnelDisplay for the text
                  ),
                ),
                SizedBox(height: 20),

                // Sign In Button
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'FunnelDisplay', // Use FunnelDisplay for the button text
                      fontWeight: FontWeight.bold, // Use bold weight
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'FunnelDisplay', // Use FunnelDisplay for the button text
                      fontWeight: FontWeight.bold, // Use bold weight
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}