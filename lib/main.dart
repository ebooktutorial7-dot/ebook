// main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/migrations.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;

import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';
import 'package:ebook_tutorial_app/firebase_options.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ebook_tutorial_app/pages/ebook_list_page.dart';
import 'package:ebook_tutorial_app/email_login_page.dart';
import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';
import 'package:ebook_tutorial_app/app_locale_controller.dart';
import 'package:ebook_tutorial_app/l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await migrateLegacyPrefsV1();
  await appLocaleController.load();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      await GoogleSignIn.instance.initialize(
        clientId:
            '574290558433-k7j2apemmr9c3cf3v1ejqu9gb6r4jkpj.apps.googleusercontent.com',
      );
    } catch (_) {}
  } catch (_) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: appLocaleController.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko'), Locale('en'), Locale('ja')],
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);

            return Scaffold(body: Center(child: Text(l10n.firebaseInitFailed)));
          },
        ),
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

    return AnimatedBuilder(
      animation: appLocaleController,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,

          locale: appLocaleController.locale,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],

          supportedLocales: const [Locale('ko'), Locale('en'), Locale('ja')],

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
                color: const Color.fromARGB(
                  233,
                  0,
                  0,
                  0,
                ).withValues(alpha: 0.7),
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
      },
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

  void _showAuthError(String provider, Object e) {
    final l10n = AppLocalizations.of(context);

    final message =
        e is FirebaseAuthException
            ? (e.message ?? l10n.providerLoginFailed(provider))
            : l10n.providerLoginFailedWithReason(provider, e.toString());

    AppToast.show(context, message);
  }

  Future<void> _loginWithGoogle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');

        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn.instance.authenticate(
          scopeHint: const ['email', 'profile'],
        );

        final googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EbookListPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showAuthError('Google', e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithApple() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final provider =
          AppleAuthProvider()
            ..addScope('email')
            ..addScope('name');

      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(provider);
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EbookListPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showAuthError('Apple', e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

      final l10n = AppLocalizations.of(context);
      AppToast.show(context, l10n.guestLoginFailed);
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
    final l10n = AppLocalizations.of(context);

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
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 216, 245, 255),
              Color(0xFFEAF8FF),
              Color.fromARGB(255, 255, 255, 255),
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
                            _LoginHeader(
                              title: l10n.appTitle,
                              subtitle: l10n.appSubtitle,
                            ),
                            const SizedBox(height: 26),
                            _LoginCard(
                              isLoading: _isLoading,
                              guestLabel: l10n.tryAsGuest,
                              onEmailPressed:
                                  _isLoading ? null : _goToEmailLogin,
                              onGuestPressed:
                                  _isLoading ? null : _loginAnonymously,
                              onGooglePressed:
                                  _isLoading ? null : _loginWithGoogle,
                              onApplePressed:
                                  _isLoading ? null : _loginWithApple,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.accountConnectNotice,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(186, 129, 178, 207),
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
  const _LoginHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 42),
        const SizedBox(height: 25),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 255, 255),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
    required this.guestLabel,
    required this.onEmailPressed,
    required this.onGuestPressed,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  final bool isLoading;
  final String guestLabel;
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
            label: guestLabel,
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
                        Icon(
                          icon,
                          size: 20,
                          color: const Color.fromARGB(186, 129, 178, 207),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15.5,
                            color: Color.fromARGB(186, 129, 178, 207),
                            fontWeight: FontWeight.w500,
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
