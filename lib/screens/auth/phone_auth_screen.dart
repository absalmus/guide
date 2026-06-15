import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/services/auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;

  Future<void> _sendCode() async {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال رقم هاتف صحيح')));
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().startPhoneVerification(
        _phoneController.text,
        codeSent: (verificationId) {
          if (mounted)
            setState(() {
              _codeSent = true;
            });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('تم إرسال رمز التحقق')));
        },
        onFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل إرسال رمز: ${e.toString()}')),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    try {
      await context.read<AuthService>().signInWithPhone(
        _phoneController.text,
        _codeController.text,
      );
      if (mounted) context.go('/complete-profile');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل التحقق: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل بالهاتف')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              enabled: !_codeSent,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                hintText: '01xxxxxxxxx',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'رمز التحقق',
                  prefixIcon: Icon(Icons.sms),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : (_codeSent ? _verify : _sendCode),
                child: _loading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(_codeSent ? 'تأكيد' : 'إرسال رمز التحقق'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
