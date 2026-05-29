import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false; // Tracks if the email was successfully sent

  // Eco-Minimalism Palette
  final Color bgColor = const Color(0xFFF4F7F5);
  final Color primaryGreen = const Color(0xFF2D6A4F);
  final Color charcoal = const Color(0xFF1A1A1A);

  // Simulated Backend Call (You will connect this to AuthProvider later)
  void _submitResetRequest() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Replace with actual Provider call: await Provider.of<AuthProvider>(context, listen: false).requestPasswordReset(email);
    await Future.delayed(const Duration(seconds: 2)); 

    setState(() {
      _isLoading = false;
      _isSent = true;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: charcoal),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded, 
                  color: primaryGreen, 
                  size: 40
                ),
              ),
              const SizedBox(height: 24),
              
              // Text Content
              Text(
                _isSent ? 'Check your mail' : 'Reset Password',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: charcoal, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),
              Text(
                _isSent 
                    ? 'We have sent password recovery instructions to your email. Please check your inbox and spam folder.'
                    : 'Enter the email associated with your EcoTracker account and we will send you a link to reset your password.',
                style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
              ),
              const SizedBox(height: 40),

              // Dynamic Form / Success State
              if (!_isSent) ...[
                // Email Text Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'name@example.com',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submitResetRequest,
                    child: _isLoading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ] else ...[
                // Success State - Return to Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryGreen, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context), // Go back to login screen
                    child: Text('Return to Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}