// genre.dart

enum Genre { main, webNovel, novel, poem, freeForm, selfHelp, science }

Genre genreFromLabel(String label) {
  switch (label) {
    case 'main':
      return Genre.main;
    case '웹 소설':
      return Genre.webNovel;
    case '소설':
      return Genre.novel;
    case '시':
      return Genre.poem;
    case '자유 서식':
      return Genre.freeForm;
    case '자기 계발':
      return Genre.selfHelp;
    case '과학 책':
      return Genre.science;
    default:
      return Genre.freeForm;
  }
}

String genreLabel(Genre g) {
  switch (g) {
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
