import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'citizen'; // Default role

  Future<void> _signUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.signUpWithRole(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      role: selectedRole,
    );
    if (!mounted) return;
    if (result != "success") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    } else {
      Navigator.pop(context); // Go back to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                DropdownMenuItem(value: 'advertiser', child: Text('Advertiser')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
