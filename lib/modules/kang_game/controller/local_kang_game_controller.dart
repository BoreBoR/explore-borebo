import 'dart:math';

import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:benjii/modules/kang_game/model/kang_rules.dart';

class LocalKangGameController {
  LocalKangGameController({Random? random}) : _random = random ?? Random();

  final Random _random;

  KangRoundState startRound(KangRoundState previous) {
    final deck = KangRules.shuffledDeck(_random);
    final youHand = deck.take(5).toList();
    final benjiHand = deck.skip(5).take(5).toList();
    final drawPile = deck.skip(11).toList();
    final discardPile = [deck[10]];

    final previousSeats = previous.players.length >= 2
        ? previous.players.take(2).toList()
        : const [
            KangPlayerState(id: 'you', name: 'You', hand: []),
            KangPlayerState(id: 'benji', name: 'Benji', hand: []),
          ];
    final previousPlayers = {
      for (final player in previous.players) player.id: player,
    };
    final players = [
      KangPlayerState(
        id: previousSeats[0].id,
        name: previousSeats[0].name,
        hand: youHand,
        gamePoints: previousPlayers[previousSeats[0].id]?.gamePoints ?? 0,
        pendingLossPenaltyPoints:
            previousPlayers[previousSeats[0].id]?.pendingLossPenaltyPoints ?? 0,
      ),
      KangPlayerState(
        id: previousSeats[1].id,
        name: previousSeats[1].name,
        hand: benjiHand,
        gamePoints: previousPlayers[previousSeats[1].id]?.gamePoints ?? 0,
        pendingLossPenaltyPoints:
            previousPlayers[previousSeats[1].id]?.pendingLossPenaltyPoints ?? 0,
      ),
    ];
    final startingTurnIndex = _startingTurnIndex(previous, players);

    final baseState = KangRoundState(
      players: players,
      drawPile: drawPile,
      discardPile: discardPile,
      currentTurnIndex: startingTurnIndex,
      roundNumber: previous.roundNumber + 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.start,
    );

    final winOutPlayers = players
        .where((player) => KangRules.hasWinOut(player.hand))
        .toList();
    if (winOutPlayers.isEmpty) {
      return baseState.copyWith(
        message: 'Round ${baseState.roundNumber} started.',
      );
    }
    if (winOutPlayers.length > 1) {
      return baseState.copyWith(
        status: KangRoundStatus.finished,
        winReason: KangWinReason.draw,
        message: 'Both players have Win Out. Round is a draw.',
      );
    }

    final winner = winOutPlayers.single;
    return _finishRound(
      baseState,
      winnerId: winner.id,
      reason: KangWinReason.winOut,
      message: '${winner.name} wins out immediately.',
    );
  }

  KangRoundState declareKang(KangRoundState state, String declarerId) {
    _requirePlaying(state);
    if (state.currentPlayer?.id != declarerId) {
      throw StateError('Only the current player can declare Kang.');
    }
    if (state.turnPhase != KangTurnPhase.start) {
      throw StateError('Kang can only be declared at the start of turn.');
    }

    final winnerId = KangRules.kangWinnerId(
      players: state.players,
      declarerId: declarerId,
    );
    final winner = state.players.firstWhere((player) => player.id == winnerId);

    return _finishRound(
      state,
      winnerId: winnerId,
      reason: KangWinReason.kang,
      message: '${winner.name} wins by Kang.',
    );
  }

  KangRoundState drawForCurrentPlayer(KangRoundState state) {
    _requirePlaying(state);
    if (state.turnPhase != KangTurnPhase.start &&
        state.turnPhase != KangTurnPhase.respondingToDrop) {
      throw StateError('Player already drew this turn.');
    }
    if (state.drawPile.isEmpty) {
      throw StateError('Draw pile is empty.');
    }

    final current = state.currentPlayer;
    if (current == null) {
      throw StateError('No current player.');
    }

    final drawPile = [...state.drawPile];
    final drawnCard = drawPile.removeLast();
    final updatedPlayer = current.copyWith(hand: [...current.hand, drawnCard]);
    final players = state.players
        .map((player) => player.id == current.id ? updatedPlayer : player)
        .toList();

    return state.copyWith(
      players: players,
      drawPile: drawPile,
      turnPhase: KangTurnPhase.drew,
      clearPendingDrop: true,
      lastDrawnCard: drawnCard,
      message: '${current.name} drew a card. Choose one card to drop.',
    );
  }

  KangRoundState dropCard(KangRoundState state, KangCard card) {
    return dropCards(state, [card]);
  }

  KangRoundState dropCards(KangRoundState state, List<KangCard> cards) {
    _requirePlaying(state);
    if (state.turnPhase != KangTurnPhase.drew) {
      throw StateError('Draw before dropping a card.');
    }
    if (cards.isEmpty) {
      throw StateError('Choose at least one card to drop.');
    }

    final current = state.currentPlayer;
    if (current == null) {
      throw StateError('No current player.');
    }
    final firstRank = cards.first.rank;
    for (final card in cards) {
      if (card.rank != firstRank) {
        throw StateError('Drop cards must have the same rank.');
      }
      if (!current.hand.contains(card)) {
        throw StateError('${current.name} does not have ${card.id}.');
      }
    }

    final opponentIndex = _nextTurnIndex(state);
    final opponent = state.players[opponentIndex];
    final currentHand = [...current.hand];
    for (final card in cards) {
      currentHand.remove(card);
    }
    final discardPile = [...state.discardPile, ...cards];
    final updatedCurrent = current.copyWith(hand: currentHand);
    final players = state.players.map((player) {
      if (player.id == updatedCurrent.id) {
        return updatedCurrent;
      }
      return player;
    }).toList();
    if (updatedCurrent.hand.isEmpty) {
      return _finishRound(
        state.copyWith(
          players: players,
          discardPile: discardPile,
          clearPendingDrop: true,
          tableDroppedCards: {
            ...state.tableDroppedCards,
            updatedCurrent.id: cards,
          },
          droppedCardsByPlayer: _appendDroppedCards(
            state,
            updatedCurrent.id,
            cards,
          ),
          clearLastDrawnCard: true,
        ),
        winnerId: updatedCurrent.id,
        reason: KangWinReason.emptyHand,
        pointsOverride: 1,
        message: '${updatedCurrent.name} dropped every card and wins.',
      );
    }

    var nextTurnIndex = opponentIndex;
    final droppedLabels = cards.map((card) => card.id).join(', ');
    var message =
        '${current.name} dropped $droppedLabels. ${opponent.name} turn.';
    var turnPhase = KangTurnPhase.start;
    KangCard? pendingDroppedCard;
    int? pendingDropperIndex;

    final matchingCard = _firstCardOfRank(opponent.hand, firstRank);
    if (matchingCard != null) {
      nextTurnIndex = opponentIndex;
      turnPhase = KangTurnPhase.respondingToDrop;
      pendingDroppedCard = cards.first;
      pendingDropperIndex = state.currentTurnIndex;
      message =
          '${current.name} dropped $droppedLabels. '
          '${opponent.name} has a matching rank. Match it or draw.';
    }

    return state.copyWith(
      players: players,
      discardPile: discardPile,
      currentTurnIndex: nextTurnIndex,
      turnPhase: turnPhase,
      pendingDroppedCard: pendingDroppedCard,
      pendingDropperIndex: pendingDropperIndex,
      tableDroppedCards: {...state.tableDroppedCards, updatedCurrent.id: cards},
      droppedCardsByPlayer: _appendDroppedCards(
        state,
        updatedCurrent.id,
        cards,
      ),
      clearPendingDrop: pendingDroppedCard == null,
      clearLastDrawnCard: true,
      message: message,
    );
  }

  KangRoundState respondToDroppedCard(KangRoundState state, KangCard card) {
    return respondToDroppedCards(state, [card]);
  }

  KangRoundState respondToDroppedCards(
    KangRoundState state,
    List<KangCard> cards,
  ) {
    _requirePlaying(state);
    if (state.turnPhase != KangTurnPhase.respondingToDrop) {
      throw StateError('There is no dropped card to respond to.');
    }
    if (cards.isEmpty) {
      throw StateError('Choose at least one matching card.');
    }

    final pendingDroppedCard = state.pendingDroppedCard;
    final pendingDropperIndex = state.pendingDropperIndex;
    final current = state.currentPlayer;
    if (pendingDroppedCard == null || pendingDropperIndex == null) {
      throw StateError('Missing dropped card response state.');
    }
    if (current == null) {
      throw StateError('No current player.');
    }
    for (final card in cards) {
      if (card.rank != pendingDroppedCard.rank) {
        throw StateError('Choose a matching ${pendingDroppedCard.rank.label}.');
      }
      if (!current.hand.contains(card)) {
        throw StateError('${current.name} does not have ${card.id}.');
      }
    }

    final currentHand = [...current.hand];
    for (final card in cards) {
      currentHand.remove(card);
    }
    final updatedCurrent = current.copyWith(hand: currentHand);
    final players = state.players
        .map(
          (player) => player.id == updatedCurrent.id ? updatedCurrent : player,
        )
        .toList();
    final dropper = state.players[pendingDropperIndex];
    if (updatedCurrent.hand.isEmpty) {
      return _finishRound(
        state.copyWith(
          players: players,
          discardPile: [...state.discardPile, ...cards],
          currentTurnIndex: pendingDropperIndex,
          clearPendingDrop: true,
          tableDroppedCards: {
            ...state.tableDroppedCards,
            updatedCurrent.id: cards,
          },
          droppedCardsByPlayer: _appendDroppedCards(
            state,
            updatedCurrent.id,
            cards,
          ),
          clearLastDrawnCard: true,
        ),
        winnerId: updatedCurrent.id,
        reason: KangWinReason.emptyHand,
        pointsOverride: 1,
        winnerPendingLossPenaltyPoints: 2,
        message:
            '${updatedCurrent.name} matched every card and wins. '
            'If they lose next round, they lose 2 points.',
      );
    }

    return state.copyWith(
      players: players,
      discardPile: [...state.discardPile, ...cards],
      currentTurnIndex: pendingDropperIndex,
      turnPhase: KangTurnPhase.start,
      clearPendingDrop: true,
      tableDroppedCards: {...state.tableDroppedCards, updatedCurrent.id: cards},
      droppedCardsByPlayer: _appendDroppedCards(
        state,
        updatedCurrent.id,
        cards,
      ),
      clearLastDrawnCard: true,
      message:
          '${current.name} matched ${cards.map((card) => card.id).join(', ')}. ${dropper.name} plays again.',
    );
  }

  KangRoundState _finishRound(
    KangRoundState state, {
    required String winnerId,
    required KangWinReason reason,
    required String message,
    int? pointsOverride,
    int winnerPendingLossPenaltyPoints = 0,
  }) {
    final players = state.players.map((player) {
      if (player.id == winnerId) {
        return player.copyWith(
          gamePoints:
              player.gamePoints +
              (pointsOverride ?? KangRules.pointsForWinningHand(player.hand)),
          pendingLossPenaltyPoints: winnerPendingLossPenaltyPoints,
        );
      }
      return player.copyWith(
        gamePoints: player.gamePoints - player.pendingLossPenaltyPoints,
        pendingLossPenaltyPoints: 0,
      );
    }).toList();

    return state.copyWith(
      players: players,
      status: KangRoundStatus.finished,
      winnerId: winnerId,
      winReason: reason,
      message: message,
    );
  }

  void _requirePlaying(KangRoundState state) {
    if (state.status != KangRoundStatus.playing) {
      throw StateError('Round is not playing.');
    }
  }

  int _nextTurnIndex(KangRoundState state) {
    return (state.currentTurnIndex + 1) % state.players.length;
  }

  int _startingTurnIndex(
    KangRoundState previous,
    List<KangPlayerState> players,
  ) {
    final winnerId = previous.winnerId;
    if (winnerId == null) {
      return 0;
    }

    final winnerIndex = players.indexWhere((player) => player.id == winnerId);
    return winnerIndex == -1 ? 0 : winnerIndex;
  }

  Map<String, List<KangCard>> _appendDroppedCards(
    KangRoundState state,
    String playerId,
    List<KangCard> cards,
  ) {
    return {
      ...state.droppedCardsByPlayer,
      playerId: [
        ...(state.droppedCardsByPlayer[playerId] ?? const <KangCard>[]),
        ...cards,
      ],
    };
  }

  KangCard? _firstCardOfRank(List<KangCard> cards, KangRank rank) {
    for (final card in cards) {
      if (card.rank == rank) {
        return card;
      }
    }
    return null;
  }
}
