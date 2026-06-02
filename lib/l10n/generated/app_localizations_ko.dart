// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get korean => '한국어';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get screenSettings => '화면 설정';

  @override
  String get defaultValue => '기본';

  @override
  String get notification => '알림';

  @override
  String get cloudSync => '클라우드 동기화';

  @override
  String get appInfo => '앱 정보';

  @override
  String get appDescription => 'AI 전자책 튜토리얼';

  @override
  String get version => '버전';

  @override
  String get close => '닫기';

  @override
  String get connect => '연결';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get search => '검색';

  @override
  String get accountConnect => '계정 연결';

  @override
  String get accountConnectMessage => '비회원 계정을 로그인 계정으로 연결할 수 있습니다.';

  @override
  String get connectLoginAccount => '로그인 계정 연결하기';

  @override
  String get appleAccountConnect => 'Apple 계정 연결';

  @override
  String get googleAccountConnect => 'Google 계정 연결';

  @override
  String get emailAccountConnect => '이메일 계정 연결';

  @override
  String get googleAccount => 'Google 계정';

  @override
  String get appleAccount => 'Apple 계정';

  @override
  String get emailAccount => '이메일 계정';

  @override
  String get guestAccount => '비회원 계정';

  @override
  String get unknown => '알 수 없음';

  @override
  String get guestUser => '비회원 사용자';

  @override
  String get user => '사용자';

  @override
  String get email => '이메일';

  @override
  String get passwordMinLengthHint => '비밀번호 6자 이상';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get allFieldsRequired => '모든 항목을 입력해 주세요.';

  @override
  String get passwordMinLength => '비밀번호는 6자 이상이어야 합니다.';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다.';

  @override
  String get signInInfoNotFound => '로그인 정보가 없습니다.';

  @override
  String get accountAlreadyLinked => '이미 계정이 연결되어 있습니다.';

  @override
  String get emailAccountLinked => '이메일 계정이 연결되었습니다.';

  @override
  String get appleAccountLinked => 'Apple 계정이 연결되었습니다.';

  @override
  String get googleAccountLinked => 'Google 계정이 연결되었습니다.';

  @override
  String get emailAlreadyInUse => '이미 사용 중인 이메일입니다.';

  @override
  String get invalidEmail => '이메일 형식이 올바르지 않습니다.';

  @override
  String get weakPassword => '비밀번호가 너무 약합니다.';

  @override
  String get accountConnectFailed => '계정 연결에 실패했습니다.';

  @override
  String get appleCredentialAlreadyInUse => '이미 다른 계정에 연결된 Apple 계정입니다.';

  @override
  String get appleProviderAlreadyLinked => '이미 Apple 계정이 연결되어 있습니다.';

  @override
  String get appleLoginNotEnabled => 'Firebase에서 Apple 로그인이 활성화되어 있지 않습니다.';

  @override
  String get appleAccountConnectFailed => 'Apple 계정 연결에 실패했습니다.';

  @override
  String get googleCredentialAlreadyInUse => '이미 다른 계정에 연결된 Google 계정입니다.';

  @override
  String get googleAccountConnectFailed => 'Google 계정 연결에 실패했습니다.';

  @override
  String get appTitle => 'AI 전자책 튜토리얼';

  @override
  String get appSubtitle => '지식을 여는 가장 쉬운 첫걸음';

  @override
  String get tryAsGuest => '비회원으로 체험하기';

  @override
  String get accountConnectNotice => '계정은 설정에서 언제든 연결하실 수 있습니다.';

  @override
  String get firebaseInitFailed => '❗ Firebase 초기화 실패';

  @override
  String providerLoginFailed(String provider) {
    return '$provider 로그인에 실패했습니다.';
  }

  @override
  String providerLoginFailedWithReason(String provider, String reason) {
    return '$provider 로그인 실패: $reason';
  }

  @override
  String get guestLoginFailed => '비회원 로그인에 실패했습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get genreSelect => '장르 선택';

  @override
  String get genreWebNovel => '웹 소설';

  @override
  String get genreNovel => '소설';

  @override
  String get genrePoetry => '시';

  @override
  String get genreFreeForm => '자유 서식';

  @override
  String get genreSelfImprovement => '자기 계발';

  @override
  String get genreScienceBook => '과학 책';

  @override
  String get more => '더보기';

  @override
  String get logout => '로그아웃';

  @override
  String get speechRecognitionUnavailable => '음성 인식을 사용할 수 없습니다.';

  @override
  String speechRecognitionError(String error) {
    return '음성 인식 오류: $error';
  }

  @override
  String get keywordAlreadyExists => '이미 등록된 키워드입니다.';

  @override
  String get chapterTitleHint => '회차 제목 입력';

  @override
  String get focusWritingModeToggle => '집중 글쓰기 모드 토글';

  @override
  String get exitFocusMode => '집중 모드 해제';

  @override
  String get focusWritingMode => '집중 글쓰기 모드';

  @override
  String get convertPng => 'PNG 변환';

  @override
  String get pngPreview => 'PNG 미리보기';

  @override
  String get keywordInputHint => '키워드 입력';

  @override
  String charCountLabel(int count) {
    return '$count자';
  }

  @override
  String get character => '캐릭터';

  @override
  String get characterColor => '캐릭터 색상';

  @override
  String get transparency => '투명도';

  @override
  String get clear => '해제';

  @override
  String get cancel => '취소';

  @override
  String get apply => '적용';

  @override
  String get addPhoto => '+ 사진';

  @override
  String get tapToAddOrChange => '탭 : 추가/변경';

  @override
  String get name => '이름';

  @override
  String get birthday => '생일';

  @override
  String get height => '키';

  @override
  String get bloodType => '혈액형';

  @override
  String get blood => '혈액형';

  @override
  String get profile => '프로필';

  @override
  String get profileUpper => 'PROFILE';

  @override
  String get color => '색상';

  @override
  String get personality => '성격';

  @override
  String get personalityKeywords => '성격 키워드';

  @override
  String get likesAndDislikes => '좋아/싫어';

  @override
  String get likes => '좋아하는 것';

  @override
  String get dislikes => '싫어하는 것';

  @override
  String get bodyAppearance => '신체 / 외형';

  @override
  String get bodyAppearanceMemo => '신체 / 외형 메모';

  @override
  String get enterAfterInput => '입력 후 Enter';

  @override
  String get keywordEnterAfterInput => '키워드 입력 후 Enter';

  @override
  String get memoEnterAfterInput => '메모 입력 후 Enter';

  @override
  String get noRegisteredItems => '아직 등록된 항목이 없습니다.';

  @override
  String get exampleName => '예) 무무';

  @override
  String get exampleBirthday => '예) 2005-01-01';

  @override
  String get exampleHeight => '예) 159cm';

  @override
  String get exampleBloodType => '예) O+';

  @override
  String get exampleProfile => '예) 낮에는 잠이 많음';

  @override
  String get exampleBodyAppearanceMemo => '예) 인간형일 때 투명하게 빛나는 귀와 꼬리';

  @override
  String get faction => '세력';

  @override
  String get addShape => '도형 추가';

  @override
  String get zoomOut => '축소';

  @override
  String get zoomIn => '확대';

  @override
  String get edgeColor => '선 색상';

  @override
  String get replacePhoto => '사진 교체';

  @override
  String get deletePhoto => '사진 삭제';

  @override
  String get addPhotoToDiagram => '사진 추가';

  @override
  String get replaceColor => '색상 교체';

  @override
  String get deleteColor => '색상 삭제';

  @override
  String get addColor => '색상 추가';

  @override
  String get addText => '텍스트 추가';

  @override
  String get replaceText => '텍스트 교체';

  @override
  String get deleteText => '텍스트 삭제';

  @override
  String get addTextColor => '텍스트 색상 추가';

  @override
  String get replaceTextColor => '텍스트 색상 교체';

  @override
  String get deleteTextColor => '텍스트 색상 삭제';

  @override
  String get textColor => '텍스트 색상';

  @override
  String get shapeColor => '도형 색상';

  @override
  String get relation => '관계';

  @override
  String get relationHint => '예: 동맹, 적대, 가족';

  @override
  String get moveLocked => '이동 잠김';

  @override
  String get moveAvailable => '이동 가능';

  @override
  String get factionSelectionHint => '도형 또는 선을 선택해 주세요.';

  @override
  String get changeShape => '도형 변경';

  @override
  String get lock => '잠금';

  @override
  String get unlock => '잠금 해제';

  @override
  String get deleteShape => '도형 삭제';

  @override
  String get deleteLine => '선 삭제';

  @override
  String get size => '크기';

  @override
  String get curvature => '곡률';

  @override
  String get lineWidth => '선 굵기';

  @override
  String get selectColor => '색상 선택';

  @override
  String get dashedLine => '점선';

  @override
  String get arrow => '화살표';

  @override
  String get none => '없음';

  @override
  String get start => '시작';

  @override
  String get end => '끝';

  @override
  String get bothEnds => '양쪽';

  @override
  String get insideTextHint => '도형 안에 표시할 텍스트';

  @override
  String get nameHint => '이름';

  @override
  String get newNode => '새 항목';

  @override
  String get timeline => '타임라인';

  @override
  String get timelineAdd => 'Timeline 추가';

  @override
  String get timelineEdit => 'Timeline 편집';

  @override
  String get timelineEmpty => '타임라인을 추가해 보세요.';

  @override
  String get timelineSeedCreate => 'create';

  @override
  String get timelineSeedCreateOne => 'create 1';

  @override
  String get timelineSeedUnnamed => 'Unnamed';

  @override
  String get timelineSeedEditWord => '탭 하여 단어를 편집해 보세요';

  @override
  String get timelineSeedReorderColor => '색상을 길게 탭 하여 위치를 바꿔보세요';

  @override
  String get timelineSeedEditColorName => '탭 하여 색상 이름을 편집해 보세요';

  @override
  String get timelineSeedEditContent => '탭 하여 내용을 편집해 보세요';

  @override
  String get unnamed => '이름 없음';

  @override
  String get barName => '바 이름';

  @override
  String get barNameHint => '예) Chapter 1';

  @override
  String get wordDescription => '단어 / 설명';

  @override
  String get description => '설명';

  @override
  String get barColor => '바 색상';

  @override
  String get worldSeat => '월드 시트';

  @override
  String get glossary => '용어집';

  @override
  String get freeMemo => '자유 메모';

  @override
  String get glossaryEmpty => '용어를 추가해 보세요.';

  @override
  String get freeMemoEmpty => '자유 메모를 추가해 보세요.';

  @override
  String get noSearchResults => '검색 결과가 없습니다.';

  @override
  String get pinAdd => '핀 추가';

  @override
  String get pinRemove => '핀 해제';

  @override
  String get term => '단어';

  @override
  String get glossaryAdd => '용어 추가';

  @override
  String get glossaryEdit => '용어 편집';

  @override
  String get glossaryDeleteTitle => '용어 삭제';

  @override
  String get glossaryDeleteMessage => '이 용어를 삭제하시겠습니까?';

  @override
  String get memoAdd => '새 메모';

  @override
  String get memoEdit => '메모 편집';

  @override
  String get memoHint => '메모를 입력하세요';

  @override
  String get memoDeleteTitle => '메모 삭제';

  @override
  String get memoDeleteMessage => '이 메모를 삭제하시겠습니까?';

  @override
  String timelineDeleteTitle(String name) {
    return '$name 삭제';
  }

  @override
  String timelineDeleteMessage(String name) {
    return '이 타임라인($name)을 삭제하시겠습니까?';
  }

  @override
  String get characterDeleteTitle => '캐릭터 삭제';

  @override
  String get characterDeleteMessage => '이 캐릭터를 삭제하시겠습니까?';

  @override
  String get protagonistCharacter => '주인공 캐릭터';

  @override
  String get supportingCharacter => '조연 캐릭터';

  @override
  String get emptyProtagonistCharacters => '주인공 캐릭터를 추가해 보세요.';

  @override
  String get emptySupportingCharacters => '조연 캐릭터를 추가해 보세요.';

  @override
  String get emptyCharacters => '캐릭터를 추가해 보세요.';

  @override
  String get tapToEdit => '탭하여 편집';

  @override
  String get descriptionInputHint => '설명을 입력하세요';

  @override
  String get seedCharacterMainTone => '메인 톤';

  @override
  String get seedCharacterHikaraName => '히카라';

  @override
  String get seedCharacterHikaraSpecialNote => '목표: 엘프 종족의 근원을 찾는다.';

  @override
  String get seedCharacterHikaraPersonalityResponsibility => '책임감';

  @override
  String get seedCharacterHikaraLikeObservation => '관측';

  @override
  String get seedCharacterHikaraLikeOldBooks => '고서';

  @override
  String get seedCharacterHikaraDislikeIrresponsibility => '무책임';

  @override
  String get seedCharacterHikaraPhysicalBlueEyes => '푸른 눈';

  @override
  String get seedCharacterElixiName => '엘릭시';

  @override
  String get seedCharacterElixiSpecialNote => '마법 약초를 연구한다.';

  @override
  String get seedCharacterElixiPersonalityCuriosity => '호기심';

  @override
  String get seedCharacterElixiLikeHerbs => '약초';

  @override
  String get seedCharacterElixiLikePharmacology => '약학';

  @override
  String get seedCharacterElixiDislikeBugs => '벌레';

  @override
  String get seedCharacterElixiPhysicalGoldenHair => '금빛 머리카락';

  @override
  String get bookListTitle => '책 목록';

  @override
  String get selectBooks => '책 선택';

  @override
  String selectedBooksCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String get cancelSelection => '선택 취소';

  @override
  String get deleteBooksConfirmTitle => '삭제 확인';

  @override
  String get deleteBooksConfirmMessage => '선택된 책을 삭제하시겠습니까?';

  @override
  String get untitledBook => '제목 없음';

  @override
  String get enterBookTitle => '제목을 입력하세요';

  @override
  String get share => '공유';

  @override
  String get restore => '불러오기';

  @override
  String get preparingPdf => 'PDF를 준비 중입니다';

  @override
  String get zipShare => 'ZIP 공유';

  @override
  String get creatingZipFile => 'ZIP 파일을 만드는 중입니다';

  @override
  String get zipNoFiles => 'ZIP에 넣을 파일이 없습니다';

  @override
  String get zipShareComplete => 'ZIP 공유 완료';

  @override
  String zipShareFailed(String error) {
    return 'ZIP 공유 실패: $error';
  }

  @override
  String get selectChapterCoverMessage => '이 회차 표지로 사용할 이미지를 선택하세요.';

  @override
  String get takePhoto => '카메라로 촬영';

  @override
  String get chooseFromAlbum => '앨범에서 선택';

  @override
  String get chapterCoverDeleted => '이 회차 표지가 삭제되었습니다';

  @override
  String get chapterCoverSet => '회차 표지가 설정되었습니다';

  @override
  String get coverFileNotFound => '표지 파일을 찾을 수 없습니다';

  @override
  String get selectCoverPhoto => '표지 사진 선택';

  @override
  String get selectBookCoverMessage => '책 표지로 사용할 이미지를 선택하세요.';

  @override
  String get coverPhotoDeleted => '표지 사진이 삭제되었습니다';

  @override
  String get coverPhotoSet => '표지 사진이 설정되었습니다';

  @override
  String get preparingBackupZip => '백업 ZIP 파일을 준비 중입니다';

  @override
  String get bookBackupDescription => '책 백업 파일입니다.';

  @override
  String get shareBackupInstruction => '공유 화면에서 iCloud Drive 또는 파일 앱을 선택하세요';

  @override
  String backupExportFailed(String error) {
    return '백업 파일 내보내기 실패: $error';
  }

  @override
  String get selectBackupZipFile => '백업 ZIP 파일을 선택하세요';

  @override
  String get backupFileReadFailed => '백업 파일을 읽을 수 없습니다';

  @override
  String get backupRestoreComplete => '백업 불러오기 완료';

  @override
  String backupRestoreFailed(String error) {
    return '백업 불러오기 실패: $error';
  }

  @override
  String get googleDriveSavingZipBackup => 'Google Drive에 ZIP 백업 저장 중입니다';

  @override
  String googleDriveSaveComplete(String savedName) {
    return 'Google Drive 저장 완료: $savedName';
  }

  @override
  String googleDriveSaveFailed(String error) {
    return 'Google Drive 저장 실패: $error';
  }

  @override
  String get googleDriveNoBackupFiles => 'Google Drive 백업 파일이 없습니다';

  @override
  String get googleDriveImport => 'Google Drive 불러오기';

  @override
  String get selectBackupFileMessage => '불러올 백업 파일을 선택하세요.';

  @override
  String get backupImport => '백업 불러오기';

  @override
  String get googleDriveBackupReplaceConfirm =>
      '현재 화면의 책 내용이 Google Drive 백업 내용으로 교체됩니다. 계속하시겠습니까?';

  @override
  String get bookBackupJsonNotFound => 'book_backup.json을 찾을 수 없습니다';

  @override
  String get restoredChapter => '복원된 회차';

  @override
  String get googleDriveBackupListLoading => 'Google Drive 백업 목록을 불러오는 중입니다';

  @override
  String get googleDriveBackupDownloading => 'Google Drive 백업을 다운로드 중입니다';

  @override
  String get googleDriveBackupRestoreComplete => 'Google Drive 백업 불러오기 완료';

  @override
  String googleDriveRestoreFailed(String error) {
    return 'Google Drive 불러오기 실패: $error';
  }

  @override
  String get noOtherChapterToSplitEdit => '같이 편집할 다른 회차가 없습니다';

  @override
  String splitSelectChapterTitle(String title) {
    return '$title와 같이 편집할 회차 선택';
  }

  @override
  String get splitEditSaveComplete => '분할 편집 저장 완료';

  @override
  String get splitEdit => '분할 편집';

  @override
  String get top => '위쪽';

  @override
  String get bottom => '아래쪽';

  @override
  String get defaultBookTitle => '책 제목';

  @override
  String chapterAutoTitle(String title, int number) {
    return '$title $number화';
  }

  @override
  String get chapterSaveComplete => '회차 저장 완료';

  @override
  String get chapterDeleteConfirmTitle => '삭제 확인';

  @override
  String chapterDeleteConfirmMessage(String title) {
    return '‘$title’ 회차를 삭제하시겠습니까?';
  }

  @override
  String get deletedComplete => '삭제되었습니다';

  @override
  String get chapterReorder => '회차 이동';

  @override
  String get reorderModeMessage => '이동 모드입니다. 드래그하여 순서를 바꾸세요';

  @override
  String chapterShareLabel(String title) {
    return '‘$title’ 공유';
  }

  @override
  String chapterDeleteLabel(String title) {
    return '‘$title’ 삭제';
  }

  @override
  String get chapterReordering => '회차 이동 중';

  @override
  String totalChapterCount(int count) {
    return '전체 $count회';
  }

  @override
  String get addChapterHint => '우측 상단의 + 버튼을 눌러 회차를 추가하세요.';

  @override
  String get addChapterFirst => '먼저 회차를 추가해 주세요';

  @override
  String get allChapters => '전체 회차';

  @override
  String get selectedChapters => '선택 회차';

  @override
  String get noSelectedChapters => '선택된 회차가 없습니다';

  @override
  String get allChaptersOption => '모든 회차';

  @override
  String get chapters => '회차';

  @override
  String get chapterTitleInput => '회차 제목 입력';

  @override
  String get sortOldestFirst => '첫화부터';

  @override
  String get sortNewestFirst => '마지막화부터';

  @override
  String get memoDeletedComplete => '메모가 삭제되었습니다';

  @override
  String get bookMemo => '책 메모';

  @override
  String get bookMemoEmptyHint => '+ 이 책과 관련된 메모를 추가해 보세요.';

  @override
  String get memo => '메모';

  @override
  String docxImageAlt(String fileName) {
    return '[이미지: $fileName]';
  }

  @override
  String get preparingWordFile => 'MS Word 파일을 준비 중입니다';

  @override
  String get wordShareOpened => 'MS Word 파일 공유를 열었습니다';

  @override
  String wordCreateFailed(String error) {
    return 'MS Word 파일 생성 실패: $error';
  }

  @override
  String get preparingTxtFile => 'TXT 파일을 준비 중입니다';

  @override
  String get txtShareOpened => 'TXT 파일 공유를 열었습니다';

  @override
  String txtCreateFailed(String error) {
    return 'TXT 파일 생성 실패: $error';
  }

  @override
  String get localCloud => '로컬 / 클라우드';

  @override
  String get iCloudImport => 'iCloud 불러오기';

  @override
  String get epubForEbook => 'ePub 전자책용';

  @override
  String pdfCreateFailed(String error) {
    return 'PDF 생성 실패: $error';
  }

  @override
  String get theme => '테마';

  @override
  String get font => '폰트';

  @override
  String get defaultFont => '기본체';

  @override
  String get batangFont => '바탕체';

  @override
  String get gothicFont => '고딕체';

  @override
  String get lineSpacing => '줄 간격';

  @override
  String get letterSpacing => '글 간격';

  @override
  String get margin => '여백';

  @override
  String get unpinChapter => '고정 해제';

  @override
  String get pinChapter => '회차 고정';

  @override
  String get unpinned => '고정 해제됨';

  @override
  String get chapterPinned => '회차 고정됨';

  @override
  String get workIntro => '작품 소개';

  @override
  String get workIntroHint => '작품의 분위기, 줄거리, 세계관 등을 간단히 소개해 주세요.';

  @override
  String get keywords => '키워드';

  @override
  String get keywordsHelper => '#로맨스 #성장물 #판타지 처럼 자유롭게 추가하세요.';

  @override
  String get emptyKeywords => '아직 등록된 키워드가 없습니다.';

  @override
  String get keywordInput => '키워드 입력';

  @override
  String get detailInfo => '상세 정보';

  @override
  String get authorOriginal => '글 / 원작';

  @override
  String get authorOriginalHint => '글 / 원작 정보를 입력하세요.';

  @override
  String get workCategory => '작품 분류';

  @override
  String get workCategoryHint => '작품 분류를 입력하세요.';

  @override
  String get ageRating => '연령 등급';

  @override
  String get ageRatingHint => '연령 등급을 입력하세요.';

  @override
  String pageIndicator(int current, int total) {
    return '페이지 $current / $total';
  }

  @override
  String chapterMeta(String size, String chars, String date) {
    return '$size · $chars자 · $date';
  }

  @override
  String get penNameHint => '필명 작성';

  @override
  String get bookPreview => '책 미리보기';

  @override
  String get workInfo => '작품 정보';

  @override
  String get allSettings => '전체 설정';

  @override
  String get back => '뒤로가기';

  @override
  String get coverPhotoAdd => '+ 표지 사진';

  @override
  String get example => '예시';

  @override
  String get settingsPreviewSample => 'Build Story\n예시 글 입니다\n설정을 바꿔보세요';

  @override
  String get calendarEditSchedule => '일정 편집';

  @override
  String get calendarNewSchedule => '신규 일정';

  @override
  String get calendarTitleHint => '제목 입력';

  @override
  String get calendarStartDate => '시작일';

  @override
  String get calendarEndDate => '종료일';

  @override
  String get calendarColor => '색상';

  @override
  String get calendarMemoHint => '메모 입력';

  @override
  String get calendarDeleteSchedule => '일정 삭제';

  @override
  String calendarDeleteScheduleConfirm(String title) {
    return '“$title” 일정을 삭제하시겠습니까?';
  }

  @override
  String get calendarNoTitle => '제목 없음';

  @override
  String get calendarPickDate => '날짜 선택';

  @override
  String get calendarConfirm => '확인';

  @override
  String get calendarWritingDays => '집필한 날';

  @override
  String get calendarTodayWritten => '오늘 작성';

  @override
  String get calendarTotalChars => '총 글자수';

  @override
  String get calendarBestRecord => '최고 기록';

  @override
  String calendarDaysValue(int count) {
    return '$count일';
  }

  @override
  String calendarCharsValue(String count) {
    return '$count자';
  }

  @override
  String calendarBestRecordValue(String chars, String date) {
    return '$chars자 ($date)';
  }

  @override
  String get calendarResetAll => '전체 초기화';

  @override
  String get calendarDeleteAllDataConfirm => '모든 캘린더 데이터를 삭제하시겠습니까?';

  @override
  String get calendarDeleteAllDataMessage =>
      '일정 / 오늘 할 일 / 연재 / 반복 설정 / 집필 기록이 모두 삭제됩니다.';

  @override
  String get calendarDeleteAll => '전체 삭제';

  @override
  String get calendarResetRecord => '기록 초기화';

  @override
  String calendarDeleteDateRecordConfirm(String date) {
    return '$date 기록을 삭제하시겠습니까?';
  }

  @override
  String get calendarDeleteDateRecordMessage =>
      '오늘 할 일 / 연재 / 집필 기록이 모두 삭제됩니다.';

  @override
  String get calendarNoEvents => '등록된 일정이 없습니다.';

  @override
  String get calendarTodayTodo => '오늘 할 일';

  @override
  String get calendarAdd => '추가';

  @override
  String get calendarTodoHelper => '오늘 해야 할 작업을 추가해두면, 작업 흐름이 정리됩니다.';

  @override
  String get calendarReleaseUpload => '연재 [ 업로드 ]';

  @override
  String get calendarReleaseHelper => '업로드 계획/완료를 기록해두면, 연재 주기 관리에 도움이 됩니다.';

  @override
  String calendarMonthlyStats(String month) {
    return '월 통계 [ $month ]';
  }

  @override
  String get calendarResetThisDateRecord => '이 날짜 기록 초기화';

  @override
  String get calendarResetAllData => '전체 데이터 초기화';

  @override
  String get calendarTaskHint => '할 일을 입력하세요';

  @override
  String get calendarZeroChars => '0자';

  @override
  String get calendarUploadTitleHint => '업로드 제목을 입력하세요';

  @override
  String get calendarComplete => '완료';

  @override
  String get calendarPlan => '계획';

  @override
  String get ebookSaveComplete => '저장 완료';

  @override
  String get ebookDefaultContent => '작품 내용을 입력하세요';

  @override
  String get ebookLatestEpisode => '최신 회차';

  @override
  String ebookCountValue(int count) {
    return '$count개';
  }

  @override
  String get ebookTodayNoRecord => '오늘 등록된 기록이 없습니다.';

  @override
  String ebookTodaySummary(
    int doneTasks,
    int totalTasks,
    int releaseCount,
    int eventCount,
  ) {
    return '오늘 할 일 $doneTasks/$totalTasks · 업로드 $releaseCount개 · 일정 $eventCount개';
  }

  @override
  String get ebookMainSquareCreateTitle => '새 작품 만들기';

  @override
  String get ebookMainCardCustomizeSaveComplete => '메인 카드 꾸미기 저장 완료';

  @override
  String get ebookPreset => '프리셋';

  @override
  String get ebookPresetName => '프리셋 이름';

  @override
  String ebookPresetDefaultName(int number) {
    return '프리셋 $number';
  }

  @override
  String get ebookPresetNameReplace => '프리셋 이름 교체';

  @override
  String get ebookPresetSaveComplete => '프리셋 저장 완료';

  @override
  String get ebookPresetRenameComplete => '프리셋 이름 교체 완료';

  @override
  String get ebookPresetNameHintExample => '예: 사진 포스터';

  @override
  String get ebookOriginalFileLoadFailed => '원본 파일을 불러오지 못했습니다';

  @override
  String get ebookPhotoLoadFailed => '사진을 불러오지 못했습니다';

  @override
  String ebookBackgroundImagePickFailed(String error) {
    return '배경 이미지 선택 실패: $error';
  }

  @override
  String get ebookBackgroundImageGestureHint => '드래그 이동 · 두 손가락 확대 · 더블 탭 초기화';

  @override
  String get ebookReset => '초기화';

  @override
  String get ebookEffect => '효과';

  @override
  String get ebookGlassMode => '글라스 모드';

  @override
  String get ebookGlassModeSubtitle => '부드러운 유리감과 렌즈 반사를 적용합니다.';

  @override
  String get ebookPresetSectionSubtitle => '현재 조합을 저장해두고 나중에 다시 적용할 수 있습니다.';

  @override
  String get ebookSaveCurrentPreset => '현재 프리셋 저장';

  @override
  String get ebookNoSavedPreset => '저장된 프리셋이 없습니다.';

  @override
  String get ebookTextSection => '문구';

  @override
  String get ebookMainText => '큰 문구';

  @override
  String get ebookSubText => '작은 문구';

  @override
  String get ebookOptional => '선택 사항';

  @override
  String get ebookMainTextWeight => '큰 문구 두께';

  @override
  String get ebookSubTextWeight => '작은 문구 두께';

  @override
  String get ebookTextPosition => '텍스트 위치';

  @override
  String get ebookTextIconColor => '문구 아이콘 색상';

  @override
  String get ebookLightTextModeNotice =>
      '밝은 문구 모드가 켜져 있으면 사진 위에서는 흰색 문구가 우선 적용됩니다.';

  @override
  String get ebookCardStyle => '카드 스타일';

  @override
  String get ebookCardRatio => '카드 비율';

  @override
  String get ebookBackgroundStyle => '배경 스타일';

  @override
  String get ebookBorderStyle => '테두리 스타일';

  @override
  String get ebookBackgroundImage => '배경 이미지';

  @override
  String get ebookBackgroundImageSubtitle =>
      '사진을 넣으면 미리보기 카드에서 직접 위치와 확대를 조절할 수 있습니다.';

  @override
  String get ebookSelectPhoto => '사진 선택';

  @override
  String get ebookDeleteImage => '이미지 삭제';

  @override
  String get ebookResetPosition => '위치 초기화';

  @override
  String get ebookDarkPhotoWhiteText => '어두운 사진용 흰 글자';

  @override
  String get ebookDarkPhotoWhiteTextSubtitle =>
      '사진 배경 위에서 아이콘과 문구를 흰색으로 보여줍니다.';

  @override
  String get ebookIcon => '아이콘';

  @override
  String get ebookShowIcon => '아이콘 보이기';

  @override
  String get ebookIconShape => '아이콘 모양';

  @override
  String get ebookIconPosition => '아이콘 위치';

  @override
  String get ebookSize => '크기';

  @override
  String get ebookThinness => '얇기';

  @override
  String get ebookRatioSquare => '정사각형';

  @override
  String get ebookRatioPortrait => '세로형';

  @override
  String get ebookRatioTall => '긴 세로형';

  @override
  String get ebookRatioLandscape => '가로형';

  @override
  String get ebookRatioWide => '와이드';

  @override
  String get ebookStyleNone => '없음';

  @override
  String get ebookStyleSky => '맑은 하늘';

  @override
  String get ebookStyleSoftPink => '소프트 핑크';

  @override
  String get ebookStyleLightLavender => '라이트 라벤더';

  @override
  String get ebookStyleVanillaCream => '바닐라 크림';

  @override
  String get ebookStyleClearMint => '클리어 민트';

  @override
  String get ebookStyleBrightAurora => '밝은 오로라';

  @override
  String get ebookOptionDefault => '기본';

  @override
  String get ebookOptionWriting => '글쓰기';

  @override
  String get ebookOptionBook => '책';

  @override
  String get ebookOptionDrawing => '드로잉';

  @override
  String get ebookOptionStar => '별';

  @override
  String get ebookOptionHeart => '하트';

  @override
  String get ebookBorderThin => '기본 얇은 테두리';

  @override
  String get ebookBorderThick => '두꺼운 테두리';

  @override
  String get ebookBorderNone => '테두리 없음';

  @override
  String get ebookBorderPastel => '파스텔 테두리';

  @override
  String get ebookBorderDashed => '점선 느낌';

  @override
  String get ebookPosTopLeft => '상단 왼쪽';

  @override
  String get ebookPosTopCenter => '상단 중앙';

  @override
  String get ebookPosTopRight => '상단 오른쪽';

  @override
  String get ebookPosCenterLeft => '중앙 왼쪽';

  @override
  String get ebookPosCenter => '정중앙';

  @override
  String get ebookPosCenterRight => '중앙 오른쪽';

  @override
  String get ebookPosBottomLeft => '하단 왼쪽';

  @override
  String get ebookPosBottomCenter => '하단 중앙';

  @override
  String get ebookPosBottomRight => '하단 오른쪽';

  @override
  String get episodesPageTitle => '회차';

  @override
  String get episodeToggleAll => '전체';

  @override
  String get episodeToggleSelected => '선택';

  @override
  String episodeCountLabel(int count) {
    return '$count개 회차';
  }

  @override
  String get emptySavedEpisodes => '저장된 회차가 없습니다.';

  @override
  String get shareCurrentPage => '지금';

  @override
  String get shareAllPages => '전체';

  @override
  String get shareCustomRange => '직접';

  @override
  String get shareNoFiles => '공유할 파일이 없습니다.';

  @override
  String get shareFailed => '공유 실패';

  @override
  String shareFailedWithReason(String error) {
    return '공유 실패: $error';
  }

  @override
  String get pdfShareComplete => 'PDF 공유 완료';

  @override
  String get pngShareComplete => 'PNG 공유 완료';

  @override
  String get jpgShareComplete => 'JPG 공유 완료';

  @override
  String pdfOpenFailed(String error) {
    return 'PDF 열기 실패: $error';
  }

  @override
  String pdfSavedToApp(String fileName) {
    return '앱에 저장 완료: $fileName';
  }

  @override
  String saveFailedWithReason(String error) {
    return '저장 실패: $error';
  }

  @override
  String pngSaveCompletePath(String path) {
    return 'PNG 저장 완료\n$path';
  }

  @override
  String get pngSaveFailed => 'PNG 저장 실패';

  @override
  String get simpleMemoTitle => '간단 메모';

  @override
  String get selectMemo => '메모 선택';

  @override
  String selectedMemosCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String get selectedMemosDeleteMessage => '선택된 메모를 삭제하시겠습니까?';

  @override
  String get simpleMemoAddTooltip => '새 메모 추가';

  @override
  String get simpleMemoEmptyMain =>
      '저장된 메모가 없습니다.\n오른쪽 상단 + 버튼으로 장르를 선택해 메모를 추가하세요.';

  @override
  String get simpleMemoEmptyGenre => '저장된 메모가 없습니다.\n오른쪽 상단 + 버튼으로 메모를 추가하세요.';

  @override
  String get pdfEmptyContent => '(내용 없음)';

  @override
  String get pdfPreviewDialogTitle => 'PDF 미리보기';

  @override
  String get pdfPreviewConfirm => '미리보기';

  @override
  String get pdfChapterListEmpty => '목차가 없습니다';

  @override
  String get pdfChapterSelectRequired => '회차를 선택해 주세요';

  @override
  String get ebookMainCardCustomize => '메인 카드 꾸미기';

  @override
  String get toolbarKeywordHide => '키워드 숨기기';

  @override
  String get toolbarKeywordOpen => '키워드 열기';

  @override
  String get toolbarSpeechStop => '음성 입력 중지';

  @override
  String get toolbarSpeechInput => '음성 입력';

  @override
  String get toolbarUndo => '실행 취소';

  @override
  String get toolbarRedo => '다시 실행';

  @override
  String get toolbarBold => '굵게';

  @override
  String get toolbarTextColor => '글자 색';

  @override
  String get toolbarTextBackgroundColor => '글자 배경 색';

  @override
  String get toolbarHighlight => '하이라이트';

  @override
  String get toolbarDividerSolid => '구분선(기본)';

  @override
  String get toolbarDividerDashed => '점선 구분선';

  @override
  String get toolbarAlign => '정렬';

  @override
  String get toolbarItalic => '기울임';

  @override
  String get toolbarUnderline => '밑줄';

  @override
  String get toolbarStrikethrough => '취소선';

  @override
  String get toolbarOrderedList => '번호 목록';

  @override
  String get toolbarBulletedList => '글머리 목록';

  @override
  String get toolbarBlockquote => '인용문';

  @override
  String get toolbarClearFormatting => '서식 초기화';

  @override
  String get toolbarImageUpload => '이미지 업로드';

  @override
  String get toolbarFontSize => '글자 크기';

  @override
  String get toolbarClearSize => '크기 해제';

  @override
  String get emailLoginTitle => '이메일 로그인';

  @override
  String get emailLoginGuide => '이메일과 비밀번호를 입력해 주세요';

  @override
  String get password => '비밀번호';

  @override
  String get showPassword => '표시';

  @override
  String get hidePassword => '숨기기';

  @override
  String get login => '로그인';

  @override
  String get signUp => '회원가입';

  @override
  String get emailLoginNotMember => '아직 회원이 아니신가요? ';

  @override
  String get emailLoginFailed => '로그인에 실패했습니다.';

  @override
  String get emailLoginInvalidCredentials => '이메일 또는 비밀번호가 올바르지 않습니다.';

  @override
  String get emailLoginNetworkError => '네트워크 연결을 확인해 주세요.';

  @override
  String get unknownErrorOccurred => '알 수 없는 오류가 발생했습니다.';

  @override
  String get emailSignupTitle => '이메일 회원가입';

  @override
  String get emailSignupCreateAccount => '새 계정을 만들어 주세요';

  @override
  String get emailSignupGuide => '이메일과 비밀번호를 입력해 주세요';

  @override
  String get emailSignupComplete => '회원가입이 완료되었습니다';

  @override
  String get emailSignupFailed => '회원가입에 실패했습니다.';

  @override
  String get emailSignupAlreadyHaveAccount => '이미 계정이 있으신가요? ';
}
