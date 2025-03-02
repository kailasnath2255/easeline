import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          dynamic userData = userDoc.data();

          if (userData is Map<String, dynamic>) {
            String role = userData['role'] ?? 'Unknown';
            _navigateBasedOnRole(role);
          } else {
            _showMessage("Unexpected data format.");
          }
        } else {
          _showMessage("User does not exist in the database.");
        }
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forgotPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage("Please enter your email address to reset your password.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage("Password reset link sent to $email.");
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'Admin':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'HOD':
        Navigator.pushReplacementNamed(context, '/hod');
        break;
      case 'Faculty':
        Navigator.pushReplacementNamed(context, '/faculty');
        break;
      case 'Student':
        Navigator.pushReplacementNamed(context, '/student');
        break;
      case 'Volunteer':
        Navigator.pushReplacementNamed(context, '/volunteer');
        break;
      default:
        _showMessage("Unknown role: $role. Contact admin.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Logo and App Name Section
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/app_logo.png', // Replace with your app logo
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'EaseLine',
                              style: TextStyle(
                                fontSize: 32.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Connecting Concerns - Delivering Solutions',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50.0),
                        // Login Form Section
                        Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                // Email Input
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: 16.0),
                                // Password Input with Toggle
                                TextField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock, color: Colors.blue),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                // Login Button
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : ElevatedButton(
                                  onPressed: _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 50),
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                // Forgot Password
                                TextButton(
                                  onPressed: _forgotPassword,
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        // Admin Login Note (Placed just below the login form)
                        Text(
                          "Note: Accounts are pre-registered by the admin. Contact the admin for any login issues.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer Section
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    // Contact Us Link
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/contactUs');
                      },
                      child: Text(
                        "Contact Us",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    // Copyright Notice
                    Text(
                      "© 2025 EaseLine. All rights reserved.",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
