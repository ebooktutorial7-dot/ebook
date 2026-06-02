// settings_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';
import 'package:ebook_tutorial_app/l10n/generated/app_localizations.dart';
import 'package:ebook_tutorial_app/app_locale_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = false;
  bool _cloudSyncEnabled = false;
  bool _isLinking = false;

  String _providerLabel(User? user, AppLocalizations l10n) {
    final providers =
        user?.providerData.map((e) => e.providerId).toList() ?? [];

    if (providers.contains('google.com')) return l10n.googleAccount;
    if (providers.contains('apple.com')) return l10n.appleAccount;
    if (providers.contains('password')) return l10n.emailAccount;
    if (user?.isAnonymous == true) return l10n.guestAccount;

    return l10n.unknown;
  }

  String _userTitle(User? user, AppLocalizations l10n) {
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!;
    }

    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    if (user?.isAnonymous == true) {
      return l10n.guestUser;
    }

    return l10n.user;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    AppToast.show(context, message);
  }

  String _languageLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (appLocaleController.locale.languageCode) {
      case 'en':
        return l10n.english;
      case 'ja':
        return l10n.japanese;
      case 'ko':
      default:
        return l10n.korean;
    }
  }

  Future<void> _openLanguageSheet() async {
    final l10n = AppLocalizations.of(context);

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: Text(l10n.language),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(sheetContext);
                await appLocaleController.setLocale(const Locale('ko'));
              },
              child: Text(l10n.korean),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(sheetContext);
                await appLocaleController.setLocale(const Locale('en'));
              },
              child: Text(l10n.english),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(sheetContext);
                await appLocaleController.setLocale(const Locale('ja'));
              },
              child: Text(l10n.japanese),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext),
            child: Text(l10n.close),
          ),
        );
      },
    );
  }

  Future<void> _openAccountConnectSheet() async {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(l10n.signInInfoNotFound);
      return;
    }

    if (!user.isAnonymous) {
      _showMessage(l10n.accountAlreadyLinked);
      return;
    }

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: Text(l10n.accountConnect),
          message: Text(l10n.accountConnectMessage),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheetContext);
                _linkWithApple();
              },
              child: Text(l10n.appleAccountConnect),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheetContext);
                _linkWithGoogle();
              },
              child: Text(l10n.googleAccountConnect),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheetContext);
                _showEmailLinkDialog();
              },
              child: Text(l10n.emailAccountConnect),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext),
            child: Text(l10n.close),
          ),
        );
      },
    );
  }

  Future<void> _showEmailLinkDialog() async {
    final l10n = AppLocalizations.of(context);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    bool obscurePassword = true;
    bool obscureConfirm = true;
    String? error;

    await showDialog<void>(
      context: context,
      barrierColor: const Color(0xFF0F2238).withValues(alpha: 0.21),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              final email = emailController.text.trim();
              final password = passwordController.text;
              final confirm = confirmController.text;

              if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
                setDialogState(() => error = l10n.allFieldsRequired);
                return;
              }

              if (password.length < 6) {
                setDialogState(() => error = l10n.passwordMinLength);
                return;
              }

              if (password != confirm) {
                setDialogState(() => error = l10n.passwordMismatch);
                return;
              }

              Navigator.pop(dialogContext);

              await _linkWithEmail(email: email, password: password);
            }

            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE6ECF3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.emailAccountConnect,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DialogField(
                          controller: emailController,
                          hintText: l10n.email,
                          icon: CupertinoIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        _DialogField(
                          controller: passwordController,
                          hintText: l10n.passwordMinLengthHint,
                          icon: CupertinoIcons.lock,
                          obscureText: obscurePassword,
                          suffix: IconButton(
                            onPressed: () {
                              setDialogState(
                                () => obscurePassword = !obscurePassword,
                              );
                            },
                            icon: Icon(
                              obscurePassword
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              size: 20,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DialogField(
                          controller: confirmController,
                          hintText: l10n.confirmPassword,
                          icon: CupertinoIcons.lock_rotation,
                          obscureText: obscureConfirm,
                          suffix: IconButton(
                            onPressed: () {
                              setDialogState(
                                () => obscureConfirm = !obscureConfirm,
                              );
                            },
                            icon: Icon(
                              obscureConfirm
                                  ? CupertinoIcons.eye
                                  : CupertinoIcons.eye_slash,
                              size: 20,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                          onSubmitted: (_) => submit(),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: Text(l10n.close),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: submit,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xFFE9F7FF),
                                  foregroundColor: const Color(0xFF1F3A56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: Text(l10n.connect),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
  }

  Future<void> _linkWithEmail({
    required String email,
    required String password,
  }) async {
    final l10n = AppLocalizations.of(context);

    if (_isLinking) return;

    setState(() => _isLinking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage(l10n.signInInfoNotFound);
        return;
      }

      if (!user.isAnonymous) {
        _showMessage(l10n.accountAlreadyLinked);
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);
      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;

      setState(() {});
      _showMessage(l10n.emailAccountLinked);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'email-already-in-use' ||
          e.code == 'credential-already-in-use') {
        _showMessage(l10n.emailAlreadyInUse);
      } else if (e.code == 'invalid-email') {
        _showMessage(l10n.invalidEmail);
      } else if (e.code == 'weak-password') {
        _showMessage(l10n.weakPassword);
      } else {
        _showMessage(e.message ?? l10n.accountConnectFailed);
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(l10n.accountConnectFailed);
    } finally {
      if (mounted) {
        setState(() => _isLinking = false);
      }
    }
  }

  Future<void> _linkWithApple() async {
    final l10n = AppLocalizations.of(context);

    if (_isLinking) return;

    setState(() => _isLinking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage(l10n.signInInfoNotFound);
        return;
      }

      if (!user.isAnonymous) {
        _showMessage(l10n.accountAlreadyLinked);
        return;
      }

      final provider =
          AppleAuthProvider()
            ..addScope('email')
            ..addScope('name');

      await user.linkWithProvider(provider);
      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;

      setState(() {});
      _showMessage(l10n.appleAccountLinked);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'credential-already-in-use') {
        _showMessage(l10n.appleCredentialAlreadyInUse);
      } else if (e.code == 'provider-already-linked') {
        _showMessage(l10n.appleProviderAlreadyLinked);
      } else if (e.code == 'operation-not-allowed') {
        _showMessage(l10n.appleLoginNotEnabled);
      } else {
        _showMessage(e.message ?? l10n.appleAccountConnectFailed);
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(l10n.appleAccountConnectFailed);
    } finally {
      if (mounted) {
        setState(() => _isLinking = false);
      }
    }
  }

  Future<void> _linkWithGoogle() async {
    final l10n = AppLocalizations.of(context);

    if (_isLinking) return;

    setState(() => _isLinking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage(l10n.signInInfoNotFound);
        return;
      }

      if (!user.isAnonymous) {
        _showMessage(l10n.accountAlreadyLinked);
        return;
      }

      final googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await user.linkWithCredential(credential);
      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;

      setState(() {});
      _showMessage(l10n.googleAccountLinked);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'credential-already-in-use') {
        _showMessage(l10n.googleCredentialAlreadyInUse);
      } else {
        _showMessage(e.message ?? l10n.googleAccountConnectFailed);
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(l10n.googleAccountConnectFailed);
    } finally {
      if (mounted) {
        setState(() => _isLinking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous == true;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        border: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
        middle: Text(
          l10n.settings,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
            decoration: TextDecoration.none,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.chevron_left,
            size: 26,
            color: Color(0xFF007AFF),
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Color(0xFF111111),
            decoration: TextDecoration.none,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  children: [
                    _AccountCard(
                      title: _userTitle(user, l10n),
                      subtitle:
                          isAnonymous
                              ? l10n.connectLoginAccount
                              : _providerLabel(user, l10n),
                      onTap: _openAccountConnectSheet,
                    ),
                    const SizedBox(height: 24),
                    _IosSection(
                      children: [
                        _IosSwitchTile(
                          icon: CupertinoIcons.bell,
                          iconColor: const Color(0xFF5AC8FA),
                          title: l10n.notification,
                          value: _notificationEnabled,
                          onChanged: (v) {
                            setState(() => _notificationEnabled = v);
                          },
                        ),
                        _IosSwitchTile(
                          icon: CupertinoIcons.cloud,
                          iconColor: const Color(0xFF5AC8FA),
                          title: l10n.cloudSync,
                          value: _cloudSyncEnabled,
                          onChanged: (v) {
                            setState(() => _cloudSyncEnabled = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    _IosSection(
                      children: [
                        _IosNavigationTile(
                          icon: CupertinoIcons.globe,
                          iconColor: const Color(0xFF5AC8FA),
                          title: l10n.language,
                          subtitle: _languageLabel(context),
                          onTap: _openLanguageSheet,
                        ),
                        _IosNavigationTile(
                          icon: CupertinoIcons.paintbrush,
                          iconColor: const Color(0xFF5AC8FA),
                          title: l10n.screenSettings,
                          subtitle: l10n.defaultValue,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    _IosSection(
                      children: [
                        _IosNavigationTile(
                          icon: CupertinoIcons.info_circle,
                          iconColor: const Color.fromARGB(255, 104, 225, 255),
                          title: l10n.appInfo,
                          subtitle: l10n.appDescription,
                          onTap: () {},
                        ),
                        _IosValueTile(
                          icon: CupertinoIcons.device_phone_portrait,
                          iconColor: const Color.fromARGB(255, 104, 225, 255),
                          title: l10n.version,
                          value: '1.0.0',
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isLinking)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
    );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(icon, color: const Color(0xFF9AD0F5), size: 21),
        suffixIcon: suffix,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: Color(0xFF9AD0F5), width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9AD0F5), Color(0xFFEAF8FF)],
                ),
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                color: Colors.white,
                size: 31,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                      letterSpacing: -0.3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: Color(0xFFC7C7CC),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosSection extends StatelessWidget {
  const _IosSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                const Padding(
                  padding: EdgeInsets.only(left: 58),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFFE5E5EA),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IosIconBox extends StatelessWidget {
  const _IosIconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29,
      height: 29,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

class _IosSwitchTile extends StatelessWidget {
  const _IosSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 51,
      padding: const EdgeInsets.only(left: 14, right: 12),
      child: Row(
        children: [
          _IosIconBox(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF111111),
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: const Color(0xFF34C759),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _IosNavigationTile extends StatelessWidget {
  const _IosNavigationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        height: 51,
        padding: const EdgeInsets.only(left: 14, right: 12),
        child: Row(
          children: [
            _IosIconBox(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111111),
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8E8E93),
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(width: 7),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 17,
              color: Color(0xFFC7C7CC),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosValueTile extends StatelessWidget {
  const _IosValueTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 51,
      padding: const EdgeInsets.only(left: 14, right: 12),
      child: Row(
        children: [
          _IosIconBox(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF111111),
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
