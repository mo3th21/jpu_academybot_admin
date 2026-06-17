import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  int _failedAttempts = 0;
  DateTime? _lastAttemptTime;

  // Security: Simple client-side rate limiting
  static const int _maxAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 5);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isLockedOut {
    if (_failedAttempts < _maxAttempts || _lastAttemptTime == null) return false;
    final elapsed = DateTime.now().difference(_lastAttemptTime!);
    return elapsed < _lockoutDuration;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    // Check rate limiting
    if (_isLockedOut) {
      final remaining = _lockoutDuration - DateTime.now().difference(_lastAttemptTime!);
      _showErrorSnack('تم تجاوز عدد المحاولات. حاول مرة أخرى بعد ${remaining.inMinutes} دقائق');
      return;
    }

    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reset failed attempts on success
      _failedAttempts = 0;

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      _failedAttempts++;
      _lastAttemptTime = DateTime.now();

      final msg = _firebaseErrorMessage(e);
      final debugInfo = kDebugMode ? ' (${e.code})' : '';
      _showErrorSnack('$msg$debugInfo');
    } catch (e) {
      _showErrorSnack('حدث خطأ غير متوقع. حاول لاحقاً.');
      if (kDebugMode) debugPrint('❌ Login error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب.';
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد.';
      case 'wrong-password':
        return 'كلمة السر غير صحيحة.';
      case 'too-many-requests':
        return 'تم إجراء محاولات كثيرة. حاول لاحقاً.';
      case 'network-request-failed':
        return 'خطأ في الاتصال. تحقق من الإنترنت.';
      default:
        return e.message ?? 'فشل تسجيل الدخول. تحقق من بياناتك.';
    }
  }

  void _showErrorSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.defaultShadow,
                border: Border.all(
                  color: AppTheme.textSecondary.withOpacity(0.06),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.primaryGradient,
                                boxShadow: AppTheme.defaultShadow,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'مرحباً، مسؤول النظام',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'سجّل الدخول للوصول إلى لوحة التحكم',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'الرجاء إدخال البريد الإلكتروني.';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                            return 'الرجاء إدخال بريد إلكتروني صالح.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'الرجاء إدخال كلمة السر.';
                          }
                          if (v.length < 6) {
                            return 'كلمة السر يجب أن تكون 6 أحرف على الأقل.';
                          }
                          return null;
                        },
                      ),
                      if (_isLockedOut) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: AppTheme.error, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'تم تجاوز عدد المحاولات المسموحة',
                                  style: TextStyle(
                                    color: AppTheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_loading || _isLockedOut) ? null : _signIn,
                          style: Theme.of(context).elevatedButtonTheme.style,
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'تسجيل دخول',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}
