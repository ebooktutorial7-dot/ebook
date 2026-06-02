import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @korean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In ko, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @screenSettings.
  ///
  /// In ko, this message translates to:
  /// **'화면 설정'**
  String get screenSettings;

  /// No description provided for @defaultValue.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get defaultValue;

  /// No description provided for @notification.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notification;

  /// No description provided for @cloudSync.
  ///
  /// In ko, this message translates to:
  /// **'클라우드 동기화'**
  String get cloudSync;

  /// No description provided for @appInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfo;

  /// No description provided for @appDescription.
  ///
  /// In ko, this message translates to:
  /// **'AI 전자책 튜토리얼'**
  String get appDescription;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @connect.
  ///
  /// In ko, this message translates to:
  /// **'연결'**
  String get connect;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get search;

  /// No description provided for @accountConnect.
  ///
  /// In ko, this message translates to:
  /// **'계정 연결'**
  String get accountConnect;

  /// No description provided for @accountConnectMessage.
  ///
  /// In ko, this message translates to:
  /// **'비회원 계정을 로그인 계정으로 연결할 수 있습니다.'**
  String get accountConnectMessage;

  /// No description provided for @connectLoginAccount.
  ///
  /// In ko, this message translates to:
  /// **'로그인 계정 연결하기'**
  String get connectLoginAccount;

  /// No description provided for @appleAccountConnect.
  ///
  /// In ko, this message translates to:
  /// **'Apple 계정 연결'**
  String get appleAccountConnect;

  /// No description provided for @googleAccountConnect.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정 연결'**
  String get googleAccountConnect;

  /// No description provided for @emailAccountConnect.
  ///
  /// In ko, this message translates to:
  /// **'이메일 계정 연결'**
  String get emailAccountConnect;

  /// No description provided for @googleAccount.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정'**
  String get googleAccount;

  /// No description provided for @appleAccount.
  ///
  /// In ko, this message translates to:
  /// **'Apple 계정'**
  String get appleAccount;

  /// No description provided for @emailAccount.
  ///
  /// In ko, this message translates to:
  /// **'이메일 계정'**
  String get emailAccount;

  /// No description provided for @guestAccount.
  ///
  /// In ko, this message translates to:
  /// **'비회원 계정'**
  String get guestAccount;

  /// No description provided for @unknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없음'**
  String get unknown;

  /// No description provided for @guestUser.
  ///
  /// In ko, this message translates to:
  /// **'비회원 사용자'**
  String get guestUser;

  /// No description provided for @user.
  ///
  /// In ko, this message translates to:
  /// **'사용자'**
  String get user;

  /// No description provided for @email.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get email;

  /// No description provided for @passwordMinLengthHint.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 6자 이상'**
  String get passwordMinLengthHint;

  /// No description provided for @confirmPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 확인'**
  String get confirmPassword;

  /// No description provided for @allFieldsRequired.
  ///
  /// In ko, this message translates to:
  /// **'모든 항목을 입력해 주세요.'**
  String get allFieldsRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호는 6자 이상이어야 합니다.'**
  String get passwordMinLength;

  /// No description provided for @passwordMismatch.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 일치하지 않습니다.'**
  String get passwordMismatch;

  /// No description provided for @signInInfoNotFound.
  ///
  /// In ko, this message translates to:
  /// **'로그인 정보가 없습니다.'**
  String get signInInfoNotFound;

  /// No description provided for @accountAlreadyLinked.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 연결되어 있습니다.'**
  String get accountAlreadyLinked;

  /// No description provided for @emailAccountLinked.
  ///
  /// In ko, this message translates to:
  /// **'이메일 계정이 연결되었습니다.'**
  String get emailAccountLinked;

  /// No description provided for @appleAccountLinked.
  ///
  /// In ko, this message translates to:
  /// **'Apple 계정이 연결되었습니다.'**
  String get appleAccountLinked;

  /// No description provided for @googleAccountLinked.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정이 연결되었습니다.'**
  String get googleAccountLinked;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In ko, this message translates to:
  /// **'이미 사용 중인 이메일입니다.'**
  String get emailAlreadyInUse;

  /// No description provided for @invalidEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일 형식이 올바르지 않습니다.'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호가 너무 약합니다.'**
  String get weakPassword;

  /// No description provided for @accountConnectFailed.
  ///
  /// In ko, this message translates to:
  /// **'계정 연결에 실패했습니다.'**
  String get accountConnectFailed;

  /// No description provided for @appleCredentialAlreadyInUse.
  ///
  /// In ko, this message translates to:
  /// **'이미 다른 계정에 연결된 Apple 계정입니다.'**
  String get appleCredentialAlreadyInUse;

  /// No description provided for @appleProviderAlreadyLinked.
  ///
  /// In ko, this message translates to:
  /// **'이미 Apple 계정이 연결되어 있습니다.'**
  String get appleProviderAlreadyLinked;

  /// No description provided for @appleLoginNotEnabled.
  ///
  /// In ko, this message translates to:
  /// **'Firebase에서 Apple 로그인이 활성화되어 있지 않습니다.'**
  String get appleLoginNotEnabled;

  /// No description provided for @appleAccountConnectFailed.
  ///
  /// In ko, this message translates to:
  /// **'Apple 계정 연결에 실패했습니다.'**
  String get appleAccountConnectFailed;

  /// No description provided for @googleCredentialAlreadyInUse.
  ///
  /// In ko, this message translates to:
  /// **'이미 다른 계정에 연결된 Google 계정입니다.'**
  String get googleCredentialAlreadyInUse;

  /// No description provided for @googleAccountConnectFailed.
  ///
  /// In ko, this message translates to:
  /// **'Google 계정 연결에 실패했습니다.'**
  String get googleAccountConnectFailed;

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 전자책 튜토리얼'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'지식을 여는 가장 쉬운 첫걸음'**
  String get appSubtitle;

  /// No description provided for @tryAsGuest.
  ///
  /// In ko, this message translates to:
  /// **'비회원으로 체험하기'**
  String get tryAsGuest;

  /// No description provided for @accountConnectNotice.
  ///
  /// In ko, this message translates to:
  /// **'계정은 설정에서 언제든 연결하실 수 있습니다.'**
  String get accountConnectNotice;

  /// No description provided for @firebaseInitFailed.
  ///
  /// In ko, this message translates to:
  /// **'❗ Firebase 초기화 실패'**
  String get firebaseInitFailed;

  /// No description provided for @providerLoginFailed.
  ///
  /// In ko, this message translates to:
  /// **'{provider} 로그인에 실패했습니다.'**
  String providerLoginFailed(String provider);

  /// No description provided for @providerLoginFailedWithReason.
  ///
  /// In ko, this message translates to:
  /// **'{provider} 로그인 실패: {reason}'**
  String providerLoginFailedWithReason(String provider, String reason);

  /// No description provided for @guestLoginFailed.
  ///
  /// In ko, this message translates to:
  /// **'비회원 로그인에 실패했습니다. 잠시 후 다시 시도해 주세요.'**
  String get guestLoginFailed;

  /// No description provided for @genreSelect.
  ///
  /// In ko, this message translates to:
  /// **'장르 선택'**
  String get genreSelect;

  /// No description provided for @genreWebNovel.
  ///
  /// In ko, this message translates to:
  /// **'웹 소설'**
  String get genreWebNovel;

  /// No description provided for @genreNovel.
  ///
  /// In ko, this message translates to:
  /// **'소설'**
  String get genreNovel;

  /// No description provided for @genrePoetry.
  ///
  /// In ko, this message translates to:
  /// **'시'**
  String get genrePoetry;

  /// No description provided for @genreFreeForm.
  ///
  /// In ko, this message translates to:
  /// **'자유 서식'**
  String get genreFreeForm;

  /// No description provided for @genreSelfImprovement.
  ///
  /// In ko, this message translates to:
  /// **'자기 계발'**
  String get genreSelfImprovement;

  /// No description provided for @genreScienceBook.
  ///
  /// In ko, this message translates to:
  /// **'과학 책'**
  String get genreScienceBook;

  /// No description provided for @more.
  ///
  /// In ko, this message translates to:
  /// **'더보기'**
  String get more;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @speechRecognitionUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식을 사용할 수 없습니다.'**
  String get speechRecognitionUnavailable;

  /// No description provided for @speechRecognitionError.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식 오류: {error}'**
  String speechRecognitionError(String error);

  /// No description provided for @keywordAlreadyExists.
  ///
  /// In ko, this message translates to:
  /// **'이미 등록된 키워드입니다.'**
  String get keywordAlreadyExists;

  /// No description provided for @chapterTitleHint.
  ///
  /// In ko, this message translates to:
  /// **'회차 제목 입력'**
  String get chapterTitleHint;

  /// No description provided for @focusWritingModeToggle.
  ///
  /// In ko, this message translates to:
  /// **'집중 글쓰기 모드 토글'**
  String get focusWritingModeToggle;

  /// No description provided for @exitFocusMode.
  ///
  /// In ko, this message translates to:
  /// **'집중 모드 해제'**
  String get exitFocusMode;

  /// No description provided for @focusWritingMode.
  ///
  /// In ko, this message translates to:
  /// **'집중 글쓰기 모드'**
  String get focusWritingMode;

  /// No description provided for @convertPng.
  ///
  /// In ko, this message translates to:
  /// **'PNG 변환'**
  String get convertPng;

  /// No description provided for @pngPreview.
  ///
  /// In ko, this message translates to:
  /// **'PNG 미리보기'**
  String get pngPreview;

  /// No description provided for @keywordInputHint.
  ///
  /// In ko, this message translates to:
  /// **'키워드 입력'**
  String get keywordInputHint;

  /// No description provided for @charCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'{count}자'**
  String charCountLabel(int count);

  /// No description provided for @character.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터'**
  String get character;

  /// No description provided for @characterColor.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터 색상'**
  String get characterColor;

  /// No description provided for @transparency.
  ///
  /// In ko, this message translates to:
  /// **'투명도'**
  String get transparency;

  /// No description provided for @clear.
  ///
  /// In ko, this message translates to:
  /// **'해제'**
  String get clear;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In ko, this message translates to:
  /// **'적용'**
  String get apply;

  /// No description provided for @addPhoto.
  ///
  /// In ko, this message translates to:
  /// **'+ 사진'**
  String get addPhoto;

  /// No description provided for @tapToAddOrChange.
  ///
  /// In ko, this message translates to:
  /// **'탭 : 추가/변경'**
  String get tapToAddOrChange;

  /// No description provided for @name.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get name;

  /// No description provided for @birthday.
  ///
  /// In ko, this message translates to:
  /// **'생일'**
  String get birthday;

  /// No description provided for @height.
  ///
  /// In ko, this message translates to:
  /// **'키'**
  String get height;

  /// No description provided for @bloodType.
  ///
  /// In ko, this message translates to:
  /// **'혈액형'**
  String get bloodType;

  /// No description provided for @blood.
  ///
  /// In ko, this message translates to:
  /// **'혈액형'**
  String get blood;

  /// No description provided for @profile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profile;

  /// No description provided for @profileUpper.
  ///
  /// In ko, this message translates to:
  /// **'PROFILE'**
  String get profileUpper;

  /// No description provided for @color.
  ///
  /// In ko, this message translates to:
  /// **'색상'**
  String get color;

  /// No description provided for @personality.
  ///
  /// In ko, this message translates to:
  /// **'성격'**
  String get personality;

  /// No description provided for @personalityKeywords.
  ///
  /// In ko, this message translates to:
  /// **'성격 키워드'**
  String get personalityKeywords;

  /// No description provided for @likesAndDislikes.
  ///
  /// In ko, this message translates to:
  /// **'좋아/싫어'**
  String get likesAndDislikes;

  /// No description provided for @likes.
  ///
  /// In ko, this message translates to:
  /// **'좋아하는 것'**
  String get likes;

  /// No description provided for @dislikes.
  ///
  /// In ko, this message translates to:
  /// **'싫어하는 것'**
  String get dislikes;

  /// No description provided for @bodyAppearance.
  ///
  /// In ko, this message translates to:
  /// **'신체 / 외형'**
  String get bodyAppearance;

  /// No description provided for @bodyAppearanceMemo.
  ///
  /// In ko, this message translates to:
  /// **'신체 / 외형 메모'**
  String get bodyAppearanceMemo;

  /// No description provided for @enterAfterInput.
  ///
  /// In ko, this message translates to:
  /// **'입력 후 Enter'**
  String get enterAfterInput;

  /// No description provided for @keywordEnterAfterInput.
  ///
  /// In ko, this message translates to:
  /// **'키워드 입력 후 Enter'**
  String get keywordEnterAfterInput;

  /// No description provided for @memoEnterAfterInput.
  ///
  /// In ko, this message translates to:
  /// **'메모 입력 후 Enter'**
  String get memoEnterAfterInput;

  /// No description provided for @noRegisteredItems.
  ///
  /// In ko, this message translates to:
  /// **'아직 등록된 항목이 없습니다.'**
  String get noRegisteredItems;

  /// No description provided for @exampleName.
  ///
  /// In ko, this message translates to:
  /// **'예) 무무'**
  String get exampleName;

  /// No description provided for @exampleBirthday.
  ///
  /// In ko, this message translates to:
  /// **'예) 2005-01-01'**
  String get exampleBirthday;

  /// No description provided for @exampleHeight.
  ///
  /// In ko, this message translates to:
  /// **'예) 159cm'**
  String get exampleHeight;

  /// No description provided for @exampleBloodType.
  ///
  /// In ko, this message translates to:
  /// **'예) O+'**
  String get exampleBloodType;

  /// No description provided for @exampleProfile.
  ///
  /// In ko, this message translates to:
  /// **'예) 낮에는 잠이 많음'**
  String get exampleProfile;

  /// No description provided for @exampleBodyAppearanceMemo.
  ///
  /// In ko, this message translates to:
  /// **'예) 인간형일 때 투명하게 빛나는 귀와 꼬리'**
  String get exampleBodyAppearanceMemo;

  /// No description provided for @faction.
  ///
  /// In ko, this message translates to:
  /// **'세력'**
  String get faction;

  /// No description provided for @addShape.
  ///
  /// In ko, this message translates to:
  /// **'도형 추가'**
  String get addShape;

  /// No description provided for @zoomOut.
  ///
  /// In ko, this message translates to:
  /// **'축소'**
  String get zoomOut;

  /// No description provided for @zoomIn.
  ///
  /// In ko, this message translates to:
  /// **'확대'**
  String get zoomIn;

  /// No description provided for @edgeColor.
  ///
  /// In ko, this message translates to:
  /// **'선 색상'**
  String get edgeColor;

  /// No description provided for @replacePhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 교체'**
  String get replacePhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 삭제'**
  String get deletePhoto;

  /// No description provided for @addPhotoToDiagram.
  ///
  /// In ko, this message translates to:
  /// **'사진 추가'**
  String get addPhotoToDiagram;

  /// No description provided for @replaceColor.
  ///
  /// In ko, this message translates to:
  /// **'색상 교체'**
  String get replaceColor;

  /// No description provided for @deleteColor.
  ///
  /// In ko, this message translates to:
  /// **'색상 삭제'**
  String get deleteColor;

  /// No description provided for @addColor.
  ///
  /// In ko, this message translates to:
  /// **'색상 추가'**
  String get addColor;

  /// No description provided for @addText.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 추가'**
  String get addText;

  /// No description provided for @replaceText.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 교체'**
  String get replaceText;

  /// No description provided for @deleteText.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 삭제'**
  String get deleteText;

  /// No description provided for @addTextColor.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 색상 추가'**
  String get addTextColor;

  /// No description provided for @replaceTextColor.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 색상 교체'**
  String get replaceTextColor;

  /// No description provided for @deleteTextColor.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 색상 삭제'**
  String get deleteTextColor;

  /// No description provided for @textColor.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 색상'**
  String get textColor;

  /// No description provided for @shapeColor.
  ///
  /// In ko, this message translates to:
  /// **'도형 색상'**
  String get shapeColor;

  /// No description provided for @relation.
  ///
  /// In ko, this message translates to:
  /// **'관계'**
  String get relation;

  /// No description provided for @relationHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 동맹, 적대, 가족'**
  String get relationHint;

  /// No description provided for @moveLocked.
  ///
  /// In ko, this message translates to:
  /// **'이동 잠김'**
  String get moveLocked;

  /// No description provided for @moveAvailable.
  ///
  /// In ko, this message translates to:
  /// **'이동 가능'**
  String get moveAvailable;

  /// No description provided for @factionSelectionHint.
  ///
  /// In ko, this message translates to:
  /// **'도형 또는 선을 선택해 주세요.'**
  String get factionSelectionHint;

  /// No description provided for @changeShape.
  ///
  /// In ko, this message translates to:
  /// **'도형 변경'**
  String get changeShape;

  /// No description provided for @lock.
  ///
  /// In ko, this message translates to:
  /// **'잠금'**
  String get lock;

  /// No description provided for @unlock.
  ///
  /// In ko, this message translates to:
  /// **'잠금 해제'**
  String get unlock;

  /// No description provided for @deleteShape.
  ///
  /// In ko, this message translates to:
  /// **'도형 삭제'**
  String get deleteShape;

  /// No description provided for @deleteLine.
  ///
  /// In ko, this message translates to:
  /// **'선 삭제'**
  String get deleteLine;

  /// No description provided for @size.
  ///
  /// In ko, this message translates to:
  /// **'크기'**
  String get size;

  /// No description provided for @curvature.
  ///
  /// In ko, this message translates to:
  /// **'곡률'**
  String get curvature;

  /// No description provided for @lineWidth.
  ///
  /// In ko, this message translates to:
  /// **'선 굵기'**
  String get lineWidth;

  /// No description provided for @selectColor.
  ///
  /// In ko, this message translates to:
  /// **'색상 선택'**
  String get selectColor;

  /// No description provided for @dashedLine.
  ///
  /// In ko, this message translates to:
  /// **'점선'**
  String get dashedLine;

  /// No description provided for @arrow.
  ///
  /// In ko, this message translates to:
  /// **'화살표'**
  String get arrow;

  /// No description provided for @none.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get none;

  /// No description provided for @start.
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get start;

  /// No description provided for @end.
  ///
  /// In ko, this message translates to:
  /// **'끝'**
  String get end;

  /// No description provided for @bothEnds.
  ///
  /// In ko, this message translates to:
  /// **'양쪽'**
  String get bothEnds;

  /// No description provided for @insideTextHint.
  ///
  /// In ko, this message translates to:
  /// **'도형 안에 표시할 텍스트'**
  String get insideTextHint;

  /// No description provided for @nameHint.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get nameHint;

  /// No description provided for @newNode.
  ///
  /// In ko, this message translates to:
  /// **'새 항목'**
  String get newNode;

  /// No description provided for @timeline.
  ///
  /// In ko, this message translates to:
  /// **'타임라인'**
  String get timeline;

  /// No description provided for @timelineAdd.
  ///
  /// In ko, this message translates to:
  /// **'Timeline 추가'**
  String get timelineAdd;

  /// No description provided for @timelineEdit.
  ///
  /// In ko, this message translates to:
  /// **'Timeline 편집'**
  String get timelineEdit;

  /// No description provided for @timelineEmpty.
  ///
  /// In ko, this message translates to:
  /// **'타임라인을 추가해 보세요.'**
  String get timelineEmpty;

  /// No description provided for @timelineSeedCreate.
  ///
  /// In ko, this message translates to:
  /// **'create'**
  String get timelineSeedCreate;

  /// No description provided for @timelineSeedCreateOne.
  ///
  /// In ko, this message translates to:
  /// **'create 1'**
  String get timelineSeedCreateOne;

  /// No description provided for @timelineSeedUnnamed.
  ///
  /// In ko, this message translates to:
  /// **'Unnamed'**
  String get timelineSeedUnnamed;

  /// No description provided for @timelineSeedEditWord.
  ///
  /// In ko, this message translates to:
  /// **'탭 하여 단어를 편집해 보세요'**
  String get timelineSeedEditWord;

  /// No description provided for @timelineSeedReorderColor.
  ///
  /// In ko, this message translates to:
  /// **'색상을 길게 탭 하여 위치를 바꿔보세요'**
  String get timelineSeedReorderColor;

  /// No description provided for @timelineSeedEditColorName.
  ///
  /// In ko, this message translates to:
  /// **'탭 하여 색상 이름을 편집해 보세요'**
  String get timelineSeedEditColorName;

  /// No description provided for @timelineSeedEditContent.
  ///
  /// In ko, this message translates to:
  /// **'탭 하여 내용을 편집해 보세요'**
  String get timelineSeedEditContent;

  /// No description provided for @unnamed.
  ///
  /// In ko, this message translates to:
  /// **'이름 없음'**
  String get unnamed;

  /// No description provided for @barName.
  ///
  /// In ko, this message translates to:
  /// **'바 이름'**
  String get barName;

  /// No description provided for @barNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예) Chapter 1'**
  String get barNameHint;

  /// No description provided for @wordDescription.
  ///
  /// In ko, this message translates to:
  /// **'단어 / 설명'**
  String get wordDescription;

  /// No description provided for @description.
  ///
  /// In ko, this message translates to:
  /// **'설명'**
  String get description;

  /// No description provided for @barColor.
  ///
  /// In ko, this message translates to:
  /// **'바 색상'**
  String get barColor;

  /// No description provided for @worldSeat.
  ///
  /// In ko, this message translates to:
  /// **'월드 시트'**
  String get worldSeat;

  /// No description provided for @glossary.
  ///
  /// In ko, this message translates to:
  /// **'용어집'**
  String get glossary;

  /// No description provided for @freeMemo.
  ///
  /// In ko, this message translates to:
  /// **'자유 메모'**
  String get freeMemo;

  /// No description provided for @glossaryEmpty.
  ///
  /// In ko, this message translates to:
  /// **'용어를 추가해 보세요.'**
  String get glossaryEmpty;

  /// No description provided for @freeMemoEmpty.
  ///
  /// In ko, this message translates to:
  /// **'자유 메모를 추가해 보세요.'**
  String get freeMemoEmpty;

  /// No description provided for @noSearchResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없습니다.'**
  String get noSearchResults;

  /// No description provided for @pinAdd.
  ///
  /// In ko, this message translates to:
  /// **'핀 추가'**
  String get pinAdd;

  /// No description provided for @pinRemove.
  ///
  /// In ko, this message translates to:
  /// **'핀 해제'**
  String get pinRemove;

  /// No description provided for @term.
  ///
  /// In ko, this message translates to:
  /// **'단어'**
  String get term;

  /// No description provided for @glossaryAdd.
  ///
  /// In ko, this message translates to:
  /// **'용어 추가'**
  String get glossaryAdd;

  /// No description provided for @glossaryEdit.
  ///
  /// In ko, this message translates to:
  /// **'용어 편집'**
  String get glossaryEdit;

  /// No description provided for @glossaryDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'용어 삭제'**
  String get glossaryDeleteTitle;

  /// No description provided for @glossaryDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 용어를 삭제하시겠습니까?'**
  String get glossaryDeleteMessage;

  /// No description provided for @memoAdd.
  ///
  /// In ko, this message translates to:
  /// **'새 메모'**
  String get memoAdd;

  /// No description provided for @memoEdit.
  ///
  /// In ko, this message translates to:
  /// **'메모 편집'**
  String get memoEdit;

  /// No description provided for @memoHint.
  ///
  /// In ko, this message translates to:
  /// **'메모를 입력하세요'**
  String get memoHint;

  /// No description provided for @memoDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'메모 삭제'**
  String get memoDeleteTitle;

  /// No description provided for @memoDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 메모를 삭제하시겠습니까?'**
  String get memoDeleteMessage;

  /// No description provided for @timelineDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name} 삭제'**
  String timelineDeleteTitle(String name);

  /// No description provided for @timelineDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 타임라인({name})을 삭제하시겠습니까?'**
  String timelineDeleteMessage(String name);

  /// No description provided for @characterDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터 삭제'**
  String get characterDeleteTitle;

  /// No description provided for @characterDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 캐릭터를 삭제하시겠습니까?'**
  String get characterDeleteMessage;

  /// No description provided for @protagonistCharacter.
  ///
  /// In ko, this message translates to:
  /// **'주인공 캐릭터'**
  String get protagonistCharacter;

  /// No description provided for @supportingCharacter.
  ///
  /// In ko, this message translates to:
  /// **'조연 캐릭터'**
  String get supportingCharacter;

  /// No description provided for @emptyProtagonistCharacters.
  ///
  /// In ko, this message translates to:
  /// **'주인공 캐릭터를 추가해 보세요.'**
  String get emptyProtagonistCharacters;

  /// No description provided for @emptySupportingCharacters.
  ///
  /// In ko, this message translates to:
  /// **'조연 캐릭터를 추가해 보세요.'**
  String get emptySupportingCharacters;

  /// No description provided for @emptyCharacters.
  ///
  /// In ko, this message translates to:
  /// **'캐릭터를 추가해 보세요.'**
  String get emptyCharacters;

  /// No description provided for @tapToEdit.
  ///
  /// In ko, this message translates to:
  /// **'탭하여 편집'**
  String get tapToEdit;

  /// No description provided for @descriptionInputHint.
  ///
  /// In ko, this message translates to:
  /// **'설명을 입력하세요'**
  String get descriptionInputHint;

  /// No description provided for @seedCharacterMainTone.
  ///
  /// In ko, this message translates to:
  /// **'메인 톤'**
  String get seedCharacterMainTone;

  /// No description provided for @seedCharacterHikaraName.
  ///
  /// In ko, this message translates to:
  /// **'히카라'**
  String get seedCharacterHikaraName;

  /// No description provided for @seedCharacterHikaraSpecialNote.
  ///
  /// In ko, this message translates to:
  /// **'목표: 엘프 종족의 근원을 찾는다.'**
  String get seedCharacterHikaraSpecialNote;

  /// No description provided for @seedCharacterHikaraPersonalityResponsibility.
  ///
  /// In ko, this message translates to:
  /// **'책임감'**
  String get seedCharacterHikaraPersonalityResponsibility;

  /// No description provided for @seedCharacterHikaraLikeObservation.
  ///
  /// In ko, this message translates to:
  /// **'관측'**
  String get seedCharacterHikaraLikeObservation;

  /// No description provided for @seedCharacterHikaraLikeOldBooks.
  ///
  /// In ko, this message translates to:
  /// **'고서'**
  String get seedCharacterHikaraLikeOldBooks;

  /// No description provided for @seedCharacterHikaraDislikeIrresponsibility.
  ///
  /// In ko, this message translates to:
  /// **'무책임'**
  String get seedCharacterHikaraDislikeIrresponsibility;

  /// No description provided for @seedCharacterHikaraPhysicalBlueEyes.
  ///
  /// In ko, this message translates to:
  /// **'푸른 눈'**
  String get seedCharacterHikaraPhysicalBlueEyes;

  /// No description provided for @seedCharacterElixiName.
  ///
  /// In ko, this message translates to:
  /// **'엘릭시'**
  String get seedCharacterElixiName;

  /// No description provided for @seedCharacterElixiSpecialNote.
  ///
  /// In ko, this message translates to:
  /// **'마법 약초를 연구한다.'**
  String get seedCharacterElixiSpecialNote;

  /// No description provided for @seedCharacterElixiPersonalityCuriosity.
  ///
  /// In ko, this message translates to:
  /// **'호기심'**
  String get seedCharacterElixiPersonalityCuriosity;

  /// No description provided for @seedCharacterElixiLikeHerbs.
  ///
  /// In ko, this message translates to:
  /// **'약초'**
  String get seedCharacterElixiLikeHerbs;

  /// No description provided for @seedCharacterElixiLikePharmacology.
  ///
  /// In ko, this message translates to:
  /// **'약학'**
  String get seedCharacterElixiLikePharmacology;

  /// No description provided for @seedCharacterElixiDislikeBugs.
  ///
  /// In ko, this message translates to:
  /// **'벌레'**
  String get seedCharacterElixiDislikeBugs;

  /// No description provided for @seedCharacterElixiPhysicalGoldenHair.
  ///
  /// In ko, this message translates to:
  /// **'금빛 머리카락'**
  String get seedCharacterElixiPhysicalGoldenHair;

  /// No description provided for @bookListTitle.
  ///
  /// In ko, this message translates to:
  /// **'책 목록'**
  String get bookListTitle;

  /// No description provided for @selectBooks.
  ///
  /// In ko, this message translates to:
  /// **'책 선택'**
  String get selectBooks;

  /// No description provided for @selectedBooksCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택됨'**
  String selectedBooksCount(int count);

  /// No description provided for @cancelSelection.
  ///
  /// In ko, this message translates to:
  /// **'선택 취소'**
  String get cancelSelection;

  /// No description provided for @deleteBooksConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'삭제 확인'**
  String get deleteBooksConfirmTitle;

  /// No description provided for @deleteBooksConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'선택된 책을 삭제하시겠습니까?'**
  String get deleteBooksConfirmMessage;

  /// No description provided for @untitledBook.
  ///
  /// In ko, this message translates to:
  /// **'제목 없음'**
  String get untitledBook;

  /// No description provided for @enterBookTitle.
  ///
  /// In ko, this message translates to:
  /// **'제목을 입력하세요'**
  String get enterBookTitle;

  /// No description provided for @share.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get share;

  /// No description provided for @restore.
  ///
  /// In ko, this message translates to:
  /// **'불러오기'**
  String get restore;

  /// No description provided for @preparingPdf.
  ///
  /// In ko, this message translates to:
  /// **'PDF를 준비 중입니다'**
  String get preparingPdf;

  /// No description provided for @zipShare.
  ///
  /// In ko, this message translates to:
  /// **'ZIP 공유'**
  String get zipShare;

  /// No description provided for @creatingZipFile.
  ///
  /// In ko, this message translates to:
  /// **'ZIP 파일을 만드는 중입니다'**
  String get creatingZipFile;

  /// No description provided for @zipNoFiles.
  ///
  /// In ko, this message translates to:
  /// **'ZIP에 넣을 파일이 없습니다'**
  String get zipNoFiles;

  /// No description provided for @zipShareComplete.
  ///
  /// In ko, this message translates to:
  /// **'ZIP 공유 완료'**
  String get zipShareComplete;

  /// No description provided for @zipShareFailed.
  ///
  /// In ko, this message translates to:
  /// **'ZIP 공유 실패: {error}'**
  String zipShareFailed(String error);

  /// No description provided for @selectChapterCoverMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 회차 표지로 사용할 이미지를 선택하세요.'**
  String get selectChapterCoverMessage;

  /// No description provided for @takePhoto.
  ///
  /// In ko, this message translates to:
  /// **'카메라로 촬영'**
  String get takePhoto;

  /// No description provided for @chooseFromAlbum.
  ///
  /// In ko, this message translates to:
  /// **'앨범에서 선택'**
  String get chooseFromAlbum;

  /// No description provided for @chapterCoverDeleted.
  ///
  /// In ko, this message translates to:
  /// **'이 회차 표지가 삭제되었습니다'**
  String get chapterCoverDeleted;

  /// No description provided for @chapterCoverSet.
  ///
  /// In ko, this message translates to:
  /// **'회차 표지가 설정되었습니다'**
  String get chapterCoverSet;

  /// No description provided for @coverFileNotFound.
  ///
  /// In ko, this message translates to:
  /// **'표지 파일을 찾을 수 없습니다'**
  String get coverFileNotFound;

  /// No description provided for @selectCoverPhoto.
  ///
  /// In ko, this message translates to:
  /// **'표지 사진 선택'**
  String get selectCoverPhoto;

  /// No description provided for @selectBookCoverMessage.
  ///
  /// In ko, this message translates to:
  /// **'책 표지로 사용할 이미지를 선택하세요.'**
  String get selectBookCoverMessage;

  /// No description provided for @coverPhotoDeleted.
  ///
  /// In ko, this message translates to:
  /// **'표지 사진이 삭제되었습니다'**
  String get coverPhotoDeleted;

  /// No description provided for @coverPhotoSet.
  ///
  /// In ko, this message translates to:
  /// **'표지 사진이 설정되었습니다'**
  String get coverPhotoSet;

  /// No description provided for @preparingBackupZip.
  ///
  /// In ko, this message translates to:
  /// **'백업 ZIP 파일을 준비 중입니다'**
  String get preparingBackupZip;

  /// No description provided for @bookBackupDescription.
  ///
  /// In ko, this message translates to:
  /// **'책 백업 파일입니다.'**
  String get bookBackupDescription;

  /// No description provided for @shareBackupInstruction.
  ///
  /// In ko, this message translates to:
  /// **'공유 화면에서 iCloud Drive 또는 파일 앱을 선택하세요'**
  String get shareBackupInstruction;

  /// No description provided for @backupExportFailed.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일 내보내기 실패: {error}'**
  String backupExportFailed(String error);

  /// No description provided for @selectBackupZipFile.
  ///
  /// In ko, this message translates to:
  /// **'백업 ZIP 파일을 선택하세요'**
  String get selectBackupZipFile;

  /// No description provided for @backupFileReadFailed.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일을 읽을 수 없습니다'**
  String get backupFileReadFailed;

  /// No description provided for @backupRestoreComplete.
  ///
  /// In ko, this message translates to:
  /// **'백업 불러오기 완료'**
  String get backupRestoreComplete;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In ko, this message translates to:
  /// **'백업 불러오기 실패: {error}'**
  String backupRestoreFailed(String error);

  /// No description provided for @googleDriveSavingZipBackup.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive에 ZIP 백업 저장 중입니다'**
  String get googleDriveSavingZipBackup;

  /// No description provided for @googleDriveSaveComplete.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive 저장 완료: {savedName}'**
  String googleDriveSaveComplete(String savedName);

  /// No description provided for @googleDriveSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive 저장 실패: {error}'**
  String googleDriveSaveFailed(String error);

  /// No description provided for @googleDriveNoBackupFiles.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive 백업 파일이 없습니다'**
  String get googleDriveNoBackupFiles;

  /// No description provided for @googleDriveImport.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive 불러오기'**
  String get googleDriveImport;

  /// No description provided for @selectBackupFileMessage.
  ///
  /// In ko, this message translates to:
  /// **'불러올 백업 파일을 선택하세요.'**
  String get selectBackupFileMessage;

  /// No description provided for @backupImport.
  ///
  /// In ko, this message translates to:
  /// **'백업 불러오기'**
  String get backupImport;

  /// No description provided for @googleDriveBackupReplaceConfirm.
  ///
  /// In ko, this message translates to:
  /// **'현재 화면의 책 내용이 Google Drive 백업 내용으로 교체됩니다. 계속하시겠습니까?'**
  String get googleDriveBackupReplaceConfirm;

  /// No description provided for @bookBackupJsonNotFound.
  ///
  /// In ko, this message translates to:
  /// **'book_backup.json을 찾을 수 없습니다'**
  String get bookBackupJsonNotFound;

  /// No description provided for @restoredChapter.
  ///
  /// In ko, this message translates to:
  /// **'복원된 회차'**
  String get restoredChapter;

  /// No description provided for @googleDriveBackupListLoading.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive 백업 목록을 불러오는 중입니다'**
  String get googleDriveBackupListLoading;

  /// No description provided for @googleDriveBackupDownloading.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive 백업을 다운로드 중입니다'**
  String get googleDriveBackupDownloading;

  /// No description provided for @googleDriveBackupRestoreComplete.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive 백업 불러오기 완료'**
  String get googleDriveBackupRestoreComplete;

  /// No description provided for @googleDriveRestoreFailed.
  ///
  /// In ko, this message translates to:
  /// **'Google Drive 불러오기 실패: {error}'**
  String googleDriveRestoreFailed(String error);

  /// No description provided for @noOtherChapterToSplitEdit.
  ///
  /// In ko, this message translates to:
  /// **'같이 편집할 다른 회차가 없습니다'**
  String get noOtherChapterToSplitEdit;

  /// No description provided for @splitSelectChapterTitle.
  ///
  /// In ko, this message translates to:
  /// **'{title}와 같이 편집할 회차 선택'**
  String splitSelectChapterTitle(String title);

  /// No description provided for @splitEditSaveComplete.
  ///
  /// In ko, this message translates to:
  /// **'분할 편집 저장 완료'**
  String get splitEditSaveComplete;

  /// No description provided for @splitEdit.
  ///
  /// In ko, this message translates to:
  /// **'분할 편집'**
  String get splitEdit;

  /// No description provided for @top.
  ///
  /// In ko, this message translates to:
  /// **'위쪽'**
  String get top;

  /// No description provided for @bottom.
  ///
  /// In ko, this message translates to:
  /// **'아래쪽'**
  String get bottom;

  /// No description provided for @defaultBookTitle.
  ///
  /// In ko, this message translates to:
  /// **'책 제목'**
  String get defaultBookTitle;

  /// No description provided for @chapterAutoTitle.
  ///
  /// In ko, this message translates to:
  /// **'{title} {number}화'**
  String chapterAutoTitle(String title, int number);

  /// No description provided for @chapterSaveComplete.
  ///
  /// In ko, this message translates to:
  /// **'회차 저장 완료'**
  String get chapterSaveComplete;

  /// No description provided for @chapterDeleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'삭제 확인'**
  String get chapterDeleteConfirmTitle;

  /// No description provided for @chapterDeleteConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'‘{title}’ 회차를 삭제하시겠습니까?'**
  String chapterDeleteConfirmMessage(String title);

  /// No description provided for @deletedComplete.
  ///
  /// In ko, this message translates to:
  /// **'삭제되었습니다'**
  String get deletedComplete;

  /// No description provided for @chapterReorder.
  ///
  /// In ko, this message translates to:
  /// **'회차 이동'**
  String get chapterReorder;

  /// No description provided for @reorderModeMessage.
  ///
  /// In ko, this message translates to:
  /// **'이동 모드입니다. 드래그하여 순서를 바꾸세요'**
  String get reorderModeMessage;

  /// No description provided for @chapterShareLabel.
  ///
  /// In ko, this message translates to:
  /// **'‘{title}’ 공유'**
  String chapterShareLabel(String title);

  /// No description provided for @chapterDeleteLabel.
  ///
  /// In ko, this message translates to:
  /// **'‘{title}’ 삭제'**
  String chapterDeleteLabel(String title);

  /// No description provided for @chapterReordering.
  ///
  /// In ko, this message translates to:
  /// **'회차 이동 중'**
  String get chapterReordering;

  /// No description provided for @totalChapterCount.
  ///
  /// In ko, this message translates to:
  /// **'전체 {count}회'**
  String totalChapterCount(int count);

  /// No description provided for @addChapterHint.
  ///
  /// In ko, this message translates to:
  /// **'우측 상단의 + 버튼을 눌러 회차를 추가하세요.'**
  String get addChapterHint;

  /// No description provided for @addChapterFirst.
  ///
  /// In ko, this message translates to:
  /// **'먼저 회차를 추가해 주세요'**
  String get addChapterFirst;

  /// No description provided for @allChapters.
  ///
  /// In ko, this message translates to:
  /// **'전체 회차'**
  String get allChapters;

  /// No description provided for @selectedChapters.
  ///
  /// In ko, this message translates to:
  /// **'선택 회차'**
  String get selectedChapters;

  /// No description provided for @noSelectedChapters.
  ///
  /// In ko, this message translates to:
  /// **'선택된 회차가 없습니다'**
  String get noSelectedChapters;

  /// No description provided for @allChaptersOption.
  ///
  /// In ko, this message translates to:
  /// **'모든 회차'**
  String get allChaptersOption;

  /// No description provided for @chapters.
  ///
  /// In ko, this message translates to:
  /// **'회차'**
  String get chapters;

  /// No description provided for @chapterTitleInput.
  ///
  /// In ko, this message translates to:
  /// **'회차 제목 입력'**
  String get chapterTitleInput;

  /// No description provided for @sortOldestFirst.
  ///
  /// In ko, this message translates to:
  /// **'첫화부터'**
  String get sortOldestFirst;

  /// No description provided for @sortNewestFirst.
  ///
  /// In ko, this message translates to:
  /// **'마지막화부터'**
  String get sortNewestFirst;

  /// No description provided for @memoDeletedComplete.
  ///
  /// In ko, this message translates to:
  /// **'메모가 삭제되었습니다'**
  String get memoDeletedComplete;

  /// No description provided for @bookMemo.
  ///
  /// In ko, this message translates to:
  /// **'책 메모'**
  String get bookMemo;

  /// No description provided for @bookMemoEmptyHint.
  ///
  /// In ko, this message translates to:
  /// **'+ 이 책과 관련된 메모를 추가해 보세요.'**
  String get bookMemoEmptyHint;

  /// No description provided for @memo.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get memo;

  /// No description provided for @docxImageAlt.
  ///
  /// In ko, this message translates to:
  /// **'[이미지: {fileName}]'**
  String docxImageAlt(String fileName);

  /// No description provided for @preparingWordFile.
  ///
  /// In ko, this message translates to:
  /// **'MS Word 파일을 준비 중입니다'**
  String get preparingWordFile;

  /// No description provided for @wordShareOpened.
  ///
  /// In ko, this message translates to:
  /// **'MS Word 파일 공유를 열었습니다'**
  String get wordShareOpened;

  /// No description provided for @wordCreateFailed.
  ///
  /// In ko, this message translates to:
  /// **'MS Word 파일 생성 실패: {error}'**
  String wordCreateFailed(String error);

  /// No description provided for @preparingTxtFile.
  ///
  /// In ko, this message translates to:
  /// **'TXT 파일을 준비 중입니다'**
  String get preparingTxtFile;

  /// No description provided for @txtShareOpened.
  ///
  /// In ko, this message translates to:
  /// **'TXT 파일 공유를 열었습니다'**
  String get txtShareOpened;

  /// No description provided for @txtCreateFailed.
  ///
  /// In ko, this message translates to:
  /// **'TXT 파일 생성 실패: {error}'**
  String txtCreateFailed(String error);

  /// No description provided for @localCloud.
  ///
  /// In ko, this message translates to:
  /// **'로컬 / 클라우드'**
  String get localCloud;

  /// No description provided for @iCloudImport.
  ///
  /// In ko, this message translates to:
  /// **'iCloud 불러오기'**
  String get iCloudImport;

  /// No description provided for @epubForEbook.
  ///
  /// In ko, this message translates to:
  /// **'ePub 전자책용'**
  String get epubForEbook;

  /// No description provided for @pdfCreateFailed.
  ///
  /// In ko, this message translates to:
  /// **'PDF 생성 실패: {error}'**
  String pdfCreateFailed(String error);

  /// No description provided for @theme.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get theme;

  /// No description provided for @font.
  ///
  /// In ko, this message translates to:
  /// **'폰트'**
  String get font;

  /// No description provided for @defaultFont.
  ///
  /// In ko, this message translates to:
  /// **'기본체'**
  String get defaultFont;

  /// No description provided for @batangFont.
  ///
  /// In ko, this message translates to:
  /// **'바탕체'**
  String get batangFont;

  /// No description provided for @gothicFont.
  ///
  /// In ko, this message translates to:
  /// **'고딕체'**
  String get gothicFont;

  /// No description provided for @lineSpacing.
  ///
  /// In ko, this message translates to:
  /// **'줄 간격'**
  String get lineSpacing;

  /// No description provided for @letterSpacing.
  ///
  /// In ko, this message translates to:
  /// **'글 간격'**
  String get letterSpacing;

  /// No description provided for @margin.
  ///
  /// In ko, this message translates to:
  /// **'여백'**
  String get margin;

  /// No description provided for @unpinChapter.
  ///
  /// In ko, this message translates to:
  /// **'고정 해제'**
  String get unpinChapter;

  /// No description provided for @pinChapter.
  ///
  /// In ko, this message translates to:
  /// **'회차 고정'**
  String get pinChapter;

  /// No description provided for @unpinned.
  ///
  /// In ko, this message translates to:
  /// **'고정 해제됨'**
  String get unpinned;

  /// No description provided for @chapterPinned.
  ///
  /// In ko, this message translates to:
  /// **'회차 고정됨'**
  String get chapterPinned;

  /// No description provided for @workIntro.
  ///
  /// In ko, this message translates to:
  /// **'작품 소개'**
  String get workIntro;

  /// No description provided for @workIntroHint.
  ///
  /// In ko, this message translates to:
  /// **'작품의 분위기, 줄거리, 세계관 등을 간단히 소개해 주세요.'**
  String get workIntroHint;

  /// No description provided for @keywords.
  ///
  /// In ko, this message translates to:
  /// **'키워드'**
  String get keywords;

  /// No description provided for @keywordsHelper.
  ///
  /// In ko, this message translates to:
  /// **'#로맨스 #성장물 #판타지 처럼 자유롭게 추가하세요.'**
  String get keywordsHelper;

  /// No description provided for @emptyKeywords.
  ///
  /// In ko, this message translates to:
  /// **'아직 등록된 키워드가 없습니다.'**
  String get emptyKeywords;

  /// No description provided for @keywordInput.
  ///
  /// In ko, this message translates to:
  /// **'키워드 입력'**
  String get keywordInput;

  /// No description provided for @detailInfo.
  ///
  /// In ko, this message translates to:
  /// **'상세 정보'**
  String get detailInfo;

  /// No description provided for @authorOriginal.
  ///
  /// In ko, this message translates to:
  /// **'글 / 원작'**
  String get authorOriginal;

  /// No description provided for @authorOriginalHint.
  ///
  /// In ko, this message translates to:
  /// **'글 / 원작 정보를 입력하세요.'**
  String get authorOriginalHint;

  /// No description provided for @workCategory.
  ///
  /// In ko, this message translates to:
  /// **'작품 분류'**
  String get workCategory;

  /// No description provided for @workCategoryHint.
  ///
  /// In ko, this message translates to:
  /// **'작품 분류를 입력하세요.'**
  String get workCategoryHint;

  /// No description provided for @ageRating.
  ///
  /// In ko, this message translates to:
  /// **'연령 등급'**
  String get ageRating;

  /// No description provided for @ageRatingHint.
  ///
  /// In ko, this message translates to:
  /// **'연령 등급을 입력하세요.'**
  String get ageRatingHint;

  /// No description provided for @pageIndicator.
  ///
  /// In ko, this message translates to:
  /// **'페이지 {current} / {total}'**
  String pageIndicator(int current, int total);

  /// No description provided for @chapterMeta.
  ///
  /// In ko, this message translates to:
  /// **'{size} · {chars}자 · {date}'**
  String chapterMeta(String size, String chars, String date);

  /// No description provided for @penNameHint.
  ///
  /// In ko, this message translates to:
  /// **'필명 작성'**
  String get penNameHint;

  /// No description provided for @bookPreview.
  ///
  /// In ko, this message translates to:
  /// **'책 미리보기'**
  String get bookPreview;

  /// No description provided for @workInfo.
  ///
  /// In ko, this message translates to:
  /// **'작품 정보'**
  String get workInfo;

  /// No description provided for @allSettings.
  ///
  /// In ko, this message translates to:
  /// **'전체 설정'**
  String get allSettings;

  /// No description provided for @back.
  ///
  /// In ko, this message translates to:
  /// **'뒤로가기'**
  String get back;

  /// No description provided for @coverPhotoAdd.
  ///
  /// In ko, this message translates to:
  /// **'+ 표지 사진'**
  String get coverPhotoAdd;

  /// No description provided for @example.
  ///
  /// In ko, this message translates to:
  /// **'예시'**
  String get example;

  /// No description provided for @settingsPreviewSample.
  ///
  /// In ko, this message translates to:
  /// **'Build Story\n예시 글 입니다\n설정을 바꿔보세요'**
  String get settingsPreviewSample;

  /// No description provided for @calendarEditSchedule.
  ///
  /// In ko, this message translates to:
  /// **'일정 편집'**
  String get calendarEditSchedule;

  /// No description provided for @calendarNewSchedule.
  ///
  /// In ko, this message translates to:
  /// **'신규 일정'**
  String get calendarNewSchedule;

  /// No description provided for @calendarTitleHint.
  ///
  /// In ko, this message translates to:
  /// **'제목 입력'**
  String get calendarTitleHint;

  /// No description provided for @calendarStartDate.
  ///
  /// In ko, this message translates to:
  /// **'시작일'**
  String get calendarStartDate;

  /// No description provided for @calendarEndDate.
  ///
  /// In ko, this message translates to:
  /// **'종료일'**
  String get calendarEndDate;

  /// No description provided for @calendarColor.
  ///
  /// In ko, this message translates to:
  /// **'색상'**
  String get calendarColor;

  /// No description provided for @calendarMemoHint.
  ///
  /// In ko, this message translates to:
  /// **'메모 입력'**
  String get calendarMemoHint;

  /// No description provided for @calendarDeleteSchedule.
  ///
  /// In ko, this message translates to:
  /// **'일정 삭제'**
  String get calendarDeleteSchedule;

  /// No description provided for @calendarDeleteScheduleConfirm.
  ///
  /// In ko, this message translates to:
  /// **'“{title}” 일정을 삭제하시겠습니까?'**
  String calendarDeleteScheduleConfirm(String title);

  /// No description provided for @calendarNoTitle.
  ///
  /// In ko, this message translates to:
  /// **'제목 없음'**
  String get calendarNoTitle;

  /// No description provided for @calendarPickDate.
  ///
  /// In ko, this message translates to:
  /// **'날짜 선택'**
  String get calendarPickDate;

  /// No description provided for @calendarConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get calendarConfirm;

  /// No description provided for @calendarWritingDays.
  ///
  /// In ko, this message translates to:
  /// **'집필한 날'**
  String get calendarWritingDays;

  /// No description provided for @calendarTodayWritten.
  ///
  /// In ko, this message translates to:
  /// **'오늘 작성'**
  String get calendarTodayWritten;

  /// No description provided for @calendarTotalChars.
  ///
  /// In ko, this message translates to:
  /// **'총 글자수'**
  String get calendarTotalChars;

  /// No description provided for @calendarBestRecord.
  ///
  /// In ko, this message translates to:
  /// **'최고 기록'**
  String get calendarBestRecord;

  /// No description provided for @calendarDaysValue.
  ///
  /// In ko, this message translates to:
  /// **'{count}일'**
  String calendarDaysValue(int count);

  /// No description provided for @calendarCharsValue.
  ///
  /// In ko, this message translates to:
  /// **'{count}자'**
  String calendarCharsValue(String count);

  /// No description provided for @calendarBestRecordValue.
  ///
  /// In ko, this message translates to:
  /// **'{chars}자 ({date})'**
  String calendarBestRecordValue(String chars, String date);

  /// No description provided for @calendarResetAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 초기화'**
  String get calendarResetAll;

  /// No description provided for @calendarDeleteAllDataConfirm.
  ///
  /// In ko, this message translates to:
  /// **'모든 캘린더 데이터를 삭제하시겠습니까?'**
  String get calendarDeleteAllDataConfirm;

  /// No description provided for @calendarDeleteAllDataMessage.
  ///
  /// In ko, this message translates to:
  /// **'일정 / 오늘 할 일 / 연재 / 반복 설정 / 집필 기록이 모두 삭제됩니다.'**
  String get calendarDeleteAllDataMessage;

  /// No description provided for @calendarDeleteAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 삭제'**
  String get calendarDeleteAll;

  /// No description provided for @calendarResetRecord.
  ///
  /// In ko, this message translates to:
  /// **'기록 초기화'**
  String get calendarResetRecord;

  /// No description provided for @calendarDeleteDateRecordConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{date} 기록을 삭제하시겠습니까?'**
  String calendarDeleteDateRecordConfirm(String date);

  /// No description provided for @calendarDeleteDateRecordMessage.
  ///
  /// In ko, this message translates to:
  /// **'오늘 할 일 / 연재 / 집필 기록이 모두 삭제됩니다.'**
  String get calendarDeleteDateRecordMessage;

  /// No description provided for @calendarNoEvents.
  ///
  /// In ko, this message translates to:
  /// **'등록된 일정이 없습니다.'**
  String get calendarNoEvents;

  /// No description provided for @calendarTodayTodo.
  ///
  /// In ko, this message translates to:
  /// **'오늘 할 일'**
  String get calendarTodayTodo;

  /// No description provided for @calendarAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get calendarAdd;

  /// No description provided for @calendarTodoHelper.
  ///
  /// In ko, this message translates to:
  /// **'오늘 해야 할 작업을 추가해두면, 작업 흐름이 정리됩니다.'**
  String get calendarTodoHelper;

  /// No description provided for @calendarReleaseUpload.
  ///
  /// In ko, this message translates to:
  /// **'연재 [ 업로드 ]'**
  String get calendarReleaseUpload;

  /// No description provided for @calendarReleaseHelper.
  ///
  /// In ko, this message translates to:
  /// **'업로드 계획/완료를 기록해두면, 연재 주기 관리에 도움이 됩니다.'**
  String get calendarReleaseHelper;

  /// No description provided for @calendarMonthlyStats.
  ///
  /// In ko, this message translates to:
  /// **'월 통계 [ {month} ]'**
  String calendarMonthlyStats(String month);

  /// No description provided for @calendarResetThisDateRecord.
  ///
  /// In ko, this message translates to:
  /// **'이 날짜 기록 초기화'**
  String get calendarResetThisDateRecord;

  /// No description provided for @calendarResetAllData.
  ///
  /// In ko, this message translates to:
  /// **'전체 데이터 초기화'**
  String get calendarResetAllData;

  /// No description provided for @calendarTaskHint.
  ///
  /// In ko, this message translates to:
  /// **'할 일을 입력하세요'**
  String get calendarTaskHint;

  /// No description provided for @calendarZeroChars.
  ///
  /// In ko, this message translates to:
  /// **'0자'**
  String get calendarZeroChars;

  /// No description provided for @calendarUploadTitleHint.
  ///
  /// In ko, this message translates to:
  /// **'업로드 제목을 입력하세요'**
  String get calendarUploadTitleHint;

  /// No description provided for @calendarComplete.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get calendarComplete;

  /// No description provided for @calendarPlan.
  ///
  /// In ko, this message translates to:
  /// **'계획'**
  String get calendarPlan;

  /// No description provided for @ebookSaveComplete.
  ///
  /// In ko, this message translates to:
  /// **'저장 완료'**
  String get ebookSaveComplete;

  /// No description provided for @ebookDefaultContent.
  ///
  /// In ko, this message translates to:
  /// **'작품 내용을 입력하세요'**
  String get ebookDefaultContent;

  /// No description provided for @ebookLatestEpisode.
  ///
  /// In ko, this message translates to:
  /// **'최신 회차'**
  String get ebookLatestEpisode;

  /// No description provided for @ebookCountValue.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String ebookCountValue(int count);

  /// No description provided for @ebookTodayNoRecord.
  ///
  /// In ko, this message translates to:
  /// **'오늘 등록된 기록이 없습니다.'**
  String get ebookTodayNoRecord;

  /// No description provided for @ebookTodaySummary.
  ///
  /// In ko, this message translates to:
  /// **'오늘 할 일 {doneTasks}/{totalTasks} · 업로드 {releaseCount}개 · 일정 {eventCount}개'**
  String ebookTodaySummary(
    int doneTasks,
    int totalTasks,
    int releaseCount,
    int eventCount,
  );

  /// No description provided for @ebookMainSquareCreateTitle.
  ///
  /// In ko, this message translates to:
  /// **'새 작품 만들기'**
  String get ebookMainSquareCreateTitle;

  /// No description provided for @ebookMainCardCustomizeSaveComplete.
  ///
  /// In ko, this message translates to:
  /// **'메인 카드 꾸미기 저장 완료'**
  String get ebookMainCardCustomizeSaveComplete;

  /// No description provided for @ebookPreset.
  ///
  /// In ko, this message translates to:
  /// **'프리셋'**
  String get ebookPreset;

  /// No description provided for @ebookPresetName.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 이름'**
  String get ebookPresetName;

  /// No description provided for @ebookPresetDefaultName.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 {number}'**
  String ebookPresetDefaultName(int number);

  /// No description provided for @ebookPresetNameReplace.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 이름 교체'**
  String get ebookPresetNameReplace;

  /// No description provided for @ebookPresetSaveComplete.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 저장 완료'**
  String get ebookPresetSaveComplete;

  /// No description provided for @ebookPresetRenameComplete.
  ///
  /// In ko, this message translates to:
  /// **'프리셋 이름 교체 완료'**
  String get ebookPresetRenameComplete;

  /// No description provided for @ebookPresetNameHintExample.
  ///
  /// In ko, this message translates to:
  /// **'예: 사진 포스터'**
  String get ebookPresetNameHintExample;

  /// No description provided for @ebookOriginalFileLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'원본 파일을 불러오지 못했습니다'**
  String get ebookOriginalFileLoadFailed;

  /// No description provided for @ebookPhotoLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'사진을 불러오지 못했습니다'**
  String get ebookPhotoLoadFailed;

  /// No description provided for @ebookBackgroundImagePickFailed.
  ///
  /// In ko, this message translates to:
  /// **'배경 이미지 선택 실패: {error}'**
  String ebookBackgroundImagePickFailed(String error);

  /// No description provided for @ebookBackgroundImageGestureHint.
  ///
  /// In ko, this message translates to:
  /// **'드래그 이동 · 두 손가락 확대 · 더블 탭 초기화'**
  String get ebookBackgroundImageGestureHint;

  /// No description provided for @ebookReset.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get ebookReset;

  /// No description provided for @ebookEffect.
  ///
  /// In ko, this message translates to:
  /// **'효과'**
  String get ebookEffect;

  /// No description provided for @ebookGlassMode.
  ///
  /// In ko, this message translates to:
  /// **'글라스 모드'**
  String get ebookGlassMode;

  /// No description provided for @ebookGlassModeSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'부드러운 유리감과 렌즈 반사를 적용합니다.'**
  String get ebookGlassModeSubtitle;

  /// No description provided for @ebookPresetSectionSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'현재 조합을 저장해두고 나중에 다시 적용할 수 있습니다.'**
  String get ebookPresetSectionSubtitle;

  /// No description provided for @ebookSaveCurrentPreset.
  ///
  /// In ko, this message translates to:
  /// **'현재 프리셋 저장'**
  String get ebookSaveCurrentPreset;

  /// No description provided for @ebookNoSavedPreset.
  ///
  /// In ko, this message translates to:
  /// **'저장된 프리셋이 없습니다.'**
  String get ebookNoSavedPreset;

  /// No description provided for @ebookTextSection.
  ///
  /// In ko, this message translates to:
  /// **'문구'**
  String get ebookTextSection;

  /// No description provided for @ebookMainText.
  ///
  /// In ko, this message translates to:
  /// **'큰 문구'**
  String get ebookMainText;

  /// No description provided for @ebookSubText.
  ///
  /// In ko, this message translates to:
  /// **'작은 문구'**
  String get ebookSubText;

  /// No description provided for @ebookOptional.
  ///
  /// In ko, this message translates to:
  /// **'선택 사항'**
  String get ebookOptional;

  /// No description provided for @ebookMainTextWeight.
  ///
  /// In ko, this message translates to:
  /// **'큰 문구 두께'**
  String get ebookMainTextWeight;

  /// No description provided for @ebookSubTextWeight.
  ///
  /// In ko, this message translates to:
  /// **'작은 문구 두께'**
  String get ebookSubTextWeight;

  /// No description provided for @ebookTextPosition.
  ///
  /// In ko, this message translates to:
  /// **'텍스트 위치'**
  String get ebookTextPosition;

  /// No description provided for @ebookTextIconColor.
  ///
  /// In ko, this message translates to:
  /// **'문구 아이콘 색상'**
  String get ebookTextIconColor;

  /// No description provided for @ebookLightTextModeNotice.
  ///
  /// In ko, this message translates to:
  /// **'밝은 문구 모드가 켜져 있으면 사진 위에서는 흰색 문구가 우선 적용됩니다.'**
  String get ebookLightTextModeNotice;

  /// No description provided for @ebookCardStyle.
  ///
  /// In ko, this message translates to:
  /// **'카드 스타일'**
  String get ebookCardStyle;

  /// No description provided for @ebookCardRatio.
  ///
  /// In ko, this message translates to:
  /// **'카드 비율'**
  String get ebookCardRatio;

  /// No description provided for @ebookBackgroundStyle.
  ///
  /// In ko, this message translates to:
  /// **'배경 스타일'**
  String get ebookBackgroundStyle;

  /// No description provided for @ebookBorderStyle.
  ///
  /// In ko, this message translates to:
  /// **'테두리 스타일'**
  String get ebookBorderStyle;

  /// No description provided for @ebookBackgroundImage.
  ///
  /// In ko, this message translates to:
  /// **'배경 이미지'**
  String get ebookBackgroundImage;

  /// No description provided for @ebookBackgroundImageSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'사진을 넣으면 미리보기 카드에서 직접 위치와 확대를 조절할 수 있습니다.'**
  String get ebookBackgroundImageSubtitle;

  /// No description provided for @ebookSelectPhoto.
  ///
  /// In ko, this message translates to:
  /// **'사진 선택'**
  String get ebookSelectPhoto;

  /// No description provided for @ebookDeleteImage.
  ///
  /// In ko, this message translates to:
  /// **'이미지 삭제'**
  String get ebookDeleteImage;

  /// No description provided for @ebookResetPosition.
  ///
  /// In ko, this message translates to:
  /// **'위치 초기화'**
  String get ebookResetPosition;

  /// No description provided for @ebookDarkPhotoWhiteText.
  ///
  /// In ko, this message translates to:
  /// **'어두운 사진용 흰 글자'**
  String get ebookDarkPhotoWhiteText;

  /// No description provided for @ebookDarkPhotoWhiteTextSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'사진 배경 위에서 아이콘과 문구를 흰색으로 보여줍니다.'**
  String get ebookDarkPhotoWhiteTextSubtitle;

  /// No description provided for @ebookIcon.
  ///
  /// In ko, this message translates to:
  /// **'아이콘'**
  String get ebookIcon;

  /// No description provided for @ebookShowIcon.
  ///
  /// In ko, this message translates to:
  /// **'아이콘 보이기'**
  String get ebookShowIcon;

  /// No description provided for @ebookIconShape.
  ///
  /// In ko, this message translates to:
  /// **'아이콘 모양'**
  String get ebookIconShape;

  /// No description provided for @ebookIconPosition.
  ///
  /// In ko, this message translates to:
  /// **'아이콘 위치'**
  String get ebookIconPosition;

  /// No description provided for @ebookSize.
  ///
  /// In ko, this message translates to:
  /// **'크기'**
  String get ebookSize;

  /// No description provided for @ebookThinness.
  ///
  /// In ko, this message translates to:
  /// **'얇기'**
  String get ebookThinness;

  /// No description provided for @ebookRatioSquare.
  ///
  /// In ko, this message translates to:
  /// **'정사각형'**
  String get ebookRatioSquare;

  /// No description provided for @ebookRatioPortrait.
  ///
  /// In ko, this message translates to:
  /// **'세로형'**
  String get ebookRatioPortrait;

  /// No description provided for @ebookRatioTall.
  ///
  /// In ko, this message translates to:
  /// **'긴 세로형'**
  String get ebookRatioTall;

  /// No description provided for @ebookRatioLandscape.
  ///
  /// In ko, this message translates to:
  /// **'가로형'**
  String get ebookRatioLandscape;

  /// No description provided for @ebookRatioWide.
  ///
  /// In ko, this message translates to:
  /// **'와이드'**
  String get ebookRatioWide;

  /// No description provided for @ebookStyleNone.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get ebookStyleNone;

  /// No description provided for @ebookStyleSky.
  ///
  /// In ko, this message translates to:
  /// **'맑은 하늘'**
  String get ebookStyleSky;

  /// No description provided for @ebookStyleSoftPink.
  ///
  /// In ko, this message translates to:
  /// **'소프트 핑크'**
  String get ebookStyleSoftPink;

  /// No description provided for @ebookStyleLightLavender.
  ///
  /// In ko, this message translates to:
  /// **'라이트 라벤더'**
  String get ebookStyleLightLavender;

  /// No description provided for @ebookStyleVanillaCream.
  ///
  /// In ko, this message translates to:
  /// **'바닐라 크림'**
  String get ebookStyleVanillaCream;

  /// No description provided for @ebookStyleClearMint.
  ///
  /// In ko, this message translates to:
  /// **'클리어 민트'**
  String get ebookStyleClearMint;

  /// No description provided for @ebookStyleBrightAurora.
  ///
  /// In ko, this message translates to:
  /// **'밝은 오로라'**
  String get ebookStyleBrightAurora;

  /// No description provided for @ebookOptionDefault.
  ///
  /// In ko, this message translates to:
  /// **'기본'**
  String get ebookOptionDefault;

  /// No description provided for @ebookOptionWriting.
  ///
  /// In ko, this message translates to:
  /// **'글쓰기'**
  String get ebookOptionWriting;

  /// No description provided for @ebookOptionBook.
  ///
  /// In ko, this message translates to:
  /// **'책'**
  String get ebookOptionBook;

  /// No description provided for @ebookOptionDrawing.
  ///
  /// In ko, this message translates to:
  /// **'드로잉'**
  String get ebookOptionDrawing;

  /// No description provided for @ebookOptionStar.
  ///
  /// In ko, this message translates to:
  /// **'별'**
  String get ebookOptionStar;

  /// No description provided for @ebookOptionHeart.
  ///
  /// In ko, this message translates to:
  /// **'하트'**
  String get ebookOptionHeart;

  /// No description provided for @ebookBorderThin.
  ///
  /// In ko, this message translates to:
  /// **'기본 얇은 테두리'**
  String get ebookBorderThin;

  /// No description provided for @ebookBorderThick.
  ///
  /// In ko, this message translates to:
  /// **'두꺼운 테두리'**
  String get ebookBorderThick;

  /// No description provided for @ebookBorderNone.
  ///
  /// In ko, this message translates to:
  /// **'테두리 없음'**
  String get ebookBorderNone;

  /// No description provided for @ebookBorderPastel.
  ///
  /// In ko, this message translates to:
  /// **'파스텔 테두리'**
  String get ebookBorderPastel;

  /// No description provided for @ebookBorderDashed.
  ///
  /// In ko, this message translates to:
  /// **'점선 느낌'**
  String get ebookBorderDashed;

  /// No description provided for @ebookPosTopLeft.
  ///
  /// In ko, this message translates to:
  /// **'상단 왼쪽'**
  String get ebookPosTopLeft;

  /// No description provided for @ebookPosTopCenter.
  ///
  /// In ko, this message translates to:
  /// **'상단 중앙'**
  String get ebookPosTopCenter;

  /// No description provided for @ebookPosTopRight.
  ///
  /// In ko, this message translates to:
  /// **'상단 오른쪽'**
  String get ebookPosTopRight;

  /// No description provided for @ebookPosCenterLeft.
  ///
  /// In ko, this message translates to:
  /// **'중앙 왼쪽'**
  String get ebookPosCenterLeft;

  /// No description provided for @ebookPosCenter.
  ///
  /// In ko, this message translates to:
  /// **'정중앙'**
  String get ebookPosCenter;

  /// No description provided for @ebookPosCenterRight.
  ///
  /// In ko, this message translates to:
  /// **'중앙 오른쪽'**
  String get ebookPosCenterRight;

  /// No description provided for @ebookPosBottomLeft.
  ///
  /// In ko, this message translates to:
  /// **'하단 왼쪽'**
  String get ebookPosBottomLeft;

  /// No description provided for @ebookPosBottomCenter.
  ///
  /// In ko, this message translates to:
  /// **'하단 중앙'**
  String get ebookPosBottomCenter;

  /// No description provided for @ebookPosBottomRight.
  ///
  /// In ko, this message translates to:
  /// **'하단 오른쪽'**
  String get ebookPosBottomRight;

  /// No description provided for @episodesPageTitle.
  ///
  /// In ko, this message translates to:
  /// **'회차'**
  String get episodesPageTitle;

  /// No description provided for @episodeToggleAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get episodeToggleAll;

  /// No description provided for @episodeToggleSelected.
  ///
  /// In ko, this message translates to:
  /// **'선택'**
  String get episodeToggleSelected;

  /// No description provided for @episodeCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 회차'**
  String episodeCountLabel(int count);

  /// No description provided for @emptySavedEpisodes.
  ///
  /// In ko, this message translates to:
  /// **'저장된 회차가 없습니다.'**
  String get emptySavedEpisodes;

  /// No description provided for @shareCurrentPage.
  ///
  /// In ko, this message translates to:
  /// **'지금'**
  String get shareCurrentPage;

  /// No description provided for @shareAllPages.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get shareAllPages;

  /// No description provided for @shareCustomRange.
  ///
  /// In ko, this message translates to:
  /// **'직접'**
  String get shareCustomRange;

  /// No description provided for @shareNoFiles.
  ///
  /// In ko, this message translates to:
  /// **'공유할 파일이 없습니다.'**
  String get shareNoFiles;

  /// No description provided for @shareFailed.
  ///
  /// In ko, this message translates to:
  /// **'공유 실패'**
  String get shareFailed;

  /// No description provided for @shareFailedWithReason.
  ///
  /// In ko, this message translates to:
  /// **'공유 실패: {error}'**
  String shareFailedWithReason(String error);

  /// No description provided for @pdfShareComplete.
  ///
  /// In ko, this message translates to:
  /// **'PDF 공유 완료'**
  String get pdfShareComplete;

  /// No description provided for @pngShareComplete.
  ///
  /// In ko, this message translates to:
  /// **'PNG 공유 완료'**
  String get pngShareComplete;

  /// No description provided for @jpgShareComplete.
  ///
  /// In ko, this message translates to:
  /// **'JPG 공유 완료'**
  String get jpgShareComplete;

  /// No description provided for @pdfOpenFailed.
  ///
  /// In ko, this message translates to:
  /// **'PDF 열기 실패: {error}'**
  String pdfOpenFailed(String error);

  /// No description provided for @pdfSavedToApp.
  ///
  /// In ko, this message translates to:
  /// **'앱에 저장 완료: {fileName}'**
  String pdfSavedToApp(String fileName);

  /// No description provided for @saveFailedWithReason.
  ///
  /// In ko, this message translates to:
  /// **'저장 실패: {error}'**
  String saveFailedWithReason(String error);

  /// No description provided for @pngSaveCompletePath.
  ///
  /// In ko, this message translates to:
  /// **'PNG 저장 완료\n{path}'**
  String pngSaveCompletePath(String path);

  /// No description provided for @pngSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'PNG 저장 실패'**
  String get pngSaveFailed;

  /// No description provided for @simpleMemoTitle.
  ///
  /// In ko, this message translates to:
  /// **'간단 메모'**
  String get simpleMemoTitle;

  /// No description provided for @selectMemo.
  ///
  /// In ko, this message translates to:
  /// **'메모 선택'**
  String get selectMemo;

  /// No description provided for @selectedMemosCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 선택됨'**
  String selectedMemosCount(int count);

  /// No description provided for @selectedMemosDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'선택된 메모를 삭제하시겠습니까?'**
  String get selectedMemosDeleteMessage;

  /// No description provided for @simpleMemoAddTooltip.
  ///
  /// In ko, this message translates to:
  /// **'새 메모 추가'**
  String get simpleMemoAddTooltip;

  /// No description provided for @simpleMemoEmptyMain.
  ///
  /// In ko, this message translates to:
  /// **'저장된 메모가 없습니다.\n오른쪽 상단 + 버튼으로 장르를 선택해 메모를 추가하세요.'**
  String get simpleMemoEmptyMain;

  /// No description provided for @simpleMemoEmptyGenre.
  ///
  /// In ko, this message translates to:
  /// **'저장된 메모가 없습니다.\n오른쪽 상단 + 버튼으로 메모를 추가하세요.'**
  String get simpleMemoEmptyGenre;

  /// No description provided for @pdfEmptyContent.
  ///
  /// In ko, this message translates to:
  /// **'(내용 없음)'**
  String get pdfEmptyContent;

  /// No description provided for @pdfPreviewDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'PDF 미리보기'**
  String get pdfPreviewDialogTitle;

  /// No description provided for @pdfPreviewConfirm.
  ///
  /// In ko, this message translates to:
  /// **'미리보기'**
  String get pdfPreviewConfirm;

  /// No description provided for @pdfChapterListEmpty.
  ///
  /// In ko, this message translates to:
  /// **'목차가 없습니다'**
  String get pdfChapterListEmpty;

  /// No description provided for @pdfChapterSelectRequired.
  ///
  /// In ko, this message translates to:
  /// **'회차를 선택해 주세요'**
  String get pdfChapterSelectRequired;

  /// No description provided for @ebookMainCardCustomize.
  ///
  /// In ko, this message translates to:
  /// **'메인 카드 꾸미기'**
  String get ebookMainCardCustomize;

  /// No description provided for @toolbarKeywordHide.
  ///
  /// In ko, this message translates to:
  /// **'키워드 숨기기'**
  String get toolbarKeywordHide;

  /// No description provided for @toolbarKeywordOpen.
  ///
  /// In ko, this message translates to:
  /// **'키워드 열기'**
  String get toolbarKeywordOpen;

  /// No description provided for @toolbarSpeechStop.
  ///
  /// In ko, this message translates to:
  /// **'음성 입력 중지'**
  String get toolbarSpeechStop;

  /// No description provided for @toolbarSpeechInput.
  ///
  /// In ko, this message translates to:
  /// **'음성 입력'**
  String get toolbarSpeechInput;

  /// No description provided for @toolbarUndo.
  ///
  /// In ko, this message translates to:
  /// **'실행 취소'**
  String get toolbarUndo;

  /// No description provided for @toolbarRedo.
  ///
  /// In ko, this message translates to:
  /// **'다시 실행'**
  String get toolbarRedo;

  /// No description provided for @toolbarBold.
  ///
  /// In ko, this message translates to:
  /// **'굵게'**
  String get toolbarBold;

  /// No description provided for @toolbarTextColor.
  ///
  /// In ko, this message translates to:
  /// **'글자 색'**
  String get toolbarTextColor;

  /// No description provided for @toolbarTextBackgroundColor.
  ///
  /// In ko, this message translates to:
  /// **'글자 배경 색'**
  String get toolbarTextBackgroundColor;

  /// No description provided for @toolbarHighlight.
  ///
  /// In ko, this message translates to:
  /// **'하이라이트'**
  String get toolbarHighlight;

  /// No description provided for @toolbarDividerSolid.
  ///
  /// In ko, this message translates to:
  /// **'구분선(기본)'**
  String get toolbarDividerSolid;

  /// No description provided for @toolbarDividerDashed.
  ///
  /// In ko, this message translates to:
  /// **'점선 구분선'**
  String get toolbarDividerDashed;

  /// No description provided for @toolbarAlign.
  ///
  /// In ko, this message translates to:
  /// **'정렬'**
  String get toolbarAlign;

  /// No description provided for @toolbarItalic.
  ///
  /// In ko, this message translates to:
  /// **'기울임'**
  String get toolbarItalic;

  /// No description provided for @toolbarUnderline.
  ///
  /// In ko, this message translates to:
  /// **'밑줄'**
  String get toolbarUnderline;

  /// No description provided for @toolbarStrikethrough.
  ///
  /// In ko, this message translates to:
  /// **'취소선'**
  String get toolbarStrikethrough;

  /// No description provided for @toolbarOrderedList.
  ///
  /// In ko, this message translates to:
  /// **'번호 목록'**
  String get toolbarOrderedList;

  /// No description provided for @toolbarBulletedList.
  ///
  /// In ko, this message translates to:
  /// **'글머리 목록'**
  String get toolbarBulletedList;

  /// No description provided for @toolbarBlockquote.
  ///
  /// In ko, this message translates to:
  /// **'인용문'**
  String get toolbarBlockquote;

  /// No description provided for @toolbarClearFormatting.
  ///
  /// In ko, this message translates to:
  /// **'서식 초기화'**
  String get toolbarClearFormatting;

  /// No description provided for @toolbarImageUpload.
  ///
  /// In ko, this message translates to:
  /// **'이미지 업로드'**
  String get toolbarImageUpload;

  /// No description provided for @toolbarFontSize.
  ///
  /// In ko, this message translates to:
  /// **'글자 크기'**
  String get toolbarFontSize;

  /// No description provided for @toolbarClearSize.
  ///
  /// In ko, this message translates to:
  /// **'크기 해제'**
  String get toolbarClearSize;

  /// No description provided for @emailLoginTitle.
  ///
  /// In ko, this message translates to:
  /// **'이메일 로그인'**
  String get emailLoginTitle;

  /// No description provided for @emailLoginGuide.
  ///
  /// In ko, this message translates to:
  /// **'이메일과 비밀번호를 입력해 주세요'**
  String get emailLoginGuide;

  /// No description provided for @password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In ko, this message translates to:
  /// **'표시'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ko, this message translates to:
  /// **'숨기기'**
  String get hidePassword;

  /// No description provided for @login.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get signUp;

  /// No description provided for @emailLoginNotMember.
  ///
  /// In ko, this message translates to:
  /// **'아직 회원이 아니신가요? '**
  String get emailLoginNotMember;

  /// No description provided for @emailLoginFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다.'**
  String get emailLoginFailed;

  /// No description provided for @emailLoginInvalidCredentials.
  ///
  /// In ko, this message translates to:
  /// **'이메일 또는 비밀번호가 올바르지 않습니다.'**
  String get emailLoginInvalidCredentials;

  /// No description provided for @emailLoginNetworkError.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해 주세요.'**
  String get emailLoginNetworkError;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했습니다.'**
  String get unknownErrorOccurred;

  /// No description provided for @emailSignupTitle.
  ///
  /// In ko, this message translates to:
  /// **'이메일 회원가입'**
  String get emailSignupTitle;

  /// No description provided for @emailSignupCreateAccount.
  ///
  /// In ko, this message translates to:
  /// **'새 계정을 만들어 주세요'**
  String get emailSignupCreateAccount;

  /// No description provided for @emailSignupGuide.
  ///
  /// In ko, this message translates to:
  /// **'이메일과 비밀번호를 입력해 주세요'**
  String get emailSignupGuide;

  /// No description provided for @emailSignupComplete.
  ///
  /// In ko, this message translates to:
  /// **'회원가입이 완료되었습니다'**
  String get emailSignupComplete;

  /// No description provided for @emailSignupFailed.
  ///
  /// In ko, this message translates to:
  /// **'회원가입에 실패했습니다.'**
  String get emailSignupFailed;

  /// No description provided for @emailSignupAlreadyHaveAccount.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있으신가요? '**
  String get emailSignupAlreadyHaveAccount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
