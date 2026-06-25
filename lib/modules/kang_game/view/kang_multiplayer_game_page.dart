import 'dart:async';

import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_multiplayer_match.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:benjii/modules/kang_game/repository/kang_multiplayer_repository.dart';
import 'package:benjii/modules/kang_game/view/kang_game_page.dart';
import 'package:benjii/util/app_background.dart';
import 'package:benjii/util/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class KangMultiplayerGamePage extends StatefulWidget {
  KangMultiplayerGamePage({
    super.key,
    required this.matchId,
    KangMultiplayerRepository? repository,
  }) : repository = repository ?? KangMultiplayerRepository();

  final String matchId;
  final KangMultiplayerRepository repository;

  @override
  State<KangMultiplayerGamePage> createState() =>
      _KangMultiplayerGamePageState();
}

class _KangMultiplayerGamePageState extends State<KangMultiplayerGamePage> {
  final ValueNotifier<List<KangCard>> _selectedCards = ValueNotifier([]);
  final ValueNotifier<bool> _isSubmitting = ValueNotifier(false);
  Timer? _keepAliveTimer;
  String? _lastShownRoundResultKey;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _keepMatchAlive();
    _keepAliveTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _keepMatchAlive(),
    );
  }

  Future<void> _submit(Future<void> Function(String userId) action) async {
    final user = _user;
    if (user == null || _isSubmitting.value) {
      return;
    }

    _isSubmitting.value = true;
    try {
      await action(user.uid);
      _selectedCards.value = const [];
    } catch (error) {
      _showMessage(error.toString());
    } finally {
      _isSubmitting.value = false;
    }
  }

  Future<void> _keepMatchAlive() async {
    final user = _user;
    if (user == null) {
      return;
    }

    try {
      await widget.repository.keepMatchAlive(
        matchId: widget.matchId,
        userId: user.uid,
      );
    } catch (_) {
      // Keep-alive is best-effort; the match stream will surface real errors.
    }
  }

  void _selectCard(
    KangRoundState round,
    KangPlayerState player,
    KangCard card,
  ) {
    final user = _user;
    if (user == null ||
        round.currentPlayer?.id != user.uid ||
        round.currentPlayer?.id != player.id ||
        !_canSelectCard(round, card)) {
      return;
    }

    final selectedCards = [..._selectedCards.value];
    if (selectedCards.contains(card)) {
      selectedCards.remove(card);
    } else if (round.turnPhase == KangTurnPhase.respondingToDrop ||
        selectedCards.isEmpty ||
        selectedCards.first.rank == card.rank) {
      selectedCards.add(card);
    } else {
      selectedCards
        ..clear()
        ..add(card);
    }
    _selectedCards.value = selectedCards;
  }

  @override
  void dispose() {
    _keepAliveTimer?.cancel();
    _selectedCards.dispose();
    _isSubmitting.dispose();
    super.dispose();
  }

  Widget _buildPlayerArea({
    required KangMultiplayerMatch match,
    required KangRoundState round,
    required User user,
  }) {
    final isYourTurn = round.currentPlayer?.id == user.uid;
    final statusText = match.isReady
        ? isYourTurn
              ? 'Your turn'
              : 'Waiting for ${round.currentPlayer == null ? 'opponent' : kangDisplayName(round.currentPlayer!.name)}'
        : 'Waiting for another player to join.';
    final canStartRound =
        match.isReady &&
        (round.status == KangRoundStatus.notStarted ||
            round.status == KangRoundStatus.finished);

    return ValueListenableBuilder<bool>(
      valueListenable: _isSubmitting,
      builder: (context, isSubmitting, _) {
        final canPlay =
            match.isReady &&
            round.status == KangRoundStatus.playing &&
            isYourTurn &&
            !isSubmitting;

        return ValueListenableBuilder<List<KangCard>>(
          valueListenable: _selectedCards,
          builder: (context, selectedCards, _) {
            return KangGameBoard(
              title: 'Kang Multiplayer',
              subtitle: statusText,
              round: round,
              primaryPlayerId: user.uid,
              selectedCards: selectedCards,
              onBack: () => Modular.to.navigate('/kang-game/multiplayer'),
              backButtonKey: const ValueKey('kang-multiplayer-back-button'),
              trailingHeader: SelectableText(
                'Match ${match.id}',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColor.textSecondary),
              ),
              canDropPlayer: (player) =>
                  canPlay &&
                  player.id == user.uid &&
                  (round.turnPhase == KangTurnPhase.drew ||
                      round.turnPhase == KangTurnPhase.respondingToDrop),
              hideCardsForPlayer: (player) =>
                  player.id != user.uid &&
                  round.status != KangRoundStatus.finished,
              onCardTap: (player, card) => _selectCard(round, player, card),
              startAction: canStartRound
                  ? FilledButton.icon(
                      key: const ValueKey(
                        'kang-multiplayer-start-round-button',
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () => _submit(
                              (userId) => widget.repository.startRound(
                                matchId: match.id,
                                userId: userId,
                              ),
                            ),
                      icon: Icon(
                        round.status == KangRoundStatus.finished
                            ? Icons.refresh_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        round.status == KangRoundStatus.finished
                            ? 'Next round'
                            : 'Start round',
                      ),
                    )
                  : null,
              drawAction: canStartRound
                  ? null
                  : FilledButton.tonalIcon(
                      key: const ValueKey('kang-multiplayer-draw-card-button'),
                      onPressed:
                          canPlay &&
                              (round.turnPhase == KangTurnPhase.start ||
                                  round.turnPhase ==
                                      KangTurnPhase.respondingToDrop)
                          ? () => _submit(
                              (userId) => widget.repository.draw(
                                matchId: match.id,
                                userId: userId,
                              ),
                            )
                          : null,
                      icon: const Icon(Icons.add_card_rounded),
                      label: const Text('Draw'),
                    ),
              dropAction: canStartRound
                  ? null
                  : FilledButton.icon(
                      key: const ValueKey('kang-multiplayer-drop-card-button'),
                      style: kangDropButtonStyle(),
                      onPressed: canPlay && selectedCards.isNotEmpty
                          ? () => _submit(
                              (userId) => widget.repository.dropCards(
                                matchId: match.id,
                                userId: userId,
                                cards: selectedCards,
                              ),
                            )
                          : null,
                      icon: const Icon(Icons.move_down_rounded),
                      label: const Text('Drop'),
                    ),
              kangAction: canStartRound
                  ? null
                  : FilledButton.icon(
                      key: const ValueKey('kang-multiplayer-declare-button'),
                      style: kangKangButtonStyle(),
                      onPressed:
                          canPlay && round.turnPhase == KangTurnPhase.start
                          ? () => _submit(
                              (userId) => widget.repository.declareKang(
                                matchId: match.id,
                                userId: userId,
                              ),
                            )
                          : null,
                      icon: const Icon(Icons.flag_rounded),
                      label: const Text('Kang!'),
                    ),
            );
          },
        );
      },
    );
  }

  bool _canSelectCard(KangRoundState round, KangCard card) {
    if (round.turnPhase == KangTurnPhase.drew) {
      return true;
    }
    if (round.turnPhase == KangTurnPhase.respondingToDrop) {
      return card.rank == round.pendingDroppedCard?.rank;
    }
    return false;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showRoundResultDialogIfNeeded(KangRoundState round) {
    if (round.status != KangRoundStatus.finished) {
      return;
    }

    final resultKey =
        '${round.roundNumber}:${round.winnerId}:${round.winReason?.name}';
    if (_lastShownRoundResultKey == resultKey) {
      return;
    }
    _lastShownRoundResultKey = resultKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final winner = round.winner;
      final reason = round.winReason;
      final reasonLabel = switch (reason) {
        KangWinReason.kang => 'Kang',
        KangWinReason.winOut => 'Win Out',
        KangWinReason.emptyHand => 'Empty Hand',
        KangWinReason.draw => 'Draw',
        null => 'Finished',
      };
      final title = winner == null ? 'Round draw' : '${winner.name} wins';
      final body = winner == null
          ? round.message ?? 'No winner this round.'
          : '${winner.name} wins by $reasonLabel.\n'
                'Total points: ${winner.gamePoints}';

      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            key: const ValueKey('kang-multiplayer-result-dialog'),
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            initialData: FirebaseAuth.instance.currentUser,
            builder: (context, authSnapshot) {
              final user = authSnapshot.data;
              if (user == null) {
                return const _CenteredMessage(message: 'Sign in to play.');
              }

              return StreamBuilder<KangMultiplayerMatch?>(
                stream: widget.repository.watchMatch(widget.matchId),
                builder: (context, snapshot) {
                  final match = snapshot.data;
                  if (snapshot.hasError) {
                    return _CenteredMessage(
                      message: 'Could not load match: ${snapshot.error}',
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (match == null) {
                    return const _CenteredMessage(message: 'Match not found.');
                  }
                  if (!match.isPlayer(user.uid)) {
                    return const _CenteredMessage(
                      message: 'You are not a player in this match.',
                    );
                  }

                  _showRoundResultDialogIfNeeded(match.round);

                  return _buildPlayerArea(
                    match: match,
                    round: match.round,
                    user: user,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
