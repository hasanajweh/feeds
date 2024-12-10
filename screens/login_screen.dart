import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // To show a loading spinner during login

  Future<void> login() async {
    final url = Uri.parse('http://feeds.ppu.edu/api/login'); // API endpoint
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      // Sending POST request with email and password
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final responseBody = jsonDecode(response.body);
        if (responseBody['status'] == 'success') {
          // Extract session token and save it using SharedPreferences
          final sessionToken = responseBody['session_token'];
          final username = responseBody['username']; // Optional: username
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('auth_token', sessionToken);
          await prefs.setString('username', username); // Optional save

          print('Login successful. Token saved: $sessionToken');
          // Navigate to Feeds screen
          Navigator.pushNamed(context, '/feeds');
        } else {
          // Handle cases where the response indicates failure
          showError('Login failed: Invalid credentials.');
        }
      } else {
        // Handle server errors or non-200 responses
        showError('Login failed: ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle network or other errors
      showError('Network error: $error');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : login,
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text('Login'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
