// signup_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ebook_tutorial_app/widgets/common/app_toast.dart';
import 'package:ebook_tutorial_app/l10n/generated/app_localizations.dart';

class EmailSignupPage extends StatefulWidget {
  const EmailSignupPage({super.key});

  @override
  State<EmailSignupPage> createState() => _EmailSignupPageState();
}

class _EmailSignupPageState extends State<EmailSignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _signupErrorMessage(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'email-already-in-use':
        return l10n.emailAlreadyInUse;
      case 'invalid-email':
        return l10n.invalidEmail;
      case 'weak-password':
        return l10n.weakPassword;
      case 'network-request-failed':
        return l10n.emailLoginNetworkError;
      default:
        return e.message ?? l10n.emailSignupFailed;
    }
  }

  Future<void> _signup() async {
    if (_isSubmitting) return;

    final l10n = AppLocalizations.of(context);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = l10n.allFieldsRequired);
      return;
    }

    if (password.length < 6) {
      setState(() => _error = l10n.passwordMinLength);
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = l10n.passwordMismatch);
      return;
    }

    setState(() {
      _error = null;
      _isSubmitting = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      AppToast.show(context, l10n.emailSignupComplete);

      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = _signupErrorMessage(e, l10n));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.unknownErrorOccurred);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    const Color pastelBlue = Color(0xFF9AD0F5);
    const Color border = Color(0xFFE5E7EB);

    const TextStyle thinText = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: .2,
      color: Colors.black87,
    );

    final ButtonStyle pillFrame = OutlinedButton.styleFrom(
      side: const BorderSide(color: border, width: 1),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      foregroundColor: Colors.black87,
      textStyle: thinText,
    );

    final InputBorder inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: border, width: 1),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          l10n.emailSignupTitle,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double topGap = constraints.maxHeight * 0.18;
            final double bottomGap = constraints.maxHeight * 0.03;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, topGap, 24, bottomGap),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.person_add_alt_1_outlined,
                          color: pastelBlue,
                          size: 44,
                        ),

                        const SizedBox(height: 18),

                        Text(
                          l10n.emailSignupCreateAccount,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 0, 0, 0),
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 7),

                        Text(
                          l10n.emailSignupGuide,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: l10n.email,
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              color: pastelBlue,
                            ),
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: inputBorder.copyWith(
                              borderSide: const BorderSide(
                                color: pastelBlue,
                                width: 1.2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: l10n.passwordMinLengthHint,
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: pastelBlue,
                            ),
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscurePassword
                                      ? l10n.showPassword
                                      : l10n.hidePassword,
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: pastelBlue,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: inputBorder.copyWith(
                              borderSide: const BorderSide(
                                color: pastelBlue,
                                width: 1.2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          onSubmitted: (_) => _signup(),
                          decoration: InputDecoration(
                            hintText: l10n.confirmPassword,
                            hintStyle: const TextStyle(color: Colors.black38),
                            prefixIcon: const Icon(
                              Icons.lock_reset_outlined,
                              color: pastelBlue,
                            ),
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscureConfirm
                                      ? l10n.showPassword
                                      : l10n.hidePassword,
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: pastelBlue,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                );
                              },
                            ),
                            border: inputBorder,
                            enabledBorder: inputBorder,
                            focusedBorder: inputBorder.copyWith(
                              borderSide: const BorderSide(
                                color: pastelBlue,
                                width: 1.2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_error != null) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red.shade300),
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.transparent,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 8),

                        OutlinedButton(
                          onPressed: _isSubmitting ? null : _signup,
                          style: pillFrame,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isSubmitting)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Text(l10n.signUp, style: thinText),
                              if (!_isSubmitting) ...const [
                                SizedBox(width: 8),
                                Icon(
                                  Icons.person_add_alt_1_outlined,
                                  size: 20,
                                  color: pastelBlue,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.emailSignupAlreadyHaveAccount,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: pillFrame.copyWith(
                                padding: const WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(l10n.login, style: thinText),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.login,
                                    size: 20,
                                    color: pastelBlue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
