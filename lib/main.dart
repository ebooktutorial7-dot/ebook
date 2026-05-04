// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/migrations.dart';

import 'package:flutter/cupertino.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;

import 'package:ebook_tutorial_app/firebase_options.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ebook_tutorial_app/pages/ebook_list_page.dart';
import 'package:ebook_tutorial_app/email_login_page.dart';
import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await migrateLegacyPrefsV1();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('❗ Firebase 초기화 실패'))),
      ),
    );
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WritingSettingsController>(
          create: (_) {
            final c = WritingSettingsController(documentId: null);
            c.load();
            return c;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color selectionFill = Color(0x55FFF59D);
    const Color selectionHandle = Color(0xFFFFC107);

    return MaterialApp(
      title: '전자책 튜토리얼',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ko')],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ).copyWith(primary: Colors.black, secondary: Colors.black),
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        splashFactory: NoSplash.splashFactory,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          foregroundColor: Colors.black,
          shadowColor: Colors.transparent,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: selectionFill,
          selectionHandleColor: selectionHandle,
          cursorColor: Color.fromARGB(255, 156, 189, 218),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: const Color.fromARGB(233, 0, 0, 0).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(70),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 0.9,
            ),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12.2,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          waitDuration: const Duration(milliseconds: 420),
          showDuration: const Duration(milliseconds: 1100),
          verticalOffset: 12,
          triggerMode: TooltipTriggerMode.longPress,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const EbookListPage();
        }

        return const WelcomePage();
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isLoading = false;

  void _showPreparing(String name) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name 로그인은 준비 중입니다.')));
  }

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToEmailLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmailLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF1F7),
              Color(0xFFFFD6E8),
              Color(0xFFEAF8FF),
              Color(0xFFBDEEFF),
            ],
            stops: [0.0, 0.38, 0.72, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _LoginHeader(),

                            const SizedBox(height: 26),

                            _LoginCard(
                              isLoading: _isLoading,
                              onEmailPressed:
                                  _isLoading ? null : _goToEmailLogin,
                              onGuestPressed:
                                  _isLoading ? null : _loginAnonymously,
                              onGooglePressed:
                                  _isLoading
                                      ? null
                                      : () => _showPreparing('Google'),
                              onApplePressed:
                                  _isLoading
                                      ? null
                                      : () => _showPreparing('Apple'),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              '계정은 설정에서 언제든 연결하실 수 있습니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 42),
        SizedBox(height: 25),
        Text(
          'AI 전자책 튜토리얼',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 255, 255),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '지식을 여는 가장 쉬운 첫걸음',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.isLoading,
    required this.onEmailPressed,
    required this.onGuestPressed,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  final bool isLoading;
  final VoidCallback? onEmailPressed;
  final VoidCallback? onGuestPressed;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialCircleButton(
                onTap: onGooglePressed,
                child: Transform.scale(
                  scale: 0.8,
                  child: Image.asset(
                    'lib/assets/icons/google_g.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(width: 25),

              _SocialCircleButton(
                onTap: onApplePressed,
                child: const FaIcon(
                  FontAwesomeIcons.apple,
                  size: 32,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(width: 25),

              _SocialCircleButton(
                onTap: onEmailPressed,
                child: const Icon(
                  Icons.mail_outline_rounded,
                  size: 26,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          _GlassActionButton(
            label: '비회원으로 체험하기',
            icon: Icons.person_outline_rounded,
            isLoading: isLoading,
            onPressed: onGuestPressed,
          ),

          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;

    return Opacity(
      opacity: disabled && !isLoading ? 0.55 : 1,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.72),
              width: 1.1,
            ),
          ),
          child: Center(
            child:
                isLoading
                    ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Color(0xFF172554),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 20, color: const Color(0xFF172554)),
                        const SizedBox(width: 9),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15.5,
                            color: Color(0xFF172554),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.92),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
