import 'package:flutter/material.dart';

class GenreSelectPage extends StatelessWidget {
  const GenreSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = ['자유 서식', '소설', '시', '동화', '에세이', '과제'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('장르 선택'),
        backgroundColor: const Color(0xFF5DADE2),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(genres[index]),
              onTap: () {
                Navigator.pop(context, genres[index]); // 선택 후 돌아감
              },
            ),
          );
        },
      ),
    );
  }
}
