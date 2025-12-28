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
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('❗ Firebase 초기화 실패'))),
      ),
    );
    return;
  }

  // 🔹 Provider 트리 구성
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
    // 선택 영역 색상
    const Color selectionFill = Color(0x55FFF59D);
    const Color selectionHandle = Color(0xFFFFC107);

    return MaterialApp(
      title: '전자책 튜토리얼',
      debugShowCheckedModeBanner: false,

      // 🌍 Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ko')],

      // =========================
      // ✅ 전역 테마 (BLACK 고정)
      // =========================
      theme: ThemeData(
        useMaterial3: true,

        // 🔑 Material primary 확정
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ).copyWith(primary: Colors.black, secondary: Colors.black),

        // 🔑 iOS tint 확정 (리스트 번호/불릿 포함)
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

        // 🔹 Tooltip 디자인
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
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
