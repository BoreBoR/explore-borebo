import 'package:benjii/modules/kang_game/controller/local_kang_game_controller.dart';
import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:benjii/modules/kang_game/model/kang_rules.dart';
import 'package:benjii/util/app_background.dart';
import 'package:benjii/util/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final showIntro = _round.status == KangRoundStatus.notStarted;
    final showStartAction =
        _round.status == KangRoundStatus.notStarted ||
        _round.status == KangRoundStatus.finished;
    final showPlayActions = _round.status == KangRoundStatus.playing;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filled(
                        key: const ValueKey('kang-back-button'),
                        tooltip: 'Back',
                        onPressed: () => Modular.to.navigate('/'),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    if (showIntro) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.secondaryContainer,
                                colorScheme.primaryContainer.withValues(
                                  alpha: 0.62,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryBlueDark.withValues(
                                  alpha: 0.09,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.style_rounded,
                            color: AppColor.primaryBlue,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Kang Game',
                        textAlign: TextAlign.center,
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Draw, drop, and let matching ranks bounce the turn back.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    KangRoundSummary(round: _round),
                    const SizedBox(height: 18),
                    for (final player in _round.players) ...[
                      KangPlayerHandCard(
                        player: player,
                        isCurrent: _round.currentPlayer?.id == player.id,
                        canDrop:
                            _round.currentPlayer?.id == player.id &&
                            (_round.turnPhase == KangTurnPhase.drew ||
                                _round.turnPhase ==
                                    KangTurnPhase.respondingToDrop),
                        selectedCards: _selectedCards,
                        pendingDroppedCard: _round.pendingDroppedCard,
                        lastDrawnCard: _round.lastDrawnCard,
                        onCardTap: (card) => _selectCard(player, card),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    if (showStartAction) ...[
                      Align(
                        alignment: Alignment.center,
                        child: FilledButton.icon(
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
                        ),
                      ),
                    ],
                    if (showPlayActions)
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          FilledButton.tonalIcon(
                            key: const ValueKey('kang-draw-card-button'),
                            onPressed:
                                _round.status == KangRoundStatus.playing &&
                                    _round.turnPhase == KangTurnPhase.start
                                ? _drawCard
                                : null,
                            icon: const Icon(Icons.add_card_rounded),
                            label: const Text('Draw card'),
                          ),
                          FilledButton.icon(
                            key: const ValueKey('kang-drop-card-button'),
                            onPressed: _selectedCards.isEmpty
                                ? null
                                : _dropSelectedCard,
                            icon: const Icon(Icons.move_down_rounded),
                            label: const Text('Drop card'),
                          ),
                          OutlinedButton.icon(
                            key: const ValueKey('kang-declare-button'),
                            onPressed:
                                _round.status == KangRoundStatus.playing &&
                                    _round.turnPhase == KangTurnPhase.start
                                ? _declareKang
                                : null,
                            icon: const Icon(Icons.flag_rounded),
                            label: const Text('Declare Kang'),
                          ),
                        ],
                      ),
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

class KangRoundSummary extends StatelessWidget {
  const KangRoundSummary({super.key, required this.round});

  final KangRoundState round;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final winner = round.winner;
    final discardTop = round.discardTop?.id ?? '-';
    final currentPlayer = round.currentPlayer?.name ?? '-';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              round.status == KangRoundStatus.notStarted
                  ? 'No round started'
                  : 'Round ${round.roundNumber}',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              round.message ?? 'Start a local round to test Kang rules.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColor.textSecondary,
              ),
            ),
            if (round.status != KangRoundStatus.notStarted) ...[
              const SizedBox(height: 12),
              Text(
                winner == null
                    ? 'Turn: $currentPlayer | Draw pile: ${round.drawPile.length} | Discard: $discardTop'
                    : 'Winner: ${winner.name} | Reason: ${round.winReason?.name ?? '-'}',
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
                    player.name,
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
                      isEnabled:
                          canDrop &&
                          (pendingDroppedCard == null ||
                              card.rank == pendingDroppedCard?.rank),
                      isSelected: selectedCards.contains(card),
                      isMatchHint:
                          pendingDroppedCard != null &&
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
  });

  final KangCard card;
  final bool isEnabled;
  final bool isSelected;
  final bool isMatchHint;
  final bool isLastDrawn;
  final VoidCallback onTap;

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
          width: 58,
          child: AspectRatio(
            aspectRatio: _assetAspectRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isSelected
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
