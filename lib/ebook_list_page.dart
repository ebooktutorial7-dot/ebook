import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class EbookListPage extends StatelessWidget {
  const EbookListPage({super.key});

  final List<Map<String, String>> _ebooks = const [
    {'title': '첫 번째 책', 'description': '앱 만들기 첫걸음'},
    {'title': '두 번째 책', 'description': '삶, 우주에 관한 모든 것'},
    {'title': '세 번째 책', 'description': '마법 세계 탐험'},
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

  void _showGenreDialog(BuildContext context) {
    final genres = [
      '자유 서식',
      '소설',
      '시',
      '자기 계발',
      '과학 책',
      '그림 책',
      '에세이',
      '수업 과제',
    ];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '장르 선택',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(158, 1, 73, 121),
                  ),
                ),
              ),

              // 2열 그리드
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 3,
                    shrinkWrap: true,
                    children: genres.map((genre) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 168, 201, 223),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 8),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('선택한 장르: $genre')),
                          );
                        },
                        child: Text(
                          genre,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // *** 닫기 버튼 전 여백 추가 ***
              const SizedBox(height: 24),

              // 닫기 버튼
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '닫기',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8), // 아래쪽 여유 공간
            ],
          ),
        ),
      ),
    );
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
            onPressed: () => _showGenreDialog(context),
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
        itemBuilder: (_, index) {
          final ebook = _ebooks[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(
                Icons.book,
                size: 40,
                color: Color(0xFF2874A6),
              ),
              title: Text(
                ebook['title']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
