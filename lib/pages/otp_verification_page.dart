import 'package:flutter/material.dart';
import 'change_password_page.dart';

class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

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
              const Text('Enter OTP',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF37474F))),
              const SizedBox(height: 8),
              const Text(
                  "we've sent a 4-digit code to your registered mobile number",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                    4,
                    (index) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300)),
                          child: const Center(
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                  counterText: "", border: InputBorder.none),
                            ),
                          ),
                        )),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code? ",
                      style: TextStyle(color: Colors.black)),
                  Text("Resend OTP",
                      style: TextStyle(color: Colors.green.shade600)),
                ],
              ),
              const SizedBox(height: 8),
              const Center(
                  child: Text("Resend available in 00:59",
                      style: TextStyle(color: Colors.black))),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48702E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0),
                  child: const Text('Verify',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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
