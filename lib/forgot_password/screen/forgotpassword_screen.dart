import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../service/forgotpassword_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ForgotPasswordService _forgotPasswordService = ForgotPasswordService();
  bool _isLoading = false;

  void _resetPassword() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    final message = await _forgotPasswordService.sendPasswordResetEmail(email);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? "Unknown error")),
    );

    setState(() => _isLoading = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              "Enter your email to reset your password",
              style: TextStyle(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _emailController,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
             SizedBox(height: 20.h),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
