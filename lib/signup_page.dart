// signup_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';

class EmailSignupPage extends StatefulWidget {
  const EmailSignupPage({super.key});

  @override
  State<EmailSignupPage> createState() => _EmailSignupPageState();
}

class _EmailSignupPageState extends State<EmailSignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_isSubmitting) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = '모든 항목을 입력해 주세요.');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = '비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = '비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      AppToast.show(context, '회원가입이 완료되었습니다');

      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message ?? '회원가입에 실패했습니다.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '알 수 없는 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color pastelBlue = Color(0xFF9AD0F5);
    const Color border = Color(0xFFE5E7EB);

    const TextStyle thinText = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: .2,
      color: Colors.black87,
    );

    final ButtonStyle pillFrame = OutlinedButton.styleFrom(
      side: const BorderSide(color: border, width: 1),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      foregroundColor: Colors.black87,
      textStyle: thinText,
    );

    final InputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: border, width: 1),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: '뒤로',
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('이메일 회원가입', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double topGap = constraints.maxHeight * 0.18;
            final double bottomGap = constraints.maxHeight * 0.03;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, topGap, 24, bottomGap),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.person_add_alt_1_outlined,
                          color: pastelBlue,
                          size: 44,
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          '새 계정을 만들어 주세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 0, 0, 0),
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          '이메일과 비밀번호를 입력해 주세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: '이메일',
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              color: pastelBlue,
                            ),
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: inputBorder.copyWith(
                              borderSide: const BorderSide(
                                color: pastelBlue,
                                width: 1.2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: '비밀번호 (6자 이상)',
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: pastelBlue,
                            ),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword ? '표시' : '숨기기',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: pastelBlue,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: inputBorder.copyWith(
                              borderSide: const BorderSide(
                                color: pastelBlue,
                                width: 1.2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          onSubmitted: (_) => _signup(),
                          decoration: InputDecoration(
                            hintText: '비밀번호 확인',
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(
                              Icons.lock_reset_outlined,
                              color: pastelBlue,
                            ),
                            suffixIcon: IconButton(
                              tooltip: _obscureConfirm ? '표시' : '숨기기',
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: pastelBlue,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                );
                              },
                            ),
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: inputBorder.copyWith(
                              borderSide: const BorderSide(
                                color: pastelBlue,
                                width: 1.2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_error != null) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red.shade300),
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.transparent,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 8),

                        OutlinedButton(
                          onPressed: _isSubmitting ? null : _signup,
                          style: pillFrame,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSubmitting)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                const Text('회원가입', style: thinText),
                              if (!_isSubmitting) ...const [
                                SizedBox(width: 8),
                                Icon(
                                  Icons.person_add_alt_1_outlined,
                                  size: 20,
                                  color: pastelBlue,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '이미 계정이 있으신가요? ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: pillFrame.copyWith(
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('로그인', style: thinText),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.login,
                                    size: 20,
                                    color: pastelBlue,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
