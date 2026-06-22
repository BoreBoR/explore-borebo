import 'package:benjii/modules/auth/service/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;
  bool _isSignedIn = false;

  Future<void> _openSignInDialog() async {
    if (_isLoading) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return AlertDialog(
          key: const ValueKey('sign-in-method-dialog'),
          title: Text(_isSignedIn ? 'Account' : 'Sign in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isSignedIn
                    ? 'You are currently signed in.'
                    : 'Choose how you want to continue.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                key: const ValueKey('google-sign-in-method-button'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleGooglePressed();
                },
                icon: _isSignedIn
                    ? const Icon(Icons.logout_rounded)
                    : const _GoogleMark(),
                label: Text(_isSignedIn ? 'Sign out' : 'Continue with Google'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGooglePressed() async {
    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignedIn) {
        await GoogleAuthService.instance.signOut();
        _showMessage('Signed out');
        if (mounted) {
          setState(() => _isSignedIn = false);
        }
      } else {
        final credential = await GoogleAuthService.instance.signInWithGoogle();
        final displayName = credential.user?.displayName;
        _showMessage(
          displayName == null || displayName.isEmpty
              ? 'Signed in with Google'
              : 'Signed in as $displayName',
        );
        if (mounted) {
          setState(() => _isSignedIn = true);
        }
      }
    } on FirebaseAuthException catch (error) {
      _showMessage('Google sign-in failed: ${error.code}');
    } on GoogleSignInException catch (error) {
      _showMessage('Google sign-in failed: ${error.code.name}');
    } catch (error) {
      _showMessage('Google sign-in failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: _isSignedIn ? 'Sign out' : 'Sign in',
      child: Material(
        key: const ValueKey('google-sign-in-button'),
        color: colorScheme.surface.withValues(alpha: 0.92),
        elevation: 4,
        shadowColor: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _openSignInDialog,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : Icon(
                        _isSignedIn
                            ? Icons.account_circle_rounded
                            : Icons.login_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                const SizedBox(width: 8),
                Text(
                  _isSignedIn ? 'Signed in' : 'Sign in',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
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

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: const Color(0xFF4285F4),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
