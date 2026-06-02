// genre.dart

enum Genre { main, webNovel, novel, poem, freeForm, selfHelp, science }

Genre genreFromLabel(String label) {
  switch (label.trim()) {
    case 'main':
    case 'Main':
    case '메인':
    case 'メイン':
      return Genre.main;

    case 'webNovel':
    case '웹 소설':
    case 'Web Novel':
    case 'ウェブ小説':
      return Genre.webNovel;

    case 'novel':
    case '소설':
    case 'Novel':
    case '小説':
      return Genre.novel;

    case 'poem':
    case 'poetry':
    case '시':
    case 'Poetry':
    case '詩':
      return Genre.poem;

    case 'freeForm':
    case '자유 서식':
    case 'Free Form':
    case '自由形式':
      return Genre.freeForm;

    case 'selfHelp':
    case 'selfImprovement':
    case '자기 계발':
    case 'Self-improvement':
    case '自己啓発':
      return Genre.selfHelp;

    case 'science':
    case 'scienceBook':
    case '과학 책':
    case 'Science Book':
    case '科学書':
      return Genre.science;

    default:
      return Genre.freeForm;
  }
}

Genre genreFromKey(String key) {
  switch (key.trim()) {
    case 'main':
      return Genre.main;
    case 'webNovel':
      return Genre.webNovel;
    case 'novel':
      return Genre.novel;
    case 'poem':
      return Genre.poem;
    case 'freeForm':
      return Genre.freeForm;
    case 'selfHelp':
      return Genre.selfHelp;
    case 'science':
      return Genre.science;
    default:
      return Genre.freeForm;
  }
}

String genreKey(Genre genre) {
  switch (genre) {
    case Genre.main:
      return 'main';
    case Genre.webNovel:
      return 'webNovel';
    case Genre.novel:
      return 'novel';
    case Genre.poem:
      return 'poem';
    case Genre.freeForm:
      return 'freeForm';
    case Genre.selfHelp:
      return 'selfHelp';
    case Genre.science:
      return 'science';
  }
}

String genreLabel(Genre genre) {
  switch (genre) {
    case Genre.main:
      return 'Main';
    case Genre.webNovel:
      return '웹 소설';
    case Genre.novel:
      return '소설';
    case Genre.poem:
      return '시';
    case Genre.freeForm:
      return '자유 서식';
    case Genre.selfHelp:
      return '자기 계발';
    case Genre.science:
      return '과학 책';
  }
}

String genreEnglishLabel(Genre genre) {
  switch (genre) {
    case Genre.main:
      return 'Main';
    case Genre.webNovel:
      return 'Web Novel';
    case Genre.novel:
      return 'Novel';
    case Genre.poem:
      return 'Poetry';
    case Genre.freeForm:
      return 'Free Form';
    case Genre.selfHelp:
      return 'Self-improvement';
    case Genre.science:
      return 'Science Book';
  }
}

String genreJapaneseLabel(Genre genre) {
  switch (genre) {
    case Genre.main:
      return 'メイン';
    case Genre.webNovel:
      return 'ウェブ小説';
    case Genre.novel:
      return '小説';
    case Genre.poem:
      return '詩';
    case Genre.freeForm:
      return '自由形式';
    case Genre.selfHelp:
      return '自己啓発';
    case Genre.science:
      return '科学書';
  }
}
