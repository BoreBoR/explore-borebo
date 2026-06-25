import 'package:benjii/modules/auth/view/google_sign_in_button.dart';
import 'package:benjii/modules/kang_game/model/kang_multiplayer_match.dart';
import 'package:benjii/modules/kang_game/repository/kang_multiplayer_repository.dart';
import 'package:benjii/util/app_background.dart';
import 'package:benjii/util/app_color.dart';
import 'package:benjii/util/standard_page_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class KangMultiplayerLobbyPage extends StatefulWidget {
  KangMultiplayerLobbyPage({super.key, KangMultiplayerRepository? repository})
    : repository = repository ?? KangMultiplayerRepository();

  final KangMultiplayerRepository repository;

  @override
  State<KangMultiplayerLobbyPage> createState() =>
      _KangMultiplayerLobbyPageState();
}

class _KangMultiplayerLobbyPageState extends State<KangMultiplayerLobbyPage> {
  bool _isCreating = false;
  String? _joiningMatchId;

  String _displayName(User user) {
    final name = user.displayName;
    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }
    final email = user.email;
    if (email != null && email.trim().isNotEmpty) {
      return email.trim();
    }
    return 'Player ${user.uid.substring(0, 5)}';
  }

  Future<void> _createMatch(User user) async {
    if (_isCreating) {
      return;
    }

    setState(() => _isCreating = true);
    try {
      final matchId = await widget.repository.createMatch(
        hostUserId: user.uid,
        hostName: _displayName(user),
      );
      _openMatch(matchId);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _joinMatch(User user, KangMultiplayerMatch match) async {
    if (_joiningMatchId != null) {
      return;
    }

    setState(() => _joiningMatchId = match.id);
    try {
      await widget.repository.joinMatch(
        matchId: match.id,
        guestUserId: user.uid,
        guestName: _displayName(user),
      );
      _openMatch(match.id);
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _joiningMatchId = null);
      }
    }
  }

  void _openMatch(String matchId) {
    Modular.to.navigate('/kang-game/multiplayer/$matchId');
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                initialData: FirebaseAuth.instance.currentUser,
                builder: (context, authSnapshot) {
                  final user = authSnapshot.data;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            StandardPageHeader(
                              title: 'Kang Multiplayer',
                              subtitle: user == null
                                  ? 'Sign in to create or join a match.'
                                  : 'Signed in as ${_displayName(user)}',
                              onBack: () => Modular.to.navigate('/'),
                              backButtonKey: const ValueKey(
                                'kang-lobby-back-button',
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              key: const ValueKey('kang-create-match-button'),
                              onPressed: user == null || _isCreating
                                  ? null
                                  : () => _createMatch(user),
                              icon: _isCreating
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add_rounded),
                              label: const Text('Create match'),
                            ),
                            const SizedBox(height: 18),
                            _OpenMatchesList(
                              currentUserId: user?.uid,
                              repository: widget.repository,
                              joiningMatchId: _joiningMatchId,
                              onJoin: user == null
                                  ? null
                                  : (match) => _joinMatch(user, match),
                              onOpen: _openMatch,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Positioned(top: 16, right: 16, child: GoogleSignInButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenMatchesList extends StatelessWidget {
  const _OpenMatchesList({
    required this.currentUserId,
    required this.repository,
    required this.joiningMatchId,
    required this.onJoin,
    required this.onOpen,
  });

  final String? currentUserId;
  final KangMultiplayerRepository repository;
  final String? joiningMatchId;
  final ValueChanged<KangMultiplayerMatch>? onJoin;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<List<KangMultiplayerMatch>>(
      stream: currentUserId == null ? null : repository.watchOpenMatches(),
      builder: (context, snapshot) {
        final matches = snapshot.data ?? const <KangMultiplayerMatch>[];

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.surface.withValues(alpha: 0.9),
            border: Border.all(color: AppColor.outline.withValues(alpha: 0.72)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Open matches',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (currentUserId == null)
                  const Text('Sign in first.')
                else if (snapshot.hasError)
                  Text(
                    'Could not load matches: ${snapshot.error}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  )
                else if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (matches.isEmpty)
                  const Text('No open matches yet.')
                else
                  for (final match in matches) ...[
                    _MatchListTile(
                      match: match,
                      isOwnMatch: match.hostUserId == currentUserId,
                      isJoining: joiningMatchId == match.id,
                      onJoin: onJoin == null ? null : () => onJoin!(match),
                      onOpen: () => onOpen(match.id),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MatchListTile extends StatelessWidget {
  const _MatchListTile({
    required this.match,
    required this.isOwnMatch,
    required this.isJoining,
    required this.onJoin,
    required this.onOpen,
  });

  final KangMultiplayerMatch match;
  final bool isOwnMatch;
  final bool isJoining;
  final VoidCallback? onJoin;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('kang-open-match-${match.id}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.style_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.hostName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'Waiting for player',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 104,
            child: FilledButton.tonal(
              onPressed: isJoining
                  ? null
                  : isOwnMatch
                  ? onOpen
                  : onJoin,
              child: Text(
                isOwnMatch
                    ? 'Open'
                    : isJoining
                    ? 'Joining...'
                    : 'Join',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
