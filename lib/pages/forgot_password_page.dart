import 'package:flutter/material.dart';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // App Logo
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png',
                        height: 40,
                        errorBuilder: (c, e, s) => const Icon(Icons.park,
                            color: Colors.green, size: 40)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Enviora',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E3E32),
                                fontFamily: 'Lisu Bosa')),
                        Text('Your route to a cleaner city',
                            style: TextStyle(
                                fontSize: 10, color: Color(0xFF556055))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              const Text('Forgot Password',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F))),
              const SizedBox(height: 8),
              const Text(
                  'Enter your registered mobile number below to receive an OTP',
                  style: TextStyle(fontSize: 16, color: Color(0xFF455A64))),
              const SizedBox(height: 32),
              const Text('Mobile Number',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Row(
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('+94',
                            style: TextStyle(
                                fontSize: 16, color: Colors.black87))),
                    Expanded(
                      child: TextField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: 'Enter your mobile number',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OtpVerificationPage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48702E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0),
                  child: const Text('Next',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios,
                      size: 16, color: Color(0xFF48702E)),
                  label: const Text('Back to Login',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF48702E))),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
