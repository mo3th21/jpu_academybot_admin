import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/admin.dart';

/// صفحة إنشاء حساب مدير (Admin)
/// الحقول: اسم، ايميل، كلمة سر، تأكيد كلمة سر
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) throw Exception('Failed to create user');

      // قم بتحديث displayName في حساب المصادقة
      await user.updateDisplayName(name);

      // أنشئ مستند Admin في Firestore تحت collection 'admins'
      final admin = Admin(
        adminId: user.uid,
        displayName: name,
        email: email,
        createdAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance.collection('admins').doc(user.uid).set(
            admin.toMap(useServerTimestampForCreated: true),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
      );

      // بعد التسجيل نعيد توجيه المستخدم للصفحة الرئيسية (أو شاشة admin)
  Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      final msg = _firebaseErrorMessage(e);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء إنشاء الحساب')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'هذا البريد مستخدم بالفعل.';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      case 'operation-not-allowed':
        return 'العملية غير مسموحة. تأكد من إعدادات Firebase Auth.';
      case 'weak-password':
        return 'كلمة السر ضعيفة. استخدم 6 أحرف أو أكثر.';
      default:
        return e.message ?? 'فشل إنشاء الحساب.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب مدير')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'الرجاء إدخال الاسم.';
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'الرجاء إدخال البريد الإلكتروني.';
                          if (!v.contains('@')) return 'الرجاء إدخال بريد إلكتروني صالح.';
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'كلمة السر',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة السر.';
                          if (v.length < 6) return 'كلمة السر يجب أن تكون 6 أحرف على الأقل.';
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscure,
                        decoration: const InputDecoration(
                          labelText: 'تأكيد كلمة السر',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'الرجاء تأكيد كلمة السر.';
                          if (v != _passwordController.text) return 'كلمتا السر غير متطابقتين.';
                          return null;
                        },
                        onFieldSubmitted: (_) => _register(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('إنشاء الحساب'),
                        ),
                      ),
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
