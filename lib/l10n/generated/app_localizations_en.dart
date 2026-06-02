// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get korean => '한국어';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get screenSettings => 'Display Settings';

  @override
  String get defaultValue => 'Default';

  @override
  String get notification => 'Notifications';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get appInfo => 'App Info';

  @override
  String get appDescription => 'AI E-book Tutorial';

  @override
  String get version => 'Version';

  @override
  String get close => 'Close';

  @override
  String get connect => 'Connect';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search';

  @override
  String get accountConnect => 'Connect Account';

  @override
  String get accountConnectMessage =>
      'You can connect your guest account to a login account.';

  @override
  String get connectLoginAccount => 'Connect login account';

  @override
  String get appleAccountConnect => 'Connect Apple account';

  @override
  String get googleAccountConnect => 'Connect Google account';

  @override
  String get emailAccountConnect => 'Connect email account';

  @override
  String get googleAccount => 'Google account';

  @override
  String get appleAccount => 'Apple account';

  @override
  String get emailAccount => 'Email account';

  @override
  String get guestAccount => 'Guest account';

  @override
  String get unknown => 'Unknown';

  @override
  String get guestUser => 'Guest User';

  @override
  String get user => 'User';

  @override
  String get email => 'Email';

  @override
  String get passwordMinLengthHint => 'Password, at least 6 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get allFieldsRequired => 'Please fill in all fields.';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get signInInfoNotFound => 'Sign-in information was not found.';

  @override
  String get accountAlreadyLinked => 'An account is already linked.';

  @override
  String get emailAccountLinked => 'Email account has been linked.';

  @override
  String get appleAccountLinked => 'Apple account has been linked.';

  @override
  String get googleAccountLinked => 'Google account has been linked.';

  @override
  String get emailAlreadyInUse => 'This email is already in use.';

  @override
  String get invalidEmail => 'The email format is invalid.';

  @override
  String get weakPassword => 'The password is too weak.';

  @override
  String get accountConnectFailed => 'Failed to connect account.';

  @override
  String get appleCredentialAlreadyInUse =>
      'This Apple account is already linked to another account.';

  @override
  String get appleProviderAlreadyLinked => 'Apple account is already linked.';

  @override
  String get appleLoginNotEnabled =>
      'Apple sign-in is not enabled in Firebase.';

  @override
  String get appleAccountConnectFailed => 'Failed to connect Apple account.';

  @override
  String get googleCredentialAlreadyInUse =>
      'This Google account is already linked to another account.';

  @override
  String get googleAccountConnectFailed => 'Failed to connect Google account.';

  @override
  String get appTitle => 'AI E-book Tutorial';

  @override
  String get appSubtitle => 'The easiest first step to opening knowledge';

  @override
  String get tryAsGuest => 'Try as guest';

  @override
  String get accountConnectNotice =>
      'You can connect your account anytime in Settings.';

  @override
  String get firebaseInitFailed => '❗ Failed to initialize Firebase';

  @override
  String providerLoginFailed(String provider) {
    return '$provider login failed.';
  }

  @override
  String providerLoginFailedWithReason(String provider, String reason) {
    return '$provider login failed: $reason';
  }

  @override
  String get guestLoginFailed => 'Guest login failed. Please try again later.';

  @override
  String get genreSelect => 'Select Genre';

  @override
  String get genreWebNovel => 'Web Novel';

  @override
  String get genreNovel => 'Novel';

  @override
  String get genrePoetry => 'Poetry';

  @override
  String get genreFreeForm => 'Free Form';

  @override
  String get genreSelfImprovement => 'Self-improvement';

  @override
  String get genreScienceBook => 'Science Book';

  @override
  String get more => 'More';

  @override
  String get logout => 'Log Out';

  @override
  String get speechRecognitionUnavailable =>
      'Speech recognition is not available.';

  @override
  String speechRecognitionError(String error) {
    return 'Speech recognition error: $error';
  }

  @override
  String get keywordAlreadyExists => 'This keyword is already registered.';

  @override
  String get chapterTitleHint => 'Enter chapter title';

  @override
  String get focusWritingModeToggle => 'Toggle focus writing mode';

  @override
  String get exitFocusMode => 'Exit focus mode';

  @override
  String get focusWritingMode => 'Focus writing mode';

  @override
  String get convertPng => 'Convert to PNG';

  @override
  String get pngPreview => 'PNG Preview';

  @override
  String get keywordInputHint => 'Enter keyword';

  @override
  String charCountLabel(int count) {
    return '$count chars';
  }

  @override
  String get character => 'Character';

  @override
  String get characterColor => 'Character Color';

  @override
  String get transparency => 'Transparency';

  @override
  String get clear => 'Clear';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String get addPhoto => '+ Photo';

  @override
  String get tapToAddOrChange => 'Tap: Add / Change';

  @override
  String get name => 'Name';

  @override
  String get birthday => 'Birthday';

  @override
  String get height => 'Height';

  @override
  String get bloodType => 'Blood type';

  @override
  String get blood => 'Blood';

  @override
  String get profile => 'Profile';

  @override
  String get profileUpper => 'PROFILE';

  @override
  String get color => 'color';

  @override
  String get personality => 'Personality';

  @override
  String get personalityKeywords => 'Personality Keywords';

  @override
  String get likesAndDislikes => 'Likes / Dislikes';

  @override
  String get likes => 'Likes';

  @override
  String get dislikes => 'Dislikes';

  @override
  String get bodyAppearance => 'Body / Appearance';

  @override
  String get bodyAppearanceMemo => 'Body / Appearance Memo';

  @override
  String get enterAfterInput => 'Enter after typing';

  @override
  String get keywordEnterAfterInput => 'Enter keyword and press Enter';

  @override
  String get memoEnterAfterInput => 'Enter memo and press Enter';

  @override
  String get noRegisteredItems => 'No items have been registered yet.';

  @override
  String get exampleName => 'e.g. Mumu';

  @override
  String get exampleBirthday => 'e.g. 2005-01-01';

  @override
  String get exampleHeight => 'e.g. 159cm';

  @override
  String get exampleBloodType => 'e.g. O+';

  @override
  String get exampleProfile => 'e.g. Sleeps a lot during the day';

  @override
  String get exampleBodyAppearanceMemo =>
      'e.g. Transparent glowing ears and tail in human form';

  @override
  String get faction => 'Faction';

  @override
  String get addShape => 'Add shape';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get edgeColor => 'Line color';

  @override
  String get replacePhoto => 'Replace photo';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get addPhotoToDiagram => 'Add photo';

  @override
  String get replaceColor => 'Replace color';

  @override
  String get deleteColor => 'Delete color';

  @override
  String get addColor => 'Add color';

  @override
  String get addText => 'Add text';

  @override
  String get replaceText => 'Replace text';

  @override
  String get deleteText => 'Delete text';

  @override
  String get addTextColor => 'Add text color';

  @override
  String get replaceTextColor => 'Replace text color';

  @override
  String get deleteTextColor => 'Delete text color';

  @override
  String get textColor => 'Text color';

  @override
  String get shapeColor => 'Shape color';

  @override
  String get relation => 'Relation';

  @override
  String get relationHint => 'e.g. Alliance, hostility, family';

  @override
  String get moveLocked => 'Move locked';

  @override
  String get moveAvailable => 'Move available';

  @override
  String get factionSelectionHint => 'Select a shape or line.';

  @override
  String get changeShape => 'Change shape';

  @override
  String get lock => 'Lock';

  @override
  String get unlock => 'Unlock';

  @override
  String get deleteShape => 'Delete shape';

  @override
  String get deleteLine => 'Delete line';

  @override
  String get size => 'Size';

  @override
  String get curvature => 'Curvature';

  @override
  String get lineWidth => 'Line width';

  @override
  String get selectColor => 'Select color';

  @override
  String get dashedLine => 'Dashed line';

  @override
  String get arrow => 'Arrow';

  @override
  String get none => 'None';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get bothEnds => 'Both ends';

  @override
  String get insideTextHint => 'Text to display inside the shape';

  @override
  String get nameHint => 'Name';

  @override
  String get newNode => 'New';

  @override
  String get timeline => 'Timeline';

  @override
  String get timelineAdd => 'Add Timeline';

  @override
  String get timelineEdit => 'Edit Timeline';

  @override
  String get timelineEmpty => 'Add a timeline.';

  @override
  String get timelineSeedCreate => 'create';

  @override
  String get timelineSeedCreateOne => 'create 1';

  @override
  String get timelineSeedUnnamed => 'Unnamed';

  @override
  String get timelineSeedEditWord => 'Tap to edit the word';

  @override
  String get timelineSeedReorderColor =>
      'Long-press a color to change its position';

  @override
  String get timelineSeedEditColorName => 'Tap to edit the color name';

  @override
  String get timelineSeedEditContent => 'Tap to edit the content';

  @override
  String get unnamed => 'Unnamed';

  @override
  String get barName => 'Bar name';

  @override
  String get barNameHint => 'e.g. Chapter 1';

  @override
  String get wordDescription => 'Word / Description';

  @override
  String get description => 'Description';

  @override
  String get barColor => 'Bar color';

  @override
  String get worldSeat => 'World Seat';

  @override
  String get glossary => 'Glossary';

  @override
  String get freeMemo => 'Free memo';

  @override
  String get glossaryEmpty => 'Add a glossary term.';

  @override
  String get freeMemoEmpty => 'Add a free memo.';

  @override
  String get noSearchResults => 'No search results.';

  @override
  String get pinAdd => 'Pin';

  @override
  String get pinRemove => 'Unpin';

  @override
  String get term => 'Word';

  @override
  String get glossaryAdd => 'Add Glossary Term';

  @override
  String get glossaryEdit => 'Edit Glossary Term';

  @override
  String get glossaryDeleteTitle => 'Delete glossary term';

  @override
  String get glossaryDeleteMessage =>
      'Do you want to delete this glossary term?';

  @override
  String get memoAdd => 'New memo';

  @override
  String get memoEdit => 'Edit memo';

  @override
  String get memoHint => 'Enter a memo';

  @override
  String get memoDeleteTitle => 'Delete memo';

  @override
  String get memoDeleteMessage => 'Do you want to delete this memo?';

  @override
  String timelineDeleteTitle(String name) {
    return 'Delete $name';
  }

  @override
  String timelineDeleteMessage(String name) {
    return 'Do you want to delete this timeline ($name)?';
  }

  @override
  String get characterDeleteTitle => 'Delete character';

  @override
  String get characterDeleteMessage => 'Do you want to delete this character?';

  @override
  String get protagonistCharacter => 'Protagonist Character';

  @override
  String get supportingCharacter => 'Supporting Character';

  @override
  String get emptyProtagonistCharacters => 'Add a protagonist character.';

  @override
  String get emptySupportingCharacters => 'Add a supporting character.';

  @override
  String get emptyCharacters => 'Add a character.';

  @override
  String get tapToEdit => 'Tap to edit';

  @override
  String get descriptionInputHint => 'Enter a description';

  @override
  String get seedCharacterMainTone => 'Main tone';

  @override
  String get seedCharacterHikaraName => 'Hikara';

  @override
  String get seedCharacterHikaraSpecialNote =>
      'Goal: Find the origin of the elf race.';

  @override
  String get seedCharacterHikaraPersonalityResponsibility => 'Responsible';

  @override
  String get seedCharacterHikaraLikeObservation => 'Observation';

  @override
  String get seedCharacterHikaraLikeOldBooks => 'Ancient books';

  @override
  String get seedCharacterHikaraDislikeIrresponsibility => 'Irresponsibility';

  @override
  String get seedCharacterHikaraPhysicalBlueEyes => 'Blue eyes';

  @override
  String get seedCharacterElixiName => 'Elixi';

  @override
  String get seedCharacterElixiSpecialNote => 'Studies magical herbs.';

  @override
  String get seedCharacterElixiPersonalityCuriosity => 'Curious';

  @override
  String get seedCharacterElixiLikeHerbs => 'Herbs';

  @override
  String get seedCharacterElixiLikePharmacology => 'Pharmacology';

  @override
  String get seedCharacterElixiDislikeBugs => 'Bugs';

  @override
  String get seedCharacterElixiPhysicalGoldenHair => 'Golden hair';

  @override
  String get bookListTitle => 'Book List';

  @override
  String get selectBooks => 'Select Books';

  @override
  String selectedBooksCount(int count) {
    return '$count selected';
  }

  @override
  String get cancelSelection => 'Cancel Selection';

  @override
  String get deleteBooksConfirmTitle => 'Confirm Delete';

  @override
  String get deleteBooksConfirmMessage =>
      'Do you want to delete the selected books?';

  @override
  String get untitledBook => 'Untitled';

  @override
  String get enterBookTitle => 'Enter a title';

  @override
  String get share => 'Share';

  @override
  String get restore => 'Restore';

  @override
  String get preparingPdf => 'Preparing PDF.';

  @override
  String get zipShare => 'Share ZIP';

  @override
  String get creatingZipFile => 'Creating ZIP file.';

  @override
  String get zipNoFiles => 'There are no files to add to the ZIP.';

  @override
  String get zipShareComplete => 'ZIP shared.';

  @override
  String zipShareFailed(String error) {
    return 'Failed to share ZIP: $error';
  }

  @override
  String get selectChapterCoverMessage =>
      'Select an image to use as this chapter cover.';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromAlbum => 'Choose from Album';

  @override
  String get chapterCoverDeleted => 'Chapter cover deleted.';

  @override
  String get chapterCoverSet => 'Chapter cover set.';

  @override
  String get coverFileNotFound => 'Cover file could not be found.';

  @override
  String get selectCoverPhoto => 'Select Cover Photo';

  @override
  String get selectBookCoverMessage =>
      'Select an image to use as the book cover.';

  @override
  String get coverPhotoDeleted => 'Cover photo deleted.';

  @override
  String get coverPhotoSet => 'Cover photo set.';

  @override
  String get preparingBackupZip => 'Preparing backup ZIP file.';

  @override
  String get bookBackupDescription => 'This is a book backup file.';

  @override
  String get shareBackupInstruction =>
      'Choose iCloud Drive or the Files app from the share sheet.';

  @override
  String backupExportFailed(String error) {
    return 'Failed to export backup file: $error';
  }

  @override
  String get selectBackupZipFile => 'Select a backup ZIP file.';

  @override
  String get backupFileReadFailed => 'Could not read the backup file.';

  @override
  String get backupRestoreComplete => 'Backup restored.';

  @override
  String backupRestoreFailed(String error) {
    return 'Failed to restore backup: $error';
  }

  @override
  String get googleDriveSavingZipBackup => 'Saving ZIP backup to Google Drive.';

  @override
  String googleDriveSaveComplete(String savedName) {
    return 'Saved to Google Drive: $savedName';
  }

  @override
  String googleDriveSaveFailed(String error) {
    return 'Failed to save to Google Drive: $error';
  }

  @override
  String get googleDriveNoBackupFiles =>
      'There are no Google Drive backup files.';

  @override
  String get googleDriveImport => 'Import from Google Drive';

  @override
  String get selectBackupFileMessage => 'Select a backup file to import.';

  @override
  String get backupImport => 'Import Backup';

  @override
  String get googleDriveBackupReplaceConfirm =>
      'The current book content will be replaced with the Google Drive backup. Continue?';

  @override
  String get bookBackupJsonNotFound => 'book_backup.json was not found.';

  @override
  String get restoredChapter => 'Restored Chapter';

  @override
  String get googleDriveBackupListLoading =>
      'Loading Google Drive backup list.';

  @override
  String get googleDriveBackupDownloading => 'Downloading Google Drive backup.';

  @override
  String get googleDriveBackupRestoreComplete =>
      'Google Drive backup restored.';

  @override
  String googleDriveRestoreFailed(String error) {
    return 'Failed to import from Google Drive: $error';
  }

  @override
  String get noOtherChapterToSplitEdit =>
      'There are no other chapters to edit together.';

  @override
  String splitSelectChapterTitle(String title) {
    return 'Select a chapter to edit with $title';
  }

  @override
  String get splitEditSaveComplete => 'Split edit saved.';

  @override
  String get splitEdit => 'Split Edit';

  @override
  String get top => 'Top';

  @override
  String get bottom => 'Bottom';

  @override
  String get defaultBookTitle => 'Book Title';

  @override
  String chapterAutoTitle(String title, int number) {
    return '$title Episode $number';
  }

  @override
  String get chapterSaveComplete => 'Chapter saved.';

  @override
  String get chapterDeleteConfirmTitle => 'Confirm Delete';

  @override
  String chapterDeleteConfirmMessage(String title) {
    return 'Do you want to delete “$title”?';
  }

  @override
  String get deletedComplete => 'Deleted.';

  @override
  String get chapterReorder => 'Reorder Chapters';

  @override
  String get reorderModeMessage =>
      'Reorder mode is on. Drag to change the order.';

  @override
  String chapterShareLabel(String title) {
    return 'Share “$title”';
  }

  @override
  String chapterDeleteLabel(String title) {
    return 'Delete “$title”';
  }

  @override
  String get chapterReordering => 'Reordering chapters';

  @override
  String totalChapterCount(int count) {
    return '$count chapters total';
  }

  @override
  String get addChapterHint =>
      'Tap the + button in the top right to add a chapter.';

  @override
  String get addChapterFirst => 'Please add a chapter first.';

  @override
  String get allChapters => 'All Chapters';

  @override
  String get selectedChapters => 'Selected Chapters';

  @override
  String get noSelectedChapters => 'No chapters selected.';

  @override
  String get allChaptersOption => 'All chapters';

  @override
  String get chapters => 'Chapters';

  @override
  String get chapterTitleInput => 'Enter chapter title';

  @override
  String get sortOldestFirst => 'From First Episode';

  @override
  String get sortNewestFirst => 'From Latest Episode';

  @override
  String get memoDeletedComplete => 'Memo deleted.';

  @override
  String get bookMemo => 'Book Memo';

  @override
  String get bookMemoEmptyHint => '+ Add a memo related to this book.';

  @override
  String get memo => 'Memo';

  @override
  String docxImageAlt(String fileName) {
    return '[Image: $fileName]';
  }

  @override
  String get preparingWordFile => 'Preparing MS Word file.';

  @override
  String get wordShareOpened => 'MS Word share sheet opened.';

  @override
  String wordCreateFailed(String error) {
    return 'Failed to create MS Word file: $error';
  }

  @override
  String get preparingTxtFile => 'Preparing TXT file.';

  @override
  String get txtShareOpened => 'TXT file share sheet opened.';

  @override
  String txtCreateFailed(String error) {
    return 'Failed to create TXT file: $error';
  }

  @override
  String get localCloud => 'Local / Cloud';

  @override
  String get iCloudImport => 'Import from iCloud';

  @override
  String get epubForEbook => 'For ePub e-books';

  @override
  String pdfCreateFailed(String error) {
    return 'Failed to create PDF: $error';
  }

  @override
  String get theme => 'Theme';

  @override
  String get font => 'Font';

  @override
  String get defaultFont => 'Default Font';

  @override
  String get batangFont => 'Serif Font';

  @override
  String get gothicFont => 'Sans-serif Font';

  @override
  String get lineSpacing => 'Line Spacing';

  @override
  String get letterSpacing => 'Letter Spacing';

  @override
  String get margin => 'Margin';

  @override
  String get unpinChapter => 'Unpin';

  @override
  String get pinChapter => 'Pin Chapter';

  @override
  String get unpinned => 'Unpinned.';

  @override
  String get chapterPinned => 'Chapter pinned.';

  @override
  String get workIntro => 'Work Introduction';

  @override
  String get workIntroHint =>
      'Briefly introduce the mood, plot, and world of the work.';

  @override
  String get keywords => 'Keywords';

  @override
  String get keywordsHelper => 'Add freely, like #romance #growth #fantasy.';

  @override
  String get emptyKeywords => 'No keywords have been registered yet.';

  @override
  String get keywordInput => 'Enter keyword';

  @override
  String get detailInfo => 'Details';

  @override
  String get authorOriginal => 'Writer / Original Work';

  @override
  String get authorOriginalHint => 'Enter writer / original work information.';

  @override
  String get workCategory => 'Work Category';

  @override
  String get workCategoryHint => 'Enter the work category.';

  @override
  String get ageRating => 'Age Rating';

  @override
  String get ageRatingHint => 'Enter the age rating.';

  @override
  String pageIndicator(int current, int total) {
    return 'Page $current / $total';
  }

  @override
  String chapterMeta(String size, String chars, String date) {
    return '$size · $chars chars · $date';
  }

  @override
  String get penNameHint => 'Pen name';

  @override
  String get bookPreview => 'Book Preview';

  @override
  String get workInfo => 'Work Info';

  @override
  String get allSettings => 'All Settings';

  @override
  String get back => 'Back';

  @override
  String get coverPhotoAdd => '+ Cover Photo';

  @override
  String get example => 'Example';

  @override
  String get settingsPreviewSample =>
      'Build Story\nExample text\nTry changing settings';

  @override
  String get calendarEditSchedule => 'Edit Schedule';

  @override
  String get calendarNewSchedule => 'New Schedule';

  @override
  String get calendarTitleHint => 'Enter a title';

  @override
  String get calendarStartDate => 'Start Date';

  @override
  String get calendarEndDate => 'End Date';

  @override
  String get calendarColor => 'Color';

  @override
  String get calendarMemoHint => 'Enter a memo';

  @override
  String get calendarDeleteSchedule => 'Delete Schedule';

  @override
  String calendarDeleteScheduleConfirm(String title) {
    return 'Do you want to delete “$title”?';
  }

  @override
  String get calendarNoTitle => 'Untitled';

  @override
  String get calendarPickDate => 'Select Date';

  @override
  String get calendarConfirm => 'OK';

  @override
  String get calendarWritingDays => 'Writing Days';

  @override
  String get calendarTodayWritten => 'Today’s Writing';

  @override
  String get calendarTotalChars => 'Total Characters';

  @override
  String get calendarBestRecord => 'Best Record';

  @override
  String calendarDaysValue(int count) {
    return '$count days';
  }

  @override
  String calendarCharsValue(String count) {
    return '$count chars';
  }

  @override
  String calendarBestRecordValue(String chars, String date) {
    return '$chars chars ($date)';
  }

  @override
  String get calendarResetAll => 'Reset All';

  @override
  String get calendarDeleteAllDataConfirm =>
      'Do you want to delete all calendar data?';

  @override
  String get calendarDeleteAllDataMessage =>
      'Schedules / Today’s tasks / Releases / Repeat settings / Writing records will all be deleted.';

  @override
  String get calendarDeleteAll => 'Delete All';

  @override
  String get calendarResetRecord => 'Reset Record';

  @override
  String calendarDeleteDateRecordConfirm(String date) {
    return 'Do you want to delete the record for $date?';
  }

  @override
  String get calendarDeleteDateRecordMessage =>
      'Today’s tasks / Releases / Writing records will all be deleted.';

  @override
  String get calendarNoEvents => 'No schedules registered.';

  @override
  String get calendarTodayTodo => 'Today’s Tasks';

  @override
  String get calendarAdd => 'Add';

  @override
  String get calendarTodoHelper =>
      'Add tasks for today to organize your workflow.';

  @override
  String get calendarReleaseUpload => 'Release [ Upload ]';

  @override
  String get calendarReleaseHelper =>
      'Record upload plans and completions to manage your release cycle.';

  @override
  String calendarMonthlyStats(String month) {
    return 'Monthly Stats [ $month ]';
  }

  @override
  String get calendarResetThisDateRecord => 'Reset This Date’s Record';

  @override
  String get calendarResetAllData => 'Reset All Data';

  @override
  String get calendarTaskHint => 'Enter a task';

  @override
  String get calendarZeroChars => '0 chars';

  @override
  String get calendarUploadTitleHint => 'Enter upload title';

  @override
  String get calendarComplete => 'Complete';

  @override
  String get calendarPlan => 'Planned';

  @override
  String get ebookSaveComplete => 'Saved.';

  @override
  String get ebookDefaultContent => 'Start writing your work here.';

  @override
  String get ebookLatestEpisode => 'Latest Episode';

  @override
  String ebookCountValue(int count) {
    return '$count';
  }

  @override
  String get ebookTodayNoRecord => 'No records registered for today.';

  @override
  String ebookTodaySummary(
    int doneTasks,
    int totalTasks,
    int releaseCount,
    int eventCount,
  ) {
    return 'Tasks $doneTasks/$totalTasks · uploads $releaseCount · schedules $eventCount';
  }

  @override
  String get ebookMainSquareCreateTitle => 'Create New Work';

  @override
  String get ebookMainCardCustomizeSaveComplete =>
      'Main card customization saved.';

  @override
  String get ebookPreset => 'Preset';

  @override
  String get ebookPresetName => 'Preset Name';

  @override
  String ebookPresetDefaultName(int number) {
    return 'Preset $number';
  }

  @override
  String get ebookPresetNameReplace => 'Rename Preset';

  @override
  String get ebookPresetSaveComplete => 'Preset saved.';

  @override
  String get ebookPresetRenameComplete => 'Preset renamed.';

  @override
  String get ebookPresetNameHintExample => 'e.g. Photo Poster';

  @override
  String get ebookOriginalFileLoadFailed => 'Could not load the original file.';

  @override
  String get ebookPhotoLoadFailed => 'Could not load the photo.';

  @override
  String ebookBackgroundImagePickFailed(String error) {
    return 'Background image selection failed: $error';
  }

  @override
  String get ebookBackgroundImageGestureHint =>
      'Drag to move · Pinch to zoom · Double-tap to reset';

  @override
  String get ebookReset => 'Reset';

  @override
  String get ebookEffect => 'Effects';

  @override
  String get ebookGlassMode => 'Glass Mode';

  @override
  String get ebookGlassModeSubtitle =>
      'Applies a soft glass effect and lens reflection.';

  @override
  String get ebookPresetSectionSubtitle =>
      'Save the current combination and apply it again later.';

  @override
  String get ebookSaveCurrentPreset => 'Save Current Preset';

  @override
  String get ebookNoSavedPreset => 'No saved presets.';

  @override
  String get ebookTextSection => 'Text';

  @override
  String get ebookMainText => 'Main Text';

  @override
  String get ebookSubText => 'Sub Text';

  @override
  String get ebookOptional => 'Optional';

  @override
  String get ebookMainTextWeight => 'Main Text Weight';

  @override
  String get ebookSubTextWeight => 'Sub Text Weight';

  @override
  String get ebookTextPosition => 'Text Position';

  @override
  String get ebookTextIconColor => 'Text / Icon Color';

  @override
  String get ebookLightTextModeNotice =>
      'When bright text mode is on, white text is prioritized over photos.';

  @override
  String get ebookCardStyle => 'Card Style';

  @override
  String get ebookCardRatio => 'Card Ratio';

  @override
  String get ebookBackgroundStyle => 'Background Style';

  @override
  String get ebookBorderStyle => 'Border Style';

  @override
  String get ebookBackgroundImage => 'Background Image';

  @override
  String get ebookBackgroundImageSubtitle =>
      'Add a photo, then adjust its position and zoom directly on the preview card.';

  @override
  String get ebookSelectPhoto => 'Select Photo';

  @override
  String get ebookDeleteImage => 'Delete Image';

  @override
  String get ebookResetPosition => 'Reset Position';

  @override
  String get ebookDarkPhotoWhiteText => 'White Text for Dark Photos';

  @override
  String get ebookDarkPhotoWhiteTextSubtitle =>
      'Shows icons and text in white over photo backgrounds.';

  @override
  String get ebookIcon => 'Icon';

  @override
  String get ebookShowIcon => 'Show Icon';

  @override
  String get ebookIconShape => 'Icon Shape';

  @override
  String get ebookIconPosition => 'Icon Position';

  @override
  String get ebookSize => 'Size';

  @override
  String get ebookThinness => 'Thinness';

  @override
  String get ebookRatioSquare => 'Square';

  @override
  String get ebookRatioPortrait => 'Portrait';

  @override
  String get ebookRatioTall => 'Tall Portrait';

  @override
  String get ebookRatioLandscape => 'Landscape';

  @override
  String get ebookRatioWide => 'Wide';

  @override
  String get ebookStyleNone => 'None';

  @override
  String get ebookStyleSky => 'Clear Sky';

  @override
  String get ebookStyleSoftPink => 'Soft Pink';

  @override
  String get ebookStyleLightLavender => 'Light Lavender';

  @override
  String get ebookStyleVanillaCream => 'Vanilla Cream';

  @override
  String get ebookStyleClearMint => 'Clear Mint';

  @override
  String get ebookStyleBrightAurora => 'Bright Aurora';

  @override
  String get ebookOptionDefault => 'Default';

  @override
  String get ebookOptionWriting => 'Writing';

  @override
  String get ebookOptionBook => 'Book';

  @override
  String get ebookOptionDrawing => 'Drawing';

  @override
  String get ebookOptionStar => 'Star';

  @override
  String get ebookOptionHeart => 'Heart';

  @override
  String get ebookBorderThin => 'Default Thin Border';

  @override
  String get ebookBorderThick => 'Thick Border';

  @override
  String get ebookBorderNone => 'No Border';

  @override
  String get ebookBorderPastel => 'Pastel Border';

  @override
  String get ebookBorderDashed => 'Dashed Feel';

  @override
  String get ebookPosTopLeft => 'Top Left';

  @override
  String get ebookPosTopCenter => 'Top Center';

  @override
  String get ebookPosTopRight => 'Top Right';

  @override
  String get ebookPosCenterLeft => 'Center Left';

  @override
  String get ebookPosCenter => 'Center';

  @override
  String get ebookPosCenterRight => 'Center Right';

  @override
  String get ebookPosBottomLeft => 'Bottom Left';

  @override
  String get ebookPosBottomCenter => 'Bottom Center';

  @override
  String get ebookPosBottomRight => 'Bottom Right';

  @override
  String get episodesPageTitle => 'Episodes';

  @override
  String get episodeToggleAll => 'All';

  @override
  String get episodeToggleSelected => 'Selected';

  @override
  String episodeCountLabel(int count) {
    return '$count episodes';
  }

  @override
  String get emptySavedEpisodes => 'No saved episodes.';

  @override
  String get shareCurrentPage => 'Current';

  @override
  String get shareAllPages => 'All';

  @override
  String get shareCustomRange => 'Custom';

  @override
  String get shareNoFiles => 'There are no files to share.';

  @override
  String get shareFailed => 'Sharing failed.';

  @override
  String shareFailedWithReason(String error) {
    return 'Sharing failed: $error';
  }

  @override
  String get pdfShareComplete => 'PDF shared.';

  @override
  String get pngShareComplete => 'PNG shared.';

  @override
  String get jpgShareComplete => 'JPG shared.';

  @override
  String pdfOpenFailed(String error) {
    return 'Failed to open PDF: $error';
  }

  @override
  String pdfSavedToApp(String fileName) {
    return 'Saved to app: $fileName';
  }

  @override
  String saveFailedWithReason(String error) {
    return 'Save failed: $error';
  }

  @override
  String pngSaveCompletePath(String path) {
    return 'Saved PNG files.\n$path';
  }

  @override
  String get pngSaveFailed => 'Failed to save PNG files.';

  @override
  String get simpleMemoTitle => 'Simple Memo';

  @override
  String get selectMemo => 'Select Memos';

  @override
  String selectedMemosCount(int count) {
    return '$count selected';
  }

  @override
  String get selectedMemosDeleteMessage =>
      'Do you want to delete the selected memos?';

  @override
  String get simpleMemoAddTooltip => 'Add new memo';

  @override
  String get simpleMemoEmptyMain =>
      'No memos have been saved.\nTap the + button in the top right to choose a genre and add a memo.';

  @override
  String get simpleMemoEmptyGenre =>
      'No memos have been saved.\nTap the + button in the top right to add a memo.';

  @override
  String get pdfEmptyContent => '(No content)';

  @override
  String get pdfPreviewDialogTitle => 'PDF Preview';

  @override
  String get pdfPreviewConfirm => 'Preview';

  @override
  String get pdfChapterListEmpty => 'There are no chapters.';

  @override
  String get pdfChapterSelectRequired => 'Please select a chapter.';

  @override
  String get ebookMainCardCustomize => 'Customize Main Card';

  @override
  String get toolbarKeywordHide => 'Hide Keywords';

  @override
  String get toolbarKeywordOpen => 'Open Keywords';

  @override
  String get toolbarSpeechStop => 'Stop Voice Input';

  @override
  String get toolbarSpeechInput => 'Voice Input';

  @override
  String get toolbarUndo => 'Undo';

  @override
  String get toolbarRedo => 'Redo';

  @override
  String get toolbarBold => 'Bold';

  @override
  String get toolbarTextColor => 'Text Color';

  @override
  String get toolbarTextBackgroundColor => 'Text Background Color';

  @override
  String get toolbarHighlight => 'Highlight';

  @override
  String get toolbarDividerSolid => 'Divider';

  @override
  String get toolbarDividerDashed => 'Dashed Divider';

  @override
  String get toolbarAlign => 'Align';

  @override
  String get toolbarItalic => 'Italic';

  @override
  String get toolbarUnderline => 'Underline';

  @override
  String get toolbarStrikethrough => 'Strikethrough';

  @override
  String get toolbarOrderedList => 'Numbered List';

  @override
  String get toolbarBulletedList => 'Bulleted List';

  @override
  String get toolbarBlockquote => 'Quote';

  @override
  String get toolbarClearFormatting => 'Clear Formatting';

  @override
  String get toolbarImageUpload => 'Upload Image';

  @override
  String get toolbarFontSize => 'Font Size';

  @override
  String get toolbarClearSize => 'Clear Size';

  @override
  String get emailLoginTitle => 'Email Login';

  @override
  String get emailLoginGuide => 'Please enter your email and password.';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show';

  @override
  String get hidePassword => 'Hide';

  @override
  String get login => 'Log In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get emailLoginNotMember => 'Not a member yet? ';

  @override
  String get emailLoginFailed => 'Login failed.';

  @override
  String get emailLoginInvalidCredentials =>
      'The email or password is incorrect.';

  @override
  String get emailLoginNetworkError => 'Please check your network connection.';

  @override
  String get unknownErrorOccurred => 'An unknown error occurred.';

  @override
  String get emailSignupTitle => 'Email Sign Up';

  @override
  String get emailSignupCreateAccount => 'Create a new account';

  @override
  String get emailSignupGuide => 'Please enter your email and password.';

  @override
  String get emailSignupComplete => 'Sign-up complete.';

  @override
  String get emailSignupFailed => 'Sign-up failed.';

  @override
  String get emailSignupAlreadyHaveAccount => 'Already have an account? ';
}
