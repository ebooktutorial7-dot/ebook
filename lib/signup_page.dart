// signup_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Glass 공용
import 'package:ebook_tutorial_app/utils/platform_accessibility.dart';
import 'package:ebook_tutorial_app/theme/glass_theme.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_container.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_app_bar.dart';
import 'package:ebook_tutorial_app/widgets/glass/glass_action_button.dart';

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
  String? _error;

  bool _reduceTransparencyFlag = false;

  @override
  void initState() {
    super.initState();
    _initReduceTransparency();
  }

  Future<void> _initReduceTransparency() async {
    final flag = await PlatformAccessibility.getReduceTransparencyFlag();
    if (!mounted) return;
    setState(() => _reduceTransparencyFlag = flag);
  }

  GlassTheme get _glassTheme =>
      GlassTheme.fromFlags(reduceTransparency: _reduceTransparencyFlag);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
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

    try {
      setState(() => _error = null);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해 주세요.')));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message ?? '회원가입에 실패했습니다.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '알 수 없는 오류가 발생했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _glassTheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const lightA = Color(0xFFF6F7F9);
    const lightB = Color(0xFFE9EBF0);
    const darkA = Color(0xFF0E0E0F);
    const darkB = Color(0xFF1A1B1E);
    final bgStart = isDark ? darkA : lightA;
    final bgEnd = isDark ? darkB : lightB;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgStart, bgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              GlassAppBar(
                title: '이메일 회원가입',
                theme: theme,
                actions: const [],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: '뒤로가기',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    children: [
                      GlassContainer(
                        theme: theme,
                        borderRadius: 18,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.person_add_alt,
                              color: Color(0xFF2874A6),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '간단한 정보로 계정을 만들 수 있습니다.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 이메일
                      GlassContainer(
                        theme: theme,
                        borderRadius: 18,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: '이메일',
                            prefixIcon: Icon(Icons.email),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 비밀번호
                      GlassContainer(
                        theme: theme,
                        borderRadius: 18,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: '비밀번호 (6자리 이상)',
                            prefixIcon: const Icon(Icons.lock),
                            border: InputBorder.none, // ✔ 수정 포인트
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword ? '표시' : '숨기기',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 비밀번호 확인
                      GlassContainer(
                        theme: theme,
                        borderRadius: 18,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: TextField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          onSubmitted: (_) => _signup(),
                          decoration: InputDecoration(
                            hintText: '비밀번호 확인',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              tooltip: _obscureConfirm ? '표시' : '숨기기',
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscureConfirm = !_obscureConfirm,
                                  ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (_error != null)
                        GlassContainer(
                          theme: theme,
                          borderRadius: 14,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          solidFallback: true,
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

                      const SizedBox(height: 16),

                      GlassActionButton(
                        theme: theme,
                        icon: Icons.check_circle,
                        label: '회원가입',
                        onPressed: _signup,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
