import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with 50% opacity
          Opacity(
            opacity: 0.5,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcomecityimge.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Content
          SizedBox(
            width: double.infinity,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Logo and tagline
                      _buildHeader(),

                      const SizedBox(height: 40),

                      // Main image card
                      _buildImageCard(),

                      const SizedBox(height: 30),

                      // Title
                      const Text(
                        'Your Route to\nCleaner City',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF384132),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Join the movement for cleaner streets and smarter waste management',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF384132),
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Remove pagination dots here as requested
                      const SizedBox(height: 32),

                      // Get Started button
                      _buildGetStartedButton(context),

                      const SizedBox(height: 16),

                      // Login link
                      _buildLoginLink(context),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo icon
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/logo.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.park, size: 40, color: Colors.green),
          ),
        ),
  
            Text(
              'Your route to a cleaner city',
              style: TextStyle(fontSize: 10, color: Color(0xFF384132)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Replace this with your actual image
            Image.asset(
              'assets/images/welcomecityimge.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Placeholder if image is not found
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF81C784),
                        const Color(0xFF66BB6A),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.park, size: 80, color: Colors.white70),
                      SizedBox(height: 16),
                      Text(
                        'City Park Scene',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == 0 ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == 0
                ? const Color(0xFF66BB6A)
                : const Color(0xFFB2DFDB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to language selection screen
          Navigator.pushReplacementNamed(context, '/language');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF48702E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Get Started',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account? ',
          style: TextStyle(fontSize: 14, color: Color(0xFF384132)),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to register screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            );
          },
          child: const Text(
            'Register',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF384132),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
