import 'package:benjii/modules/auth/service/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  String _userLabel(User? user) {
    final displayName = user?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    final email = user?.email;
    if (email != null && email.trim().isNotEmpty) {
      return email.trim();
    }
    return 'Google';
  }

  Future<void> _openSignInDialog(User? user) async {
    if (_isLoading) {
      return;
    }

    final isSignedIn = user != null;
    await showDialog<void>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return AlertDialog(
          key: const ValueKey('sign-in-method-dialog'),
          title: Text(isSignedIn ? 'Account' : 'Sign in'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isSignedIn
                    ? 'Signed in as ${_userLabel(user)}.'
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
                icon: isSignedIn
                    ? const Icon(Icons.logout_rounded)
                    : const _GoogleMark(),
                label: Text(isSignedIn ? 'Sign out' : 'Continue with Google'),
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
      if (Firebase.apps.isEmpty) {
        _showMessage('Firebase is not ready yet.');
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await GoogleAuthService.instance.signOut();
        _showMessage('Signed out');
      } else {
        final credential = await GoogleAuthService.instance.signInWithGoogle();
        final displayName = credential.user?.displayName;
        _showMessage(
          displayName == null || displayName.isEmpty
              ? 'Signed in with Google'
              : 'Signed in as $displayName',
        );
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
    if (Firebase.apps.isEmpty) {
      return _GoogleSignInButtonContent(
        isLoading: false,
        isSignedIn: false,
        label: 'Sign in',
        onTap: () => _showMessage('Firebase is not ready yet.'),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isSignedIn = user != null;
        final label = isSignedIn
            ? 'Signed in as ${_userLabel(user)}'
            : 'Sign in';

        return _GoogleSignInButtonContent(
          isLoading: _isLoading,
          isSignedIn: isSignedIn,
          label: label,
          onTap: () => _openSignInDialog(user),
        );
      },
    );
  }
}

class _GoogleSignInButtonContent extends StatelessWidget {
  const _GoogleSignInButtonContent({
    required this.isLoading,
    required this.isSignedIn,
    required this.label,
    required this.onTap,
  });

  final bool isLoading;
  final bool isSignedIn;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: isSignedIn ? 'Sign out' : 'Sign in',
      child: Material(
        key: const ValueKey('google-sign-in-button'),
        color: colorScheme.surface.withValues(alpha: 0.92),
        elevation: 4,
        shadowColor: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isLoading
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : Icon(
                        isSignedIn
                            ? Icons.account_circle_rounded
                            : Icons.login_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
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
