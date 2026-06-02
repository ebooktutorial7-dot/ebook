// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get korean => '한국어';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get screenSettings => '画面設定';

  @override
  String get defaultValue => 'デフォルト';

  @override
  String get notification => '通知';

  @override
  String get cloudSync => 'クラウド同期';

  @override
  String get appInfo => 'アプリ情報';

  @override
  String get appDescription => 'AI電子書籍チュートリアル';

  @override
  String get version => 'バージョン';

  @override
  String get close => '閉じる';

  @override
  String get connect => '連携';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get search => '検索';

  @override
  String get accountConnect => 'アカウント連携';

  @override
  String get accountConnectMessage => 'ゲストアカウントをログインアカウントに連携できます。';

  @override
  String get connectLoginAccount => 'ログインアカウントを連携';

  @override
  String get appleAccountConnect => 'Appleアカウントを連携';

  @override
  String get googleAccountConnect => 'Googleアカウントを連携';

  @override
  String get emailAccountConnect => 'メールアカウントを連携';

  @override
  String get googleAccount => 'Googleアカウント';

  @override
  String get appleAccount => 'Appleアカウント';

  @override
  String get emailAccount => 'メールアカウント';

  @override
  String get guestAccount => 'ゲストアカウント';

  @override
  String get unknown => '不明';

  @override
  String get guestUser => 'ゲストユーザー';

  @override
  String get user => 'ユーザー';

  @override
  String get email => 'メールアドレス';

  @override
  String get passwordMinLengthHint => 'パスワード6文字以上';

  @override
  String get confirmPassword => 'パスワード確認';

  @override
  String get allFieldsRequired => 'すべての項目を入力してください。';

  @override
  String get passwordMinLength => 'パスワードは6文字以上で入力してください。';

  @override
  String get passwordMismatch => 'パスワードが一致しません。';

  @override
  String get signInInfoNotFound => 'ログイン情報がありません。';

  @override
  String get accountAlreadyLinked => 'すでにアカウントが連携されています。';

  @override
  String get emailAccountLinked => 'メールアカウントが連携されました。';

  @override
  String get appleAccountLinked => 'Appleアカウントが連携されました。';

  @override
  String get googleAccountLinked => 'Googleアカウントが連携されました。';

  @override
  String get emailAlreadyInUse => 'すでに使用中のメールアドレスです。';

  @override
  String get invalidEmail => 'メールアドレスの形式が正しくありません。';

  @override
  String get weakPassword => 'パスワードが弱すぎます。';

  @override
  String get accountConnectFailed => 'アカウント連携に失敗しました。';

  @override
  String get appleCredentialAlreadyInUse => 'すでに他のアカウントに連携されているAppleアカウントです。';

  @override
  String get appleProviderAlreadyLinked => 'すでにAppleアカウントが連携されています。';

  @override
  String get appleLoginNotEnabled => 'FirebaseでAppleログインが有効になっていません。';

  @override
  String get appleAccountConnectFailed => 'Appleアカウントの連携に失敗しました。';

  @override
  String get googleCredentialAlreadyInUse => 'すでに他のアカウントに連携されているGoogleアカウントです。';

  @override
  String get googleAccountConnectFailed => 'Googleアカウントの連携に失敗しました。';

  @override
  String get appTitle => 'AI電子書籍チュートリアル';

  @override
  String get appSubtitle => '知識を開くいちばん簡単な第一歩';

  @override
  String get tryAsGuest => 'ゲストとして試す';

  @override
  String get accountConnectNotice => 'アカウントは設定からいつでも連携できます。';

  @override
  String get firebaseInitFailed => '❗ Firebaseの初期化に失敗しました';

  @override
  String providerLoginFailed(String provider) {
    return '$providerログインに失敗しました。';
  }

  @override
  String providerLoginFailedWithReason(String provider, String reason) {
    return '$providerログイン失敗: $reason';
  }

  @override
  String get guestLoginFailed => 'ゲストログインに失敗しました。しばらくしてからもう一度お試しください。';

  @override
  String get genreSelect => 'ジャンル選択';

  @override
  String get genreWebNovel => 'ウェブ小説';

  @override
  String get genreNovel => '小説';

  @override
  String get genrePoetry => '詩';

  @override
  String get genreFreeForm => '自由形式';

  @override
  String get genreSelfImprovement => '自己啓発';

  @override
  String get genreScienceBook => '科学書';

  @override
  String get more => 'その他';

  @override
  String get logout => 'ログアウト';

  @override
  String get speechRecognitionUnavailable => '音声認識を使用できません。';

  @override
  String speechRecognitionError(String error) {
    return '音声認識エラー: $error';
  }

  @override
  String get keywordAlreadyExists => 'このキーワードはすでに登録されています。';

  @override
  String get chapterTitleHint => '章タイトルを入力';

  @override
  String get focusWritingModeToggle => '集中執筆モードを切り替え';

  @override
  String get exitFocusMode => '集中モードを終了';

  @override
  String get focusWritingMode => '集中執筆モード';

  @override
  String get convertPng => 'PNGに変換';

  @override
  String get pngPreview => 'PNGプレビュー';

  @override
  String get keywordInputHint => 'キーワードを入力';

  @override
  String charCountLabel(int count) {
    return '$count文字';
  }

  @override
  String get character => 'キャラクター';

  @override
  String get characterColor => 'キャラクター色';

  @override
  String get transparency => '透明度';

  @override
  String get clear => '解除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get apply => '適用';

  @override
  String get addPhoto => '+ 写真';

  @override
  String get tapToAddOrChange => 'タップ：追加 / 変更';

  @override
  String get name => '名前';

  @override
  String get birthday => '誕生日';

  @override
  String get height => '身長';

  @override
  String get bloodType => '血液型';

  @override
  String get blood => '血液型';

  @override
  String get profile => 'プロフィール';

  @override
  String get profileUpper => 'PROFILE';

  @override
  String get color => '色';

  @override
  String get personality => '性格';

  @override
  String get personalityKeywords => '性格キーワード';

  @override
  String get likesAndDislikes => '好き / 嫌い';

  @override
  String get likes => '好きなもの';

  @override
  String get dislikes => '嫌いなもの';

  @override
  String get bodyAppearance => '身体 / 外見';

  @override
  String get bodyAppearanceMemo => '身体 / 外見メモ';

  @override
  String get enterAfterInput => '入力後 Enter';

  @override
  String get keywordEnterAfterInput => 'キーワード入力後 Enter';

  @override
  String get memoEnterAfterInput => 'メモ入力後 Enter';

  @override
  String get noRegisteredItems => 'まだ登録された項目がありません。';

  @override
  String get exampleName => '例）ムム';

  @override
  String get exampleBirthday => '例）2005-01-01';

  @override
  String get exampleHeight => '例）159cm';

  @override
  String get exampleBloodType => '例）O+';

  @override
  String get exampleProfile => '例）昼間はよく眠る';

  @override
  String get exampleBodyAppearanceMemo => '例）人型の時に透明に光る耳と尻尾';

  @override
  String get faction => '勢力';

  @override
  String get addShape => '図形を追加';

  @override
  String get zoomOut => '縮小';

  @override
  String get zoomIn => '拡大';

  @override
  String get edgeColor => '線の色';

  @override
  String get replacePhoto => '写真を変更';

  @override
  String get deletePhoto => '写真を削除';

  @override
  String get addPhotoToDiagram => '写真を追加';

  @override
  String get replaceColor => '色を変更';

  @override
  String get deleteColor => '色を削除';

  @override
  String get addColor => '色を追加';

  @override
  String get addText => 'テキストを追加';

  @override
  String get replaceText => 'テキストを変更';

  @override
  String get deleteText => 'テキストを削除';

  @override
  String get addTextColor => 'テキスト色を追加';

  @override
  String get replaceTextColor => 'テキスト色を変更';

  @override
  String get deleteTextColor => 'テキスト色を削除';

  @override
  String get textColor => 'テキスト色';

  @override
  String get shapeColor => '図形の色';

  @override
  String get relation => '関係';

  @override
  String get relationHint => '例：同盟、敵対、家族';

  @override
  String get moveLocked => '移動ロック中';

  @override
  String get moveAvailable => '移動可能';

  @override
  String get factionSelectionHint => '図形または線を選択してください。';

  @override
  String get changeShape => '図形を変更';

  @override
  String get lock => 'ロック';

  @override
  String get unlock => 'ロック解除';

  @override
  String get deleteShape => '図形を削除';

  @override
  String get deleteLine => '線を削除';

  @override
  String get size => 'サイズ';

  @override
  String get curvature => '曲率';

  @override
  String get lineWidth => '線の太さ';

  @override
  String get selectColor => '色を選択';

  @override
  String get dashedLine => '点線';

  @override
  String get arrow => '矢印';

  @override
  String get none => 'なし';

  @override
  String get start => '開始';

  @override
  String get end => '終了';

  @override
  String get bothEnds => '両端';

  @override
  String get insideTextHint => '図形内に表示するテキスト';

  @override
  String get nameHint => '名前';

  @override
  String get newNode => '新規';

  @override
  String get timeline => 'タイムライン';

  @override
  String get timelineAdd => 'Timelineを追加';

  @override
  String get timelineEdit => 'Timelineを編集';

  @override
  String get timelineEmpty => 'タイムラインを追加してください。';

  @override
  String get timelineSeedCreate => 'create';

  @override
  String get timelineSeedCreateOne => 'create 1';

  @override
  String get timelineSeedUnnamed => 'Unnamed';

  @override
  String get timelineSeedEditWord => 'タップして単語を編集してください';

  @override
  String get timelineSeedReorderColor => '色を長押しして位置を変更してください';

  @override
  String get timelineSeedEditColorName => 'タップして色名を編集してください';

  @override
  String get timelineSeedEditContent => 'タップして内容を編集してください';

  @override
  String get unnamed => '名前なし';

  @override
  String get barName => 'バー名';

  @override
  String get barNameHint => '例）Chapter 1';

  @override
  String get wordDescription => '単語 / 説明';

  @override
  String get description => '説明';

  @override
  String get barColor => 'バー色';

  @override
  String get worldSeat => 'ワールドシート';

  @override
  String get glossary => '用語集';

  @override
  String get freeMemo => '自由メモ';

  @override
  String get glossaryEmpty => '用語を追加してください。';

  @override
  String get freeMemoEmpty => '自由メモを追加してください。';

  @override
  String get noSearchResults => '検索結果がありません。';

  @override
  String get pinAdd => 'ピン留め';

  @override
  String get pinRemove => 'ピン留め解除';

  @override
  String get term => '単語';

  @override
  String get glossaryAdd => '用語を追加';

  @override
  String get glossaryEdit => '用語を編集';

  @override
  String get glossaryDeleteTitle => '用語を削除';

  @override
  String get glossaryDeleteMessage => 'この用語を削除しますか？';

  @override
  String get memoAdd => '新しいメモ';

  @override
  String get memoEdit => 'メモを編集';

  @override
  String get memoHint => 'メモを入力してください';

  @override
  String get memoDeleteTitle => 'メモを削除';

  @override
  String get memoDeleteMessage => 'このメモを削除しますか？';

  @override
  String timelineDeleteTitle(String name) {
    return '$nameを削除';
  }

  @override
  String timelineDeleteMessage(String name) {
    return 'このタイムライン（$name）を削除しますか？';
  }

  @override
  String get characterDeleteTitle => 'キャラクターを削除';

  @override
  String get characterDeleteMessage => 'このキャラクターを削除しますか？';

  @override
  String get protagonistCharacter => '主人公キャラクター';

  @override
  String get supportingCharacter => 'サブキャラクター';

  @override
  String get emptyProtagonistCharacters => '主人公キャラクターを追加してください。';

  @override
  String get emptySupportingCharacters => 'サブキャラクターを追加してください。';

  @override
  String get emptyCharacters => 'キャラクターを追加してください。';

  @override
  String get tapToEdit => 'タップして編集';

  @override
  String get descriptionInputHint => '説明を入力してください';

  @override
  String get seedCharacterMainTone => 'メイントーン';

  @override
  String get seedCharacterHikaraName => 'ヒカラ';

  @override
  String get seedCharacterHikaraSpecialNote => '目標：エルフ種族の起源を探す。';

  @override
  String get seedCharacterHikaraPersonalityResponsibility => '責任感';

  @override
  String get seedCharacterHikaraLikeObservation => '観測';

  @override
  String get seedCharacterHikaraLikeOldBooks => '古書';

  @override
  String get seedCharacterHikaraDislikeIrresponsibility => '無責任';

  @override
  String get seedCharacterHikaraPhysicalBlueEyes => '青い目';

  @override
  String get seedCharacterElixiName => 'エリクシ';

  @override
  String get seedCharacterElixiSpecialNote => '魔法薬草を研究している。';

  @override
  String get seedCharacterElixiPersonalityCuriosity => '好奇心';

  @override
  String get seedCharacterElixiLikeHerbs => '薬草';

  @override
  String get seedCharacterElixiLikePharmacology => '薬学';

  @override
  String get seedCharacterElixiDislikeBugs => '虫';

  @override
  String get seedCharacterElixiPhysicalGoldenHair => '金色の髪';

  @override
  String get bookListTitle => '本の一覧';

  @override
  String get selectBooks => '本を選択';

  @override
  String selectedBooksCount(int count) {
    return '$count件選択中';
  }

  @override
  String get cancelSelection => '選択を解除';

  @override
  String get deleteBooksConfirmTitle => '削除確認';

  @override
  String get deleteBooksConfirmMessage => '選択した本を削除しますか？';

  @override
  String get untitledBook => '無題';

  @override
  String get enterBookTitle => 'タイトルを入力してください';

  @override
  String get share => '共有';

  @override
  String get restore => '読み込み';

  @override
  String get preparingPdf => 'PDFを準備しています。';

  @override
  String get zipShare => 'ZIPを共有';

  @override
  String get creatingZipFile => 'ZIPファイルを作成しています。';

  @override
  String get zipNoFiles => 'ZIPに入れるファイルがありません。';

  @override
  String get zipShareComplete => 'ZIPの共有が完了しました。';

  @override
  String zipShareFailed(String error) {
    return 'ZIPの共有に失敗しました: $error';
  }

  @override
  String get selectChapterCoverMessage => 'この話の表紙として使用する画像を選択してください。';

  @override
  String get takePhoto => 'カメラで撮影';

  @override
  String get chooseFromAlbum => 'アルバムから選択';

  @override
  String get chapterCoverDeleted => '話の表紙を削除しました。';

  @override
  String get chapterCoverSet => '話の表紙を設定しました。';

  @override
  String get coverFileNotFound => '表紙ファイルが見つかりません。';

  @override
  String get selectCoverPhoto => '表紙写真を選択';

  @override
  String get selectBookCoverMessage => '本の表紙として使用する画像を選択してください。';

  @override
  String get coverPhotoDeleted => '表紙写真を削除しました。';

  @override
  String get coverPhotoSet => '表紙写真を設定しました。';

  @override
  String get preparingBackupZip => 'バックアップZIPファイルを準備しています。';

  @override
  String get bookBackupDescription => '本のバックアップファイルです。';

  @override
  String get shareBackupInstruction => '共有画面でiCloud Driveまたはファイルアプリを選択してください。';

  @override
  String backupExportFailed(String error) {
    return 'バックアップファイルの書き出しに失敗しました: $error';
  }

  @override
  String get selectBackupZipFile => 'バックアップZIPファイルを選択してください。';

  @override
  String get backupFileReadFailed => 'バックアップファイルを読み取れません。';

  @override
  String get backupRestoreComplete => 'バックアップの読み込みが完了しました。';

  @override
  String backupRestoreFailed(String error) {
    return 'バックアップの読み込みに失敗しました: $error';
  }

  @override
  String get googleDriveSavingZipBackup => 'Google DriveにZIPバックアップを保存しています。';

  @override
  String googleDriveSaveComplete(String savedName) {
    return 'Google Driveに保存しました: $savedName';
  }

  @override
  String googleDriveSaveFailed(String error) {
    return 'Google Driveへの保存に失敗しました: $error';
  }

  @override
  String get googleDriveNoBackupFiles => 'Google Driveのバックアップファイルがありません。';

  @override
  String get googleDriveImport => 'Google Driveから読み込み';

  @override
  String get selectBackupFileMessage => '読み込むバックアップファイルを選択してください。';

  @override
  String get backupImport => 'バックアップを読み込み';

  @override
  String get googleDriveBackupReplaceConfirm =>
      '現在画面の本の内容がGoogle Driveのバックアップ内容に置き換わります。続行しますか？';

  @override
  String get bookBackupJsonNotFound => 'book_backup.jsonが見つかりません。';

  @override
  String get restoredChapter => '復元された話';

  @override
  String get googleDriveBackupListLoading => 'Google Driveのバックアップ一覧を読み込んでいます。';

  @override
  String get googleDriveBackupDownloading => 'Google Driveのバックアップをダウンロードしています。';

  @override
  String get googleDriveBackupRestoreComplete =>
      'Google Driveバックアップの読み込みが完了しました。';

  @override
  String googleDriveRestoreFailed(String error) {
    return 'Google Driveからの読み込みに失敗しました: $error';
  }

  @override
  String get noOtherChapterToSplitEdit => '一緒に編集する他の話がありません。';

  @override
  String splitSelectChapterTitle(String title) {
    return '$titleと一緒に編集する話を選択';
  }

  @override
  String get splitEditSaveComplete => '分割編集を保存しました。';

  @override
  String get splitEdit => '分割編集';

  @override
  String get top => '上';

  @override
  String get bottom => '下';

  @override
  String get defaultBookTitle => '本のタイトル';

  @override
  String chapterAutoTitle(String title, int number) {
    return '$title 第$number話';
  }

  @override
  String get chapterSaveComplete => '話を保存しました。';

  @override
  String get chapterDeleteConfirmTitle => '削除確認';

  @override
  String chapterDeleteConfirmMessage(String title) {
    return '「$title」を削除しますか？';
  }

  @override
  String get deletedComplete => '削除しました。';

  @override
  String get chapterReorder => '話を並べ替え';

  @override
  String get reorderModeMessage => '移動モードです。ドラッグして順番を変更してください。';

  @override
  String chapterShareLabel(String title) {
    return '「$title」を共有';
  }

  @override
  String chapterDeleteLabel(String title) {
    return '「$title」を削除';
  }

  @override
  String get chapterReordering => '話を移動中';

  @override
  String totalChapterCount(int count) {
    return '全$count話';
  }

  @override
  String get addChapterHint => '右上の+ボタンを押して話を追加してください。';

  @override
  String get addChapterFirst => '先に話を追加してください。';

  @override
  String get allChapters => 'すべての話';

  @override
  String get selectedChapters => '選択した話';

  @override
  String get noSelectedChapters => '選択された話がありません。';

  @override
  String get allChaptersOption => 'すべての話';

  @override
  String get chapters => '話';

  @override
  String get chapterTitleInput => '話タイトルを入力';

  @override
  String get sortOldestFirst => '最初の話から';

  @override
  String get sortNewestFirst => '最新話から';

  @override
  String get memoDeletedComplete => 'メモを削除しました。';

  @override
  String get bookMemo => '本のメモ';

  @override
  String get bookMemoEmptyHint => '+ この本に関するメモを追加してください。';

  @override
  String get memo => 'メモ';

  @override
  String docxImageAlt(String fileName) {
    return '[画像: $fileName]';
  }

  @override
  String get preparingWordFile => 'MS Wordファイルを準備しています。';

  @override
  String get wordShareOpened => 'MS Wordファイルの共有を開きました。';

  @override
  String wordCreateFailed(String error) {
    return 'MS Wordファイルの作成に失敗しました: $error';
  }

  @override
  String get preparingTxtFile => 'TXTファイルを準備しています。';

  @override
  String get txtShareOpened => 'TXTファイルの共有を開きました。';

  @override
  String txtCreateFailed(String error) {
    return 'TXTファイルの作成に失敗しました: $error';
  }

  @override
  String get localCloud => 'ローカル / クラウド';

  @override
  String get iCloudImport => 'iCloudから読み込み';

  @override
  String get epubForEbook => 'ePub電子書籍用';

  @override
  String pdfCreateFailed(String error) {
    return 'PDFの作成に失敗しました: $error';
  }

  @override
  String get theme => 'テーマ';

  @override
  String get font => 'フォント';

  @override
  String get defaultFont => 'デフォルト書体';

  @override
  String get batangFont => '明朝体';

  @override
  String get gothicFont => 'ゴシック体';

  @override
  String get lineSpacing => '行間';

  @override
  String get letterSpacing => '文字間隔';

  @override
  String get margin => '余白';

  @override
  String get unpinChapter => 'ピン留め解除';

  @override
  String get pinChapter => '話をピン留め';

  @override
  String get unpinned => 'ピン留めを解除しました。';

  @override
  String get chapterPinned => '話をピン留めしました。';

  @override
  String get workIntro => '作品紹介';

  @override
  String get workIntroHint => '作品の雰囲気、あらすじ、世界観などを簡単に紹介してください。';

  @override
  String get keywords => 'キーワード';

  @override
  String get keywordsHelper => '#ロマンス #成長物 #ファンタジー のように自由に追加してください。';

  @override
  String get emptyKeywords => 'まだ登録されたキーワードがありません。';

  @override
  String get keywordInput => 'キーワードを入力';

  @override
  String get detailInfo => '詳細情報';

  @override
  String get authorOriginal => '作 / 原作';

  @override
  String get authorOriginalHint => '作 / 原作情報を入力してください。';

  @override
  String get workCategory => '作品分類';

  @override
  String get workCategoryHint => '作品分類を入力してください。';

  @override
  String get ageRating => '年齢レーティング';

  @override
  String get ageRatingHint => '年齢レーティングを入力してください。';

  @override
  String pageIndicator(int current, int total) {
    return 'ページ $current / $total';
  }

  @override
  String chapterMeta(String size, String chars, String date) {
    return '$size · $chars文字 · $date';
  }

  @override
  String get penNameHint => 'ペンネームを入力';

  @override
  String get bookPreview => '本のプレビュー';

  @override
  String get workInfo => '作品情報';

  @override
  String get allSettings => '全体設定';

  @override
  String get back => '戻る';

  @override
  String get coverPhotoAdd => '+ 表紙写真';

  @override
  String get example => '例';

  @override
  String get settingsPreviewSample => 'Build Story\n例文です\n設定を変更してみてください';

  @override
  String get calendarEditSchedule => '予定を編集';

  @override
  String get calendarNewSchedule => '新規予定';

  @override
  String get calendarTitleHint => 'タイトルを入力';

  @override
  String get calendarStartDate => '開始日';

  @override
  String get calendarEndDate => '終了日';

  @override
  String get calendarColor => '色';

  @override
  String get calendarMemoHint => 'メモを入力';

  @override
  String get calendarDeleteSchedule => '予定を削除';

  @override
  String calendarDeleteScheduleConfirm(String title) {
    return '「$title」の予定を削除しますか？';
  }

  @override
  String get calendarNoTitle => '無題';

  @override
  String get calendarPickDate => '日付を選択';

  @override
  String get calendarConfirm => '確認';

  @override
  String get calendarWritingDays => '執筆した日';

  @override
  String get calendarTodayWritten => '今日の執筆';

  @override
  String get calendarTotalChars => '総文字数';

  @override
  String get calendarBestRecord => '最高記録';

  @override
  String calendarDaysValue(int count) {
    return '$count日';
  }

  @override
  String calendarCharsValue(String count) {
    return '$count文字';
  }

  @override
  String calendarBestRecordValue(String chars, String date) {
    return '$chars文字（$date）';
  }

  @override
  String get calendarResetAll => 'すべて初期化';

  @override
  String get calendarDeleteAllDataConfirm => 'すべてのカレンダーデータを削除しますか？';

  @override
  String get calendarDeleteAllDataMessage =>
      '予定 / 今日のタスク / 連載 / 繰り返し設定 / 執筆記録がすべて削除されます。';

  @override
  String get calendarDeleteAll => 'すべて削除';

  @override
  String get calendarResetRecord => '記録を初期化';

  @override
  String calendarDeleteDateRecordConfirm(String date) {
    return '$dateの記録を削除しますか？';
  }

  @override
  String get calendarDeleteDateRecordMessage => '今日のタスク / 連載 / 執筆記録がすべて削除されます。';

  @override
  String get calendarNoEvents => '登録された予定がありません。';

  @override
  String get calendarTodayTodo => '今日のタスク';

  @override
  String get calendarAdd => '追加';

  @override
  String get calendarTodoHelper => '今日やる作業を追加しておくと、作業の流れを整理できます。';

  @override
  String get calendarReleaseUpload => '連載 [ アップロード ]';

  @override
  String get calendarReleaseHelper => 'アップロード予定/完了を記録しておくと、連載周期の管理に役立ちます。';

  @override
  String calendarMonthlyStats(String month) {
    return '月間統計 [ $month ]';
  }

  @override
  String get calendarResetThisDateRecord => 'この日の記録を初期化';

  @override
  String get calendarResetAllData => 'すべてのデータを初期化';

  @override
  String get calendarTaskHint => 'タスクを入力してください';

  @override
  String get calendarZeroChars => '0文字';

  @override
  String get calendarUploadTitleHint => 'アップロードタイトルを入力してください';

  @override
  String get calendarComplete => '完了';

  @override
  String get calendarPlan => '予定';

  @override
  String get ebookSaveComplete => '保存しました。';

  @override
  String get ebookDefaultContent => '作品内容を入力してください';

  @override
  String get ebookLatestEpisode => '最新話';

  @override
  String ebookCountValue(int count) {
    return '$count件';
  }

  @override
  String get ebookTodayNoRecord => '今日登録された記録はありません。';

  @override
  String ebookTodaySummary(
    int doneTasks,
    int totalTasks,
    int releaseCount,
    int eventCount,
  ) {
    return '今日のタスク $doneTasks/$totalTasks · アップロード $releaseCount件 · 予定 $eventCount件';
  }

  @override
  String get ebookMainSquareCreateTitle => '新しい作品を作成';

  @override
  String get ebookMainCardCustomizeSaveComplete => 'メインカードのカスタマイズを保存しました。';

  @override
  String get ebookPreset => 'プリセット';

  @override
  String get ebookPresetName => 'プリセット名';

  @override
  String ebookPresetDefaultName(int number) {
    return 'プリセット $number';
  }

  @override
  String get ebookPresetNameReplace => 'プリセット名を変更';

  @override
  String get ebookPresetSaveComplete => 'プリセットを保存しました。';

  @override
  String get ebookPresetRenameComplete => 'プリセット名を変更しました。';

  @override
  String get ebookPresetNameHintExample => '例：写真ポスター';

  @override
  String get ebookOriginalFileLoadFailed => '元のファイルを読み込めませんでした。';

  @override
  String get ebookPhotoLoadFailed => '写真を読み込めませんでした。';

  @override
  String ebookBackgroundImagePickFailed(String error) {
    return '背景画像の選択に失敗しました: $error';
  }

  @override
  String get ebookBackgroundImageGestureHint =>
      'ドラッグで移動 · 二本指で拡大 · ダブルタップでリセット';

  @override
  String get ebookReset => 'リセット';

  @override
  String get ebookEffect => '効果';

  @override
  String get ebookGlassMode => 'グラスモード';

  @override
  String get ebookGlassModeSubtitle => 'やわらかなガラス感とレンズ反射を適用します。';

  @override
  String get ebookPresetSectionSubtitle => '現在の組み合わせを保存して、後で再適用できます。';

  @override
  String get ebookSaveCurrentPreset => '現在のプリセットを保存';

  @override
  String get ebookNoSavedPreset => '保存されたプリセットがありません。';

  @override
  String get ebookTextSection => '文言';

  @override
  String get ebookMainText => '大きい文言';

  @override
  String get ebookSubText => '小さい文言';

  @override
  String get ebookOptional => '任意';

  @override
  String get ebookMainTextWeight => '大きい文言の太さ';

  @override
  String get ebookSubTextWeight => '小さい文言の太さ';

  @override
  String get ebookTextPosition => 'テキスト位置';

  @override
  String get ebookTextIconColor => '文言 / アイコン色';

  @override
  String get ebookLightTextModeNotice => '明るい文言モードがオンの場合、写真上では白い文言が優先されます。';

  @override
  String get ebookCardStyle => 'カードスタイル';

  @override
  String get ebookCardRatio => 'カード比率';

  @override
  String get ebookBackgroundStyle => '背景スタイル';

  @override
  String get ebookBorderStyle => '枠線スタイル';

  @override
  String get ebookBackgroundImage => '背景画像';

  @override
  String get ebookBackgroundImageSubtitle =>
      '写真を入れると、プレビューカード上で位置と拡大率を直接調整できます。';

  @override
  String get ebookSelectPhoto => '写真を選択';

  @override
  String get ebookDeleteImage => '画像を削除';

  @override
  String get ebookResetPosition => '位置をリセット';

  @override
  String get ebookDarkPhotoWhiteText => '暗い写真用の白文字';

  @override
  String get ebookDarkPhotoWhiteTextSubtitle => '写真背景の上でアイコンと文言を白色で表示します。';

  @override
  String get ebookIcon => 'アイコン';

  @override
  String get ebookShowIcon => 'アイコンを表示';

  @override
  String get ebookIconShape => 'アイコン形状';

  @override
  String get ebookIconPosition => 'アイコン位置';

  @override
  String get ebookSize => 'サイズ';

  @override
  String get ebookThinness => '細さ';

  @override
  String get ebookRatioSquare => '正方形';

  @override
  String get ebookRatioPortrait => '縦型';

  @override
  String get ebookRatioTall => '長い縦型';

  @override
  String get ebookRatioLandscape => '横型';

  @override
  String get ebookRatioWide => 'ワイド';

  @override
  String get ebookStyleNone => 'なし';

  @override
  String get ebookStyleSky => '澄んだ空';

  @override
  String get ebookStyleSoftPink => 'ソフトピンク';

  @override
  String get ebookStyleLightLavender => 'ライトラベンダー';

  @override
  String get ebookStyleVanillaCream => 'バニラクリーム';

  @override
  String get ebookStyleClearMint => 'クリアミント';

  @override
  String get ebookStyleBrightAurora => '明るいオーロラ';

  @override
  String get ebookOptionDefault => 'デフォルト';

  @override
  String get ebookOptionWriting => '執筆';

  @override
  String get ebookOptionBook => '本';

  @override
  String get ebookOptionDrawing => 'ドローイング';

  @override
  String get ebookOptionStar => '星';

  @override
  String get ebookOptionHeart => 'ハート';

  @override
  String get ebookBorderThin => '基本の細い枠線';

  @override
  String get ebookBorderThick => '太い枠線';

  @override
  String get ebookBorderNone => '枠線なし';

  @override
  String get ebookBorderPastel => 'パステル枠線';

  @override
  String get ebookBorderDashed => '点線風';

  @override
  String get ebookPosTopLeft => '上左';

  @override
  String get ebookPosTopCenter => '上中央';

  @override
  String get ebookPosTopRight => '上右';

  @override
  String get ebookPosCenterLeft => '中央左';

  @override
  String get ebookPosCenter => '中央';

  @override
  String get ebookPosCenterRight => '中央右';

  @override
  String get ebookPosBottomLeft => '下左';

  @override
  String get ebookPosBottomCenter => '下中央';

  @override
  String get ebookPosBottomRight => '下右';

  @override
  String get episodesPageTitle => '話';

  @override
  String get episodeToggleAll => 'すべて';

  @override
  String get episodeToggleSelected => '選択';

  @override
  String episodeCountLabel(int count) {
    return '$count話';
  }

  @override
  String get emptySavedEpisodes => '保存された話がありません。';

  @override
  String get shareCurrentPage => '現在';

  @override
  String get shareAllPages => 'すべて';

  @override
  String get shareCustomRange => '指定';

  @override
  String get shareNoFiles => '共有するファイルがありません。';

  @override
  String get shareFailed => '共有に失敗しました。';

  @override
  String shareFailedWithReason(String error) {
    return '共有に失敗しました: $error';
  }

  @override
  String get pdfShareComplete => 'PDFの共有が完了しました。';

  @override
  String get pngShareComplete => 'PNGの共有が完了しました。';

  @override
  String get jpgShareComplete => 'JPGの共有が完了しました。';

  @override
  String pdfOpenFailed(String error) {
    return 'PDFを開けませんでした: $error';
  }

  @override
  String pdfSavedToApp(String fileName) {
    return 'アプリに保存しました: $fileName';
  }

  @override
  String saveFailedWithReason(String error) {
    return '保存に失敗しました: $error';
  }

  @override
  String pngSaveCompletePath(String path) {
    return 'PNGファイルを保存しました。\n$path';
  }

  @override
  String get pngSaveFailed => 'PNGファイルの保存に失敗しました。';

  @override
  String get simpleMemoTitle => '簡単メモ';

  @override
  String get selectMemo => 'メモを選択';

  @override
  String selectedMemosCount(int count) {
    return '$count件選択中';
  }

  @override
  String get selectedMemosDeleteMessage => '選択したメモを削除しますか？';

  @override
  String get simpleMemoAddTooltip => '新しいメモを追加';

  @override
  String get simpleMemoEmptyMain =>
      '保存されたメモがありません。\n右上の+ボタンからジャンルを選択してメモを追加してください。';

  @override
  String get simpleMemoEmptyGenre => '保存されたメモがありません。\n右上の+ボタンからメモを追加してください。';

  @override
  String get pdfEmptyContent => '（内容なし）';

  @override
  String get pdfPreviewDialogTitle => 'PDFプレビュー';

  @override
  String get pdfPreviewConfirm => 'プレビュー';

  @override
  String get pdfChapterListEmpty => '目次がありません。';

  @override
  String get pdfChapterSelectRequired => '話を選択してください。';

  @override
  String get ebookMainCardCustomize => 'メインカードをカスタマイズ';

  @override
  String get toolbarKeywordHide => 'キーワードを隠す';

  @override
  String get toolbarKeywordOpen => 'キーワードを開く';

  @override
  String get toolbarSpeechStop => '音声入力を停止';

  @override
  String get toolbarSpeechInput => '音声入力';

  @override
  String get toolbarUndo => '元に戻す';

  @override
  String get toolbarRedo => 'やり直す';

  @override
  String get toolbarBold => '太字';

  @override
  String get toolbarTextColor => '文字色';

  @override
  String get toolbarTextBackgroundColor => '文字背景色';

  @override
  String get toolbarHighlight => 'ハイライト';

  @override
  String get toolbarDividerSolid => '区切り線';

  @override
  String get toolbarDividerDashed => '点線の区切り線';

  @override
  String get toolbarAlign => '整列';

  @override
  String get toolbarItalic => '斜体';

  @override
  String get toolbarUnderline => '下線';

  @override
  String get toolbarStrikethrough => '取り消し線';

  @override
  String get toolbarOrderedList => '番号付きリスト';

  @override
  String get toolbarBulletedList => '箇条書きリスト';

  @override
  String get toolbarBlockquote => '引用';

  @override
  String get toolbarClearFormatting => '書式をクリア';

  @override
  String get toolbarImageUpload => '画像をアップロード';

  @override
  String get toolbarFontSize => '文字サイズ';

  @override
  String get toolbarClearSize => 'サイズを解除';

  @override
  String get emailLoginTitle => 'メールログイン';

  @override
  String get emailLoginGuide => 'メールアドレスとパスワードを入力してください';

  @override
  String get password => 'パスワード';

  @override
  String get showPassword => '表示';

  @override
  String get hidePassword => '隠す';

  @override
  String get login => 'ログイン';

  @override
  String get signUp => '会員登録';

  @override
  String get emailLoginNotMember => 'まだ会員ではありませんか？ ';

  @override
  String get emailLoginFailed => 'ログインに失敗しました。';

  @override
  String get emailLoginInvalidCredentials => 'メールアドレスまたはパスワードが正しくありません。';

  @override
  String get emailLoginNetworkError => 'ネットワーク接続を確認してください。';

  @override
  String get unknownErrorOccurred => '不明なエラーが発生しました。';

  @override
  String get emailSignupTitle => 'メール会員登録';

  @override
  String get emailSignupCreateAccount => '新しいアカウントを作成してください';

  @override
  String get emailSignupGuide => 'メールアドレスとパスワードを入力してください';

  @override
  String get emailSignupComplete => '会員登録が完了しました';

  @override
  String get emailSignupFailed => '会員登録に失敗しました。';

  @override
  String get emailSignupAlreadyHaveAccount => 'すでにアカウントをお持ちですか？ ';
}
