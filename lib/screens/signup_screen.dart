import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'citizen'; // Default role

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedRole,
              items: [
                DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                DropdownMenuItem(value: 'advertiser', child: Text('Advertiser')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await authProvider.signUpWithRole(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                  role: _selectedRole,
                );
                if (result != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                } else {
                  Navigator.pop(context); // Go back to login screen
                }
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
