import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/migrations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;

import 'package:ebook_tutorial_app/firebase_options.dart';
import 'package:ebook_tutorial_app/pages/ebook_list_page.dart';
import 'package:ebook_tutorial_app/pages/login_page.dart';
import 'package:ebook_tutorial_app/controllers/writing_settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 레거시 key 정리
  await migrateLegacyPrefsV1();

  // 🔹 Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('❗ Firebase 초기화 실패\n$e'))),
      ),
    );
    return;
  }

  // 🔹 Provider 트리 구성
  runApp(
    MultiProvider(
      providers: [
        /// 전역(Global) WritingSettings
        ChangeNotifierProvider<WritingSettingsController>(
          create: (_) {
            final c = WritingSettingsController(documentId: null);
            c.load(); // SharedPrefs에서 로드
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
    // 선택 영역 색상 (커스텀)
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
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
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

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color pastelBlue = Color(0xFF9AD0F5);
    const Color border = Color(0xFFE5E7EB);

    final ButtonStyle frameStyle = OutlinedButton.styleFrom(
      side: const BorderSide(color: border, width: 1),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      foregroundColor: Colors.black87,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '전자책 튜토리얼',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double topGap = constraints.maxHeight * 0.20;
            final double bottomGap = constraints.maxHeight * 0.05;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, topGap, 24, bottomGap),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book, size: 80, color: pastelBlue),
                      const SizedBox(height: 24),
                      const Text(
                        '지식을 여는 첫걸음',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'AI 전자책 튜토리얼',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: frameStyle,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('시작하기'),
                            SizedBox(width: 8),
                            Icon(
                              Icons.school_outlined,
                              size: 22,
                              color: pastelBlue,
                            ),
                          ],
                        ),
                      ),
                    ],
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
