import 'package:benjii/modules/kang_game/controller/local_kang_game_controller.dart';
import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:benjii/modules/kang_game/model/kang_rules.dart';
import 'package:benjii/util/app_background.dart';
import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

String kangDisplayName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }

  final parts = trimmed.split(RegExp(r'\s+'));
  final firstName = parts.first;
  final firstLabel =
      firstName.length > 7 ? '${firstName.substring(0, 7)}...' : firstName;
  if (parts.length == 1) {
    return firstLabel;
  }

  return '$firstLabel ${parts.last.characters.first}.';
}

String kangDisplayMessage(KangRoundState round, String message) {
  var displayMessage = message;
  for (final player in round.players) {
    displayMessage = displayMessage.replaceAll(
      player.name,
      kangDisplayName(player.name),
    );
  }
  return displayMessage;
}

class KangGamePage extends StatefulWidget {
  const KangGamePage({super.key, this.controller, this.initialRound});

  final LocalKangGameController? controller;
  final KangRoundState? initialRound;

  @override
  State<KangGamePage> createState() => _KangGamePageState();
}

class _KangGamePageState extends State<KangGamePage> {
  late final LocalKangGameController _controller =
      widget.controller ?? LocalKangGameController();
  late KangRoundState _round =
      widget.initialRound ?? KangRoundState.notStarted();
  final List<KangCard> _selectedCards = [];
  String? _lastShownRoundResultKey;

  void _startRound() {
    setState(() {
      _selectedCards.clear();
      _round = _controller.startRound(_round);
    });
    _showRoundResultDialogIfNeeded();
  }

  void _declareKang() {
    try {
      setState(() => _round = _controller.declareKang(_round, 'you'));
      _showRoundResultDialogIfNeeded();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _drawCard() {
    try {
      setState(() {
        _selectedCards.clear();
        _round = _controller.drawForCurrentPlayer(_round);
      });
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  void _selectCard(KangPlayerState player, KangCard card) {
    if (_round.currentPlayer?.id != player.id || !_canSelectCard(card)) {
      return;
    }

    setState(() {
      if (_round.turnPhase == KangTurnPhase.respondingToDrop) {
        if (_selectedCards.contains(card)) {
          _selectedCards.remove(card);
        } else {
          _selectedCards.add(card);
        }
        return;
      }

      if (_selectedCards.contains(card)) {
        _selectedCards.remove(card);
      } else if (_selectedCards.isEmpty ||
          _selectedCards.first.rank == card.rank) {
        _selectedCards.add(card);
      } else {
        _selectedCards
          ..clear()
          ..add(card);
      }
    });
  }

  void _dropSelectedCard() {
    if (_selectedCards.isEmpty ||
        _selectedCards.any((card) => !_canSelectCard(card))) {
      return;
    }

    try {
      setState(() {
        if (_round.turnPhase == KangTurnPhase.respondingToDrop) {
          _round = _controller.respondToDroppedCards(_round, _selectedCards);
        } else {
          _round = _controller.dropCards(_round, _selectedCards);
        }
        _selectedCards.clear();
      });
      _showRoundResultDialogIfNeeded();
    } catch (error) {
      _showMessage(error.toString());
    }
  }

  bool _canSelectCard(KangCard card) {
    if (_round.turnPhase == KangTurnPhase.drew) {
      return true;
    }
    if (_round.turnPhase == KangTurnPhase.respondingToDrop) {
      return card.rank == _round.pendingDroppedCard?.rank;
    }
    return false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showRoundResultDialogIfNeeded() {
    if (_round.status != KangRoundStatus.finished) {
      return;
    }

    final resultKey =
        '${_round.roundNumber}:${_round.winnerId}:${_round.winReason?.name}';
    if (_lastShownRoundResultKey == resultKey) {
      return;
    }
    _lastShownRoundResultKey = resultKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final winner = _round.winner;
      final reason = _round.winReason;
      final reasonLabel = switch (reason) {
        KangWinReason.kang => 'Kang',
        KangWinReason.winOut => 'Win Out',
        KangWinReason.emptyHand => 'Empty Hand',
        KangWinReason.draw => 'Draw',
        null => 'Finished',
      };
      final title = winner == null ? 'Round draw' : '${winner.name} wins';
      final body = winner == null
          ? _round.message ?? 'No winner this round.'
          : '${winner.name} wins by $reasonLabel.\n'
              'Total points: ${winner.gamePoints}';

      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            key: const ValueKey('kang-round-result-dialog'),
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                key: const ValueKey('kang-round-result-close-button'),
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
    final showIntro = _round.status == KangRoundStatus.notStarted;
    final showStartAction = _round.status == KangRoundStatus.notStarted ||
        _round.status == KangRoundStatus.finished;
    final showPlayActions = _round.status == KangRoundStatus.playing;
    final primaryPlayerId = _round.players.any((player) => player.id == 'you')
        ? 'you'
        : _round.currentPlayer?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: KangGameBoard(
            title: 'Kang Game',
            subtitle: showIntro
                ? 'Draw, drop, and let matching ranks bounce the turn back.'
                : null,
            round: _round,
            primaryPlayerId: primaryPlayerId,
            selectedCards: _selectedCards,
            onBack: () => Modular.to.navigate('/'),
            backButtonKey: const ValueKey('kang-back-button'),
            canDropPlayer: (player) =>
                _round.currentPlayer?.id == player.id &&
                (_round.turnPhase == KangTurnPhase.drew ||
                    _round.turnPhase == KangTurnPhase.respondingToDrop),
            hideCardsForPlayer: (_) => false,
            onCardTap: _selectCard,
            startAction: showStartAction
                ? FilledButton.icon(
                    key: const ValueKey('kang-start-round-button'),
                    onPressed: _startRound,
                    icon: Icon(
                      _round.status == KangRoundStatus.finished
                          ? Icons.refresh_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      _round.status == KangRoundStatus.finished
                          ? 'Next round'
                          : 'Start local round',
                    ),
                  )
                : null,
            drawAction: showPlayActions
                ? FilledButton.tonalIcon(
                    key: const ValueKey('kang-draw-card-button'),
                    onPressed: _round.status == KangRoundStatus.playing &&
                            (_round.turnPhase == KangTurnPhase.start ||
                                _round.turnPhase ==
                                    KangTurnPhase.respondingToDrop)
                        ? _drawCard
                        : null,
                    icon: const Icon(Icons.add_card_rounded),
                    label: const Text('Draw'),
                  )
                : null,
            dropAction: showPlayActions
                ? FilledButton.icon(
                    key: const ValueKey('kang-drop-card-button'),
                    onPressed:
                        _selectedCards.isEmpty ? null : _dropSelectedCard,
                    icon: const Icon(Icons.move_down_rounded),
                    label: const Text('Drop'),
                  )
                : null,
            kangAction: showPlayActions
                ? OutlinedButton.icon(
                    key: const ValueKey('kang-declare-button'),
                    onPressed: _round.status == KangRoundStatus.playing &&
                            _round.turnPhase == KangTurnPhase.start
                        ? _declareKang
                        : null,
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text('Kang!'),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class KangGameBoard extends StatelessWidget {
  const KangGameBoard({
    super.key,
    required this.title,
    required this.round,
    required this.selectedCards,
    required this.canDropPlayer,
    required this.hideCardsForPlayer,
    required this.onCardTap,
    this.subtitle,
    this.primaryPlayerId,
    this.onBack,
    this.backButtonKey,
    this.trailingHeader,
    this.startAction,
    this.drawAction,
    this.dropAction,
    this.kangAction,
  });

  final String title;
  final String? subtitle;
  final KangRoundState round;
  final String? primaryPlayerId;
  final List<KangCard> selectedCards;
  final bool Function(KangPlayerState player) canDropPlayer;
  final bool Function(KangPlayerState player) hideCardsForPlayer;
  final void Function(KangPlayerState player, KangCard card) onCardTap;
  final VoidCallback? onBack;
  final Key? backButtonKey;
  final Widget? trailingHeader;
  final Widget? startAction;
  final Widget? drawAction;
  final Widget? dropAction;
  final Widget? kangAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryPlayer = _primaryPlayer;
    final opponents = round.players
        .where((player) => player.id != primaryPlayer?.id)
        .toList();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton.filled(
                    key: backButtonKey,
                    tooltip: 'Back',
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColor.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ...(trailingHeader == null
                      ? const <Widget>[]
                      : [trailingHeader!]),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColor.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              KangRoundSummary(round: round),
              if (round.players.isEmpty) ...[
                const SizedBox(height: 16),
                if (startAction != null)
                  Align(alignment: Alignment.center, child: startAction!),
              ] else ...[
                const SizedBox(height: 12),
                if (opponents.isNotEmpty) ...[
                  _OpponentHandPanel(
                    players: opponents,
                    currentPlayerId: round.currentPlayer?.id,
                    hideCardsForPlayer: hideCardsForPlayer,
                  ),
                  const SizedBox(height: 8),
                ],
                _KangTableArea(
                  round: round,
                  primaryPlayerId: primaryPlayer?.id,
                  drawAction: drawAction,
                ),
                const SizedBox(height: 8),
                if (primaryPlayer != null)
                  KangPlayerHandCard(
                    player: primaryPlayer,
                    isCurrent: round.currentPlayer?.id == primaryPlayer.id,
                    canDrop: canDropPlayer(primaryPlayer),
                    selectedCards: selectedCards,
                    pendingDroppedCard: round.pendingDroppedCard,
                    lastDrawnCard: round.lastDrawnCard,
                    hideCards: hideCardsForPlayer(primaryPlayer),
                    onCardTap: (card) => onCardTap(primaryPlayer, card),
                  ),
                const SizedBox(height: 12),
                if (startAction != null)
                  Align(alignment: Alignment.center, child: startAction!)
                else
                  _KangActionBar(
                      dropAction: dropAction, kangAction: kangAction),
              ],
            ],
          ),
        ),
      ),
    );
  }

  KangPlayerState? get _primaryPlayer {
    if (round.players.isEmpty) {
      return null;
    }
    final id = primaryPlayerId;
    if (id != null) {
      for (final player in round.players) {
        if (player.id == id) {
          return player;
        }
      }
    }
    return round.currentPlayer ?? round.players.first;
  }
}

class _OpponentHandPanel extends StatelessWidget {
  const _OpponentHandPanel({
    required this.players,
    required this.currentPlayerId,
    required this.hideCardsForPlayer,
  });

  final List<KangPlayerState> players;
  final String? currentPlayerId;
  final bool Function(KangPlayerState player) hideCardsForPlayer;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.surface.withValues(alpha: 0.9),
        border: Border.all(color: AppColor.outline.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryBlueDark.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final player in players) ...[
              _OpponentHandRow(
                key: ValueKey('kang-player-${player.id}'),
                player: player,
                isCurrent: currentPlayerId == player.id,
                hideCards: hideCardsForPlayer(player),
              ),
              if (player != players.last) const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _OpponentHandRow extends StatelessWidget {
  const _OpponentHandRow({
    super.key,
    required this.player,
    required this.isCurrent,
    required this.hideCards,
  });

  final KangPlayerState player;
  final bool isCurrent;
  final bool hideCards;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sortedHand = KangRules.sortedCards(player.hand);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColor.blush.withValues(alpha: 0.76)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCurrent ? 10 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kangDisplayName(player.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${player.gamePoints} pts',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColor.blushDeep,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final card in sortedHand) ...[
                    if (hideCards)
                      const _CardBack()
                    else
                      _PlayingCard(
                        card: card,
                        isEnabled: false,
                        isSelected: false,
                        isMatchHint: false,
                        isLastDrawn: false,
                        onTap: () {},
                      ),
                    const SizedBox(width: 10),
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

class _KangTableArea extends StatelessWidget {
  const _KangTableArea({
    required this.round,
    required this.primaryPlayerId,
    required this.drawAction,
  });

  final KangRoundState round;
  final String? primaryPlayerId;
  final Widget? drawAction;

  @override
  Widget build(BuildContext context) {
    final droppedCards = _droppedCardsBySide;

    return SizedBox(
      height: 238,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 114,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${round.drawPile.length}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const _DrawPileCard(),
                  if (drawAction != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(width: 108, height: 46, child: drawAction!),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 16,
            child: _TableCardSlot(
              label: 'Opponent',
              cards: droppedCards.right,
              emptyIcon: Icons.style_rounded,
            ),
          ),
          Positioned(
            left: 176,
            bottom: 0,
            child: _TableCardSlot(
              label: 'Your drop',
              cards: droppedCards.left,
              emptyIcon: Icons.move_down_rounded,
            ),
          ),
        ],
      ),
    );
  }

  ({List<KangCard> left, List<KangCard> right}) get _droppedCardsBySide {
    List<KangCard> left = const [];
    List<KangCard> right = const [];
    final primaryId = primaryPlayerId;
    for (final entry in round.tableDroppedCards.entries) {
      if (entry.value.isEmpty) {
        continue;
      }
      if (entry.key == primaryId) {
        left = entry.value;
      } else {
        right = entry.value;
      }
    }
    if (left.isEmpty &&
        right.isEmpty &&
        round.pendingDroppedCard != null &&
        round.pendingDropperIndex != null &&
        round.pendingDropperIndex! < round.players.length) {
      final dropper = round.players[round.pendingDropperIndex!];
      if (dropper.id == primaryId) {
        left = [round.pendingDroppedCard!];
      } else {
        right = [round.pendingDroppedCard!];
      }
    }
    return (left: left, right: right);
  }
}

class _DrawPileCard extends StatelessWidget {
  const _DrawPileCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      height: 136,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 14,
            top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColor.primaryBlueDark.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SizedBox(width: 86, height: 120),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColor.primaryBlue,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryBlueDark.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: SizedBox(
              width: 92,
              height: 126,
              child: Center(
                child: Icon(
                  Icons.style_rounded,
                  color: AppColor.surface.withValues(alpha: 0.9),
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableCardSlot extends StatelessWidget {
  const _TableCardSlot({
    required this.label,
    required this.cards,
    required this.emptyIcon,
  });

  final String label;
  final List<KangCard> cards;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cards.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColor.surface.withValues(alpha: 0.42),
              border: Border.all(color: AppColor.outline),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: 66,
              height: 94,
              child: Icon(emptyIcon, color: AppColor.textSecondary),
            ),
          )
        else
          _DroppedCardStack(cards: cards),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColor.textSecondary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _DroppedCardStack extends StatelessWidget {
  const _DroppedCardStack({required this.cards});

  final List<KangCard> cards;

  @override
  Widget build(BuildContext context) {
    final visibleBackCards = cards.length <= 1
        ? 0
        : cards.length > 4
            ? 3
            : cards.length - 1;
    final topCard = cards.last;

    return SizedBox(
      width: 104,
      height: 134,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = visibleBackCards; index > 0; index--)
            Positioned(
              left: index * 5,
              top: index * 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColor.surfaceMuted,
                  border: Border.all(color: AppColor.outline),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryBlueDark.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const SizedBox(width: 92, height: 126),
              ),
            ),
          _PlayingCard(
            card: topCard,
            width: 92,
            isEnabled: false,
            isSelected: false,
            isMatchHint: false,
            isLastDrawn: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _KangActionBar extends StatelessWidget {
  const _KangActionBar({required this.dropAction, required this.kangAction});

  final Widget? dropAction;
  final Widget? kangAction;

  @override
  Widget build(BuildContext context) {
    if (dropAction == null && kangAction == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (dropAction != null)
          Expanded(child: SizedBox(height: 58, child: dropAction!)),
        if (dropAction != null && kangAction != null) const SizedBox(width: 14),
        if (kangAction != null)
          Expanded(child: SizedBox(height: 58, child: kangAction!)),
      ],
    );
  }
}

class KangRoundSummary extends StatelessWidget {
  const KangRoundSummary({super.key, required this.round});

  final KangRoundState round;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final winner = round.winner;
    final discardTop = round.discardTop?.id ?? '-';
    final currentPlayer = round.currentPlayer == null
        ? '-'
        : kangDisplayName(round.currentPlayer!.name);
    final roundLabel = round.status == KangRoundStatus.notStarted
        ? 'No round started'
        : 'Round ${round.roundNumber}';
    final stateLabel = winner == null
        ? kangDisplayMessage(
            round,
            round.message ?? 'Start a local round to test Kang rules.',
          )
        : '${kangDisplayName(winner.name)} wins by ${round.winReason?.name ?? 'finished'}';

    return DecoratedBox(
      key: key ?? const ValueKey('kang-round-summary'),
      decoration: BoxDecoration(
        color: AppColor.surface.withValues(alpha: 0.9),
        border: Border.all(color: AppColor.outline.withValues(alpha: 0.72)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryBlueDark.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColor.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    width: 92,
                    height: 62,
                    child: Center(
                      child: Text(
                        roundLabel,
                        textAlign: TextAlign.center,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColor.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    stateLabel,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (round.status != KangRoundStatus.notStarted) ...[
              const SizedBox(height: 12),
              Text(
                winner == null
                    ? 'Turn: $currentPlayer | Draw pile: ${round.drawPile.length} | Discard: $discardTop'
                    : 'Winner: ${kangDisplayName(winner.name)} | Reason: ${round.winReason?.name ?? '-'}',
                textAlign: TextAlign.center,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColor.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class KangPlayerHandCard extends StatelessWidget {
  const KangPlayerHandCard({
    super.key,
    required this.player,
    required this.isCurrent,
    required this.canDrop,
    required this.selectedCards,
    required this.pendingDroppedCard,
    required this.lastDrawnCard,
    required this.onCardTap,
    this.hideCards = false,
  });

  final KangPlayerState player;
  final bool isCurrent;
  final bool canDrop;
  final List<KangCard> selectedCards;
  final KangCard? pendingDroppedCard;
  final KangCard? lastDrawnCard;
  final ValueChanged<KangCard> onCardTap;
  final bool hideCards;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final matchingRanks = KangRules.availablePairRanks(player.hand);
    final sortedHand = KangRules.sortedCards(player.hand);
    final detailLabel = hideCards
        ? '${player.hand.length} cards'
        : 'Hand value: ${KangRules.handValue(player.hand)}'
            ' | Matching ranks: ${matchingRanks.isEmpty ? '-' : matchingRanks.map((rank) => rank.label).join(', ')}';

    return DecoratedBox(
      key: key ?? ValueKey('kang-player-${player.id}'),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColor.blush.withValues(alpha: 0.76)
            : AppColor.surface.withValues(alpha: 0.88),
        border: Border.all(
          color: isCurrent
              ? AppColor.blushDeep.withValues(alpha: 0.28)
              : AppColor.outline.withValues(alpha: 0.7),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    kangDisplayName(player.name),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${player.gamePoints} pts',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColor.blushDeep,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final card in sortedHand)
                  if (hideCards)
                    const _CardBack()
                  else
                    _PlayingCard(
                      card: card,
                      isEnabled: canDrop &&
                          (pendingDroppedCard == null ||
                              card.rank == pendingDroppedCard?.rank),
                      isSelected: selectedCards.contains(card),
                      isMatchHint: pendingDroppedCard != null &&
                          card.rank == pendingDroppedCard?.rank,
                      isLastDrawn: lastDrawnCard == card,
                      onTap: () => onCardTap(card),
                    ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${isCurrent ? 'Current turn | ' : ''}$detailLabel',
              style: textTheme.bodySmall?.copyWith(
                color: AppColor.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  static const _assetAspectRatio = 167.0869141 / 242.6669922;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: AspectRatio(
        aspectRatio: _assetAspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.primaryBlue,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColor.primaryBlueDark),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryBlueDark.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.style_rounded,
              size: 24,
              color: AppColor.surface.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayingCard extends StatelessWidget {
  const _PlayingCard({
    required this.card,
    required this.isEnabled,
    required this.isSelected,
    required this.isMatchHint,
    required this.isLastDrawn,
    required this.onTap,
    this.width = 58,
  });

  final KangCard card;
  final bool isEnabled;
  final bool isSelected;
  final bool isMatchHint;
  final bool isLastDrawn;
  final VoidCallback onTap;
  final double width;

  static const _assetAspectRatio = 167.0869141 / 242.6669922;

  @override
  Widget build(BuildContext context) {
    final highlightColor = isSelected
        ? AppColor.blushDeep
        : isMatchHint
            ? AppColor.warmGold
            : isLastDrawn
                ? const Color(0xFF2EAD5F)
                : isEnabled
                    ? AppColor.primaryBlue
                    : AppColor.outline;
    final hasStrongHighlight = isSelected || isMatchHint || isLastDrawn;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('kang-card-${card.id}'),
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: _assetAspectRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected
                            ? AppColor.blushDeep
                            : AppColor.primaryBlueDark)
                        .withValues(alpha: isSelected ? 0.14 : 0.05),
                    blurRadius: isSelected ? 16 : 10,
                    offset: Offset(0, isSelected ? 8 : 5),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: ColoredBox(
                      color: AppColor.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: SvgPicture.asset(
                          card.assetPath,
                          fit: BoxFit.contain,
                          semanticsLabel: card.id,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: highlightColor,
                          width: hasStrongHighlight ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
