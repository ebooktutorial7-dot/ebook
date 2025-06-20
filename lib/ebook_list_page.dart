import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'genre_select_page.dart';

class EbookListPage extends StatelessWidget {
  const EbookListPage({super.key});

  final List<Map<String, String>> _ebooks = const [
    {'title': '플러터 입문', 'description': 'Flutter로 앱 만들기 첫걸음'},
    {'title': 'Firebase 기초', 'description': 'Firebase와 백엔드 연동'},
    {'title': '상태관리', 'description': 'Provider, Riverpod 등 상태관리 기초'},
  ];

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _goToGenreSelect(BuildContext context) async {
    final selectedGenre = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GenreSelectPage()),
    );

    if (selectedGenre != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('선택한 장르: $selectedGenre')),
      );
      // TODO: 선택한 장르 기반 동작 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전자책 목록'),
        backgroundColor: const Color(0xFF5DADE2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '장르 선택',
            onPressed: () => _goToGenreSelect(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _ebooks.length,
        itemBuilder: (context, index) {
          final ebook = _ebooks[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading:
                  const Icon(Icons.book, size: 40, color: Color(0xFF2874A6)),
              title: Text(
                ebook['title']!,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                ebook['description']!,
                style: const TextStyle(color: Colors.black54),
              ),
              onTap: () {
                // TODO: 상세보기 페이지로 이동
              },
            ),
          );
        },
      ),
    );
  }
}
