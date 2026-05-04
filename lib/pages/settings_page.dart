import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = false;
  bool _cloudSyncEnabled = false;
  bool _isLinking = false;

  String _providerLabel(User? user) {
    final providers =
        user?.providerData.map((e) => e.providerId).toList() ?? [];

    if (providers.contains('google.com')) return 'Google 계정';
    if (providers.contains('apple.com')) return 'Apple 계정';
    if (providers.contains('password')) return '이메일 계정';
    if (user?.isAnonymous == true) return '비회원 계정';

    return '알 수 없음';
  }

  String _userTitle(User? user) {
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!;
    }

    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    if (user?.isAnonymous == true) {
      return '비회원 사용자';
    }

    return '사용자';
  }

  void _showMessage(String message) {
    if (!mounted) return;

    AppToast.show(context, message);
  }

  Future<void> _openAccountConnectSheet() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('로그인 정보가 없습니다.');
      return;
    }

    if (!user.isAnonymous) {
      _showMessage('이미 계정이 연결되어 있습니다.');
      return;
    }

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: const Text('계정 연결'),
          message: const Text('비회원 계정을 로그인 계정으로 연결할 수 있습니다.'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheetContext);
                _linkWithApple();
              },
              child: const Text('Apple 계정 연결'),
            ),

            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheetContext);
                _linkWithGoogle();
              },
              child: const Text('Google 계정 연결'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheetContext);
                _showEmailLinkDialog();
              },
              child: const Text('이메일 계정 연결'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext),
            child: const Text('닫기'),
          ),
        );
      },
    );
  }

  Future<void> _showEmailLinkDialog() async {
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
                setDialogState(() => error = '모든 항목을 입력해 주세요.');
                return;
              }

              if (password.length < 6) {
                setDialogState(() => error = '비밀번호는 6자 이상이어야 합니다.');
                return;
              }

              if (password != confirm) {
                setDialogState(() => error = '비밀번호가 일치하지 않습니다.');
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
                        const Text(
                          '이메일 계정 연결',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _DialogField(
                          controller: emailController,
                          hintText: '이메일',
                          icon: CupertinoIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 10),

                        _DialogField(
                          controller: passwordController,
                          hintText: '비밀번호 6자 이상',
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
                          hintText: '비밀번호 확인',
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
                                child: const Text('닫기'),
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
                                child: const Text('연결'),
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
    if (_isLinking) return;

    setState(() => _isLinking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage('로그인 정보가 없습니다.');
        return;
      }

      if (!user.isAnonymous) {
        _showMessage('이미 계정이 연결되어 있습니다.');
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
      _showMessage('이메일 계정이 연결되었습니다.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' ||
          e.code == 'credential-already-in-use') {
        _showMessage('이미 사용 중인 이메일입니다.');
      } else if (e.code == 'invalid-email') {
        _showMessage('이메일 형식이 올바르지 않습니다.');
      } else if (e.code == 'weak-password') {
        _showMessage('비밀번호가 너무 약합니다.');
      } else {
        _showMessage(e.message ?? '계정 연결에 실패했습니다.');
      }
    } catch (_) {
      _showMessage('계정 연결에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isLinking = false);
      }
    }
  }

  Future<void> _linkWithApple() async {
    if (_isLinking) return;

    setState(() => _isLinking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage('로그인 정보가 없습니다.');
        return;
      }

      if (!user.isAnonymous) {
        _showMessage('이미 계정이 연결되어 있습니다.');
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
      _showMessage('Apple 계정이 연결되었습니다.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        _showMessage('이미 다른 계정에 연결된 Apple 계정입니다.');
      } else if (e.code == 'provider-already-linked') {
        _showMessage('이미 Apple 계정이 연결되어 있습니다.');
      } else if (e.code == 'operation-not-allowed') {
        _showMessage('Firebase에서 Apple 로그인이 활성화되어 있지 않습니다.');
      } else {
        _showMessage(e.message ?? 'Apple 계정 연결에 실패했습니다.');
      }
    } catch (_) {
      _showMessage('Apple 계정 연결에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isLinking = false);
      }
    }
  }

  Future<void> _linkWithGoogle() async {
    if (_isLinking) return;

    setState(() => _isLinking = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage('로그인 정보가 없습니다.');
        return;
      }

      if (!user.isAnonymous) {
        _showMessage('이미 계정이 연결되어 있습니다.');
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
      _showMessage('Google 계정이 연결되었습니다.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        _showMessage('이미 다른 계정에 연결된 Google 계정입니다.');
      } else {
        _showMessage(e.message ?? 'Google 계정 연결에 실패했습니다.');
      }
    } catch (_) {
      _showMessage('Google 계정 연결에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isLinking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous == true;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        border: const Border(
          bottom: BorderSide(color: Colors.transparent, width: 0),
        ),
        middle: const Text(
          '설정',
          style: TextStyle(
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
                      title: _userTitle(user),
                      subtitle:
                          isAnonymous ? '로그인 계정 연결하기' : _providerLabel(user),
                      onTap: _openAccountConnectSheet,
                    ),

                    const SizedBox(height: 24),

                    _IosSection(
                      children: [
                        _IosSwitchTile(
                          icon: CupertinoIcons.bell,
                          iconColor: const Color(0xFF5AC8FA),
                          title: '알림',
                          value: _notificationEnabled,
                          onChanged: (v) {
                            setState(() => _notificationEnabled = v);
                          },
                        ),
                        _IosSwitchTile(
                          icon: CupertinoIcons.cloud,
                          iconColor: const Color(0xFF5AC8FA),
                          title: '클라우드 동기화',
                          value: _cloudSyncEnabled,
                          onChanged: (v) {
                            setState(() => _cloudSyncEnabled = v);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    _IosNavigationTile(
                      icon: CupertinoIcons.paintbrush,
                      iconColor: const Color(0xFF5AC8FA),
                      title: '화면 설정',
                      subtitle: '기본',
                      onTap: () {},
                    ),

                    const SizedBox(height: 26),

                    _IosSection(
                      children: [
                        _IosNavigationTile(
                          icon: CupertinoIcons.info_circle,
                          iconColor: const Color.fromARGB(255, 104, 225, 255),
                          title: '앱 정보',
                          subtitle: 'AI 전자책 튜토리얼',
                          onTap: () {},
                        ),
                        const _IosValueTile(
                          icon: CupertinoIcons.device_phone_portrait,
                          iconColor: Color.fromARGB(255, 104, 225, 255),
                          title: '버전',
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
