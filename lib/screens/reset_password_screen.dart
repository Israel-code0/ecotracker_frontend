import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  // Eco-Minimalism Palette
  final Color bgColor = const Color(0xFFF4F7F5);
  final Color primaryGreen = const Color(0xFF2D6A4F);
  final Color charcoal = const Color(0xFF1A1A1A);

  void _submitNewPassword() async {
    if (_codeController.text.length != 6 || _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code and a valid password'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Connect to Provider -> AuthProvider.verifyAndReset(code, newPassword)
    await Future.delayed(const Duration(seconds: 2)); 

    setState(() => _isLoading = false);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password Reset Successful!'), backgroundColor: Colors.green),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // Sends them back to the very first Login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: charcoal)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: charcoal, letterSpacing: -0.5)),
              const SizedBox(height: 12),
              Text('Enter the 6-digit code sent to your email and choose a new secure password.', style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5)),
              const SizedBox(height: 40),

              // OTP Code Field
              _buildTextField(_codeController, '6-Digit Code', Icons.pin_outlined, false, TextInputType.number),
              const SizedBox(height: 20),

              // New Password Field
              _buildTextField(_passwordController, 'New Password', Icons.lock_outline, true, TextInputType.text),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _submitNewPassword,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Update Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper UI Widget
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword, TextInputType type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscureText,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}