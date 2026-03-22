import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/supervisor_auth_service.dart';

class SupervisorAuthGuard extends StatefulWidget {
  final Widget child;
  const SupervisorAuthGuard({Key? key, required this.child}) : super(key: key);

  @override
  State<SupervisorAuthGuard> createState() => _SupervisorAuthGuardState();
}

class _SupervisorAuthGuardState extends State<SupervisorAuthGuard> {
  final SupervisorAuthService _authService = SupervisorAuthService();
  bool? _isAuthorized;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isAuthorized = false);
      return;
    }

    bool isSup = await _authService.isSupervisor(user.uid);
    if (mounted) {
      setState(() => _isAuthorized = isSup);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthorized == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAuthorized!) {
      // If not authorized, redirect to supervisor login or show error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/supervisor-login');
      });
      return const Scaffold();
    }

    return widget.child;
  }
}
