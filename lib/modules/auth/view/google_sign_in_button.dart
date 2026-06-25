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
  bool _isExpanded = false;

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

  String? _userEmail(User? user) {
    final email = user?.email;
    if (email != null && email.trim().isNotEmpty) {
      return email.trim();
    }
    return null;
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
              if (isSignedIn)
                _AccountSummary(name: _userLabel(user), email: _userEmail(user))
              else
                Text(
                  'Choose how you want to continue.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 18),
              if (isSignedIn) ...[
                FilledButton.icon(
                  key: const ValueKey('google-switch-account-button'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleSwitchAccount();
                  },
                  icon: const Icon(Icons.switch_account_rounded),
                  label: const Text('Switch Google account'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const ValueKey('google-sign-out-button'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleSignOut();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: const ValueKey('google-delete-account-button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleDeleteAccount();
                  },
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Delete account'),
                ),
              ] else
                OutlinedButton.icon(
                  key: const ValueKey('google-sign-in-method-button'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleSignIn();
                  },
                  icon: const _GoogleMark(),
                  label: const Text('Continue with Google'),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleAccountTap(User? user) {
    if (_isLoading) {
      return;
    }

    if (user == null || _isExpanded) {
      _openSignInDialog(user);
      return;
    }

    setState(() => _isExpanded = true);
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (Firebase.apps.isEmpty) {
        _showMessage('Firebase is not ready yet.');
        return;
      }

      final credential = await GoogleAuthService.instance.signInWithGoogle();
      _isExpanded = false;
      final displayName = credential.user?.displayName;
      _showMessage(
        displayName == null || displayName.isEmpty
            ? 'Signed in with Google'
            : 'Signed in as $displayName',
      );
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

  Future<void> _handleSignOut() async {
    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (Firebase.apps.isEmpty) {
        _showMessage('Firebase is not ready yet.');
        return;
      }

      await GoogleAuthService.instance.signOut();
      _isExpanded = false;
      _showMessage('Signed out');
    } on FirebaseAuthException catch (error) {
      _showMessage('Sign out failed: ${error.code}');
    } on GoogleSignInException catch (error) {
      _showMessage('Sign out failed: ${error.code.name}');
    } catch (error) {
      _showMessage('Sign out failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSwitchAccount() async {
    if (_isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (Firebase.apps.isEmpty) {
        _showMessage('Firebase is not ready yet.');
        return;
      }

      final credential = await GoogleAuthService.instance.switchGoogleAccount();
      _isExpanded = false;
      final displayName = credential.user?.displayName;
      _showMessage(
        displayName == null || displayName.isEmpty
            ? 'Switched Google account'
            : 'Switched to $displayName',
      );
    } on FirebaseAuthException catch (error) {
      _showMessage('Switch account failed: ${error.code}');
    } on GoogleSignInException catch (error) {
      _showMessage('Switch account failed: ${error.code.name}');
    } catch (error) {
      _showMessage('Switch account failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (_isLoading) {
      return;
    }

    final confirmed = await _confirmDeleteAccount();
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (Firebase.apps.isEmpty) {
        _showMessage('Firebase is not ready yet.');
        return;
      }

      await GoogleAuthService.instance.deleteCurrentAccount();
      _isExpanded = false;
      _showMessage('Account deleted');
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        _showMessage('Signed out. Delete needs a recent login.');
      } else if (error.code == 'user-mismatch' &&
          error.message != null &&
          error.message!.isNotEmpty) {
        _showMessage(error.message!);
      } else {
        _showMessage('Delete account failed: ${error.code}');
      }
    } on GoogleSignInException catch (error) {
      _showMessage('Delete account failed: ${error.code.name}');
    } catch (error) {
      _showMessage('Delete account failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          key: const ValueKey('delete-account-confirm-dialog'),
          title: const Text('Delete account?'),
          content: const Text(
            'This will delete your Firebase account and profile data. You will need to sign in again to use online features.',
          ),
          actions: [
            TextButton(
              key: const ValueKey('cancel-delete-account-button'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              key: const ValueKey('confirm-delete-account-button'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_forever_rounded),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
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
        email: null,
        isExpanded: false,
        onCollapse: null,
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
          email: _userEmail(user),
          isExpanded: isSignedIn && _isExpanded,
          onCollapse: isSignedIn && _isExpanded
              ? () => setState(() => _isExpanded = false)
              : null,
          onTap: () => _handleAccountTap(user),
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
    required this.email,
    required this.isExpanded,
    required this.onCollapse,
    required this.onTap,
  });

  final bool isLoading;
  final bool isSignedIn;
  final String label;
  final String? email;
  final bool isExpanded;
  final VoidCallback? onCollapse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isCollapsedAccount = isSignedIn && !isExpanded && !isLoading;

    return Semantics(
      button: true,
      label: isSignedIn
          ? (isExpanded ? 'Manage account' : 'Show account')
          : 'Sign in',
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isCollapsedAccount ? 48 : 276,
            minWidth: isCollapsedAccount ? 48 : 0,
          ),
          child: Material(
            key: const ValueKey('google-sign-in-button'),
            color: colorScheme.surface.withValues(alpha: 0.94),
            elevation: 4,
            shadowColor: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(isCollapsedAccount ? 24 : 18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsedAccount ? 12 : 14,
                  vertical: isCollapsedAccount ? 12 : 10,
                ),
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
                            size: isCollapsedAccount ? 24 : 20,
                          ),
                    if (!isCollapsedAccount) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isSignedIn && email != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                email!,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSignedIn && isExpanded && onCollapse != null) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          key: const ValueKey('collapse-account-button'),
                          tooltip: 'Hide account',
                          constraints: const BoxConstraints.tightFor(
                            width: 32,
                            height: 32,
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          onPressed: onCollapse,
                          icon: const Icon(Icons.chevron_right_rounded),
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.name, required this.email});

  final String name;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.account_circle_rounded,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      email!,
                      key: const ValueKey('current-google-account-email'),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
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
