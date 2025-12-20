// login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ebook_tutorial_app/pages/ebook_list_page.dart';
import 'package:ebook_tutorial_app/email_login_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _loginAnonymously() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EbookListPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비회원 로그인에 실패했습니다. 잠시 후 다시 시도해 주세요.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color pastelBlue = Color(0xFF9AD0F5);
    const Color pastelPink = Color(0xFFF8BBD0);
    const Color border = Color(0xFFE5E7EB);

    const TextStyle thinText = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: .2,
      color: Colors.black87,
    );

    final ButtonStyle frameStyle = OutlinedButton.styleFrom(
      side: const BorderSide(color: border, width: 1),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      foregroundColor: Colors.black87,
      textStyle: thinText,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: '뒤로',
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed:
              () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              ),
        ),
        centerTitle: true,
        title: const Text('로그인', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double topGap = constraints.maxHeight * 0.25;
            final double bottomGap = constraints.maxHeight * 0.03;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, topGap, 24, bottomGap),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '원하는 방법으로 시작해 보세요',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        OutlinedButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const EmailLoginPage(),
                                      ),
                                    );
                                  },
                          style: frameStyle,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('이메일로 계속하기', style: thinText),
                              SizedBox(width: 8),
                              Icon(
                                Icons.mail_outline,
                                size: 20,
                                color: pastelPink,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton(
                          onPressed: _isLoading ? null : _loginAnonymously,
                          style: frameStyle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isLoading)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                const Text('비회원 체험', style: thinText),
                              if (!_isLoading) ...const [
                                SizedBox(width: 8),
                                Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: pastelBlue,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          '계정은 설정에서 언제든 연결할 수 있습니다.',
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
