import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ebook_list_page.dart';
import 'email_login_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // 비회원 로그인 함수
  Future<void> _loginAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EbookListPage()),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비회원 로그인 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인 방법 선택')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용 크기에 맞춤
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmailLoginPage()),
                  );
                },
                child: const Text('이메일 로그인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _loginAnonymously(context),
                child: const Text('비회원 체험'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
