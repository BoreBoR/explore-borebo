import 'package:benjii/modules/kang_game/controller/local_kang_game_controller.dart';
import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  KangCard card(KangRank rank, KangSuit suit) {
    return KangCard(rank: rank, suit: suit);
  }

  test('previous winner starts the next round', () {
    final controller = LocalKangGameController();
    final previous = KangRoundState(
      players: const [
        KangPlayerState(id: 'host', name: 'Host', hand: []),
        KangPlayerState(id: 'guest', name: 'Guest', hand: []),
      ],
      drawPile: const [],
      discardPile: const [],
      currentTurnIndex: 0,
      roundNumber: 1,
      status: KangRoundStatus.finished,
      turnPhase: KangTurnPhase.start,
      winnerId: 'guest',
      winReason: KangWinReason.kang,
    );

    final next = controller.startRound(previous);

    expect(next.currentPlayer?.id, 'guest');
  });

  test('draw round keeps host starting the next round', () {
    final controller = LocalKangGameController();
    final previous = KangRoundState(
      players: const [
        KangPlayerState(id: 'host', name: 'Host', hand: []),
        KangPlayerState(id: 'guest', name: 'Guest', hand: []),
      ],
      drawPile: const [],
      discardPile: const [],
      currentTurnIndex: 1,
      roundNumber: 1,
      status: KangRoundStatus.finished,
      turnPhase: KangTurnPhase.start,
      winReason: KangWinReason.draw,
    );

    final next = controller.startRound(previous);

    expect(next.currentPlayer?.id, 'host');
  });

  test('dropping a matched rank asks opponent to respond', () {
    final controller = LocalKangGameController();
    final droppedCard = card(KangRank.ace, KangSuit.spades);
    final matchingCard = card(KangRank.ace, KangSuit.hearts);
    final state = KangRoundState(
      players: [
        KangPlayerState(
          id: 'you',
          name: 'You',
          hand: [droppedCard, card(KangRank.five, KangSuit.clubs)],
        ),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [matchingCard, card(KangRank.nine, KangSuit.diamonds)],
        ),
      ],
      drawPile: const [],
      discardPile: const [],
      currentTurnIndex: 0,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.drew,
    );

    final next = controller.dropCard(state, droppedCard);

    expect(next.currentPlayer?.id, 'benji');
    expect(next.turnPhase, KangTurnPhase.respondingToDrop);
    expect(next.pendingDroppedCard, droppedCard);
    expect(next.pendingDropperIndex, 0);
    expect(next.discardPile, [droppedCard]);
    expect(next.tableDroppedCards, {
      'you': [droppedCard],
    });
    expect(next.droppedCardsByPlayer, {
      'you': [droppedCard],
    });
    expect(next.players[0].hand, isNot(contains(droppedCard)));
    expect(next.players[1].hand, contains(matchingCard));
  });

  test('opponent response drops matching card and returns turn', () {
    final controller = LocalKangGameController();
    final droppedCard = card(KangRank.ace, KangSuit.spades);
    final matchingCard = card(KangRank.ace, KangSuit.hearts);
    final secondMatchingCard = card(KangRank.ace, KangSuit.diamonds);
    final state = KangRoundState(
      players: [
        KangPlayerState(id: 'you', name: 'You', hand: const []),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [
            matchingCard,
            secondMatchingCard,
            card(KangRank.nine, KangSuit.diamonds),
          ],
        ),
      ],
      drawPile: const [],
      discardPile: [droppedCard],
      currentTurnIndex: 1,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.respondingToDrop,
      pendingDroppedCard: droppedCard,
      pendingDropperIndex: 0,
      tableDroppedCards: {
        'you': [droppedCard],
      },
      droppedCardsByPlayer: {
        'you': [droppedCard],
      },
    );

    final next = controller.respondToDroppedCards(state, [
      matchingCard,
      secondMatchingCard,
    ]);

    expect(next.currentPlayer?.id, 'you');
    expect(next.turnPhase, KangTurnPhase.start);
    expect(next.pendingDroppedCard, isNull);
    expect(next.discardPile, [droppedCard, matchingCard, secondMatchingCard]);
    expect(next.tableDroppedCards, {
      'you': [droppedCard],
      'benji': [matchingCard, secondMatchingCard],
    });
    expect(next.droppedCardsByPlayer, {
      'you': [droppedCard],
      'benji': [matchingCard, secondMatchingCard],
    });
    expect(next.players[1].hand, [card(KangRank.nine, KangSuit.diamonds)]);
  });

  test('opponent with matching rank may draw instead of responding', () {
    final controller = LocalKangGameController();
    final droppedCard = card(KangRank.three, KangSuit.hearts);
    final matchingCard = card(KangRank.three, KangSuit.diamonds);
    final drawnCard = card(KangRank.king, KangSuit.clubs);
    final state = KangRoundState(
      players: [
        KangPlayerState(id: 'you', name: 'You', hand: const []),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [matchingCard, card(KangRank.nine, KangSuit.diamonds)],
        ),
      ],
      drawPile: [drawnCard],
      discardPile: [droppedCard],
      currentTurnIndex: 1,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.respondingToDrop,
      pendingDroppedCard: droppedCard,
      pendingDropperIndex: 0,
      tableDroppedCards: {
        'you': [droppedCard],
      },
      droppedCardsByPlayer: {
        'you': [droppedCard],
      },
    );

    final next = controller.drawForCurrentPlayer(state);

    expect(next.currentPlayer?.id, 'benji');
    expect(next.turnPhase, KangTurnPhase.drew);
    expect(next.pendingDroppedCard, isNull);
    expect(next.pendingDropperIndex, isNull);
    expect(next.players[1].hand, [
      matchingCard,
      card(KangRank.nine, KangSuit.diamonds),
      drawnCard,
    ]);
    expect(next.tableDroppedCards, {
      'you': [droppedCard],
    });
  });

  test('normal drop keeps the other player dropped card visible', () {
    final controller = LocalKangGameController();
    final firstPlayerDrop = card(KangRank.king, KangSuit.hearts);
    final secondPlayerDrop = card(KangRank.seven, KangSuit.hearts);
    final state = KangRoundState(
      players: [
        KangPlayerState(id: 'you', name: 'You', hand: const []),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [secondPlayerDrop, card(KangRank.nine, KangSuit.diamonds)],
        ),
      ],
      drawPile: const [],
      discardPile: [firstPlayerDrop],
      currentTurnIndex: 1,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.drew,
      tableDroppedCards: {
        'you': [firstPlayerDrop],
      },
      droppedCardsByPlayer: {
        'you': [firstPlayerDrop],
      },
    );

    final next = controller.dropCard(state, secondPlayerDrop);

    expect(next.discardPile, [firstPlayerDrop, secondPlayerDrop]);
    expect(next.tableDroppedCards, {
      'you': [firstPlayerDrop],
      'benji': [secondPlayerDrop],
    });
    expect(next.droppedCardsByPlayer, {
      'you': [firstPlayerDrop],
      'benji': [secondPlayerDrop],
    });
  });

  test('dropping without opponent match passes turn', () {
    final controller = LocalKangGameController();
    final droppedCard = card(KangRank.ace, KangSuit.spades);
    final state = KangRoundState(
      players: [
        KangPlayerState(
          id: 'you',
          name: 'You',
          hand: [droppedCard, card(KangRank.five, KangSuit.clubs)],
        ),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [card(KangRank.nine, KangSuit.diamonds)],
        ),
      ],
      drawPile: const [],
      discardPile: const [],
      currentTurnIndex: 0,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.drew,
    );

    final next = controller.dropCard(state, droppedCard);

    expect(next.currentPlayer?.id, 'benji');
    expect(next.discardPile, [droppedCard]);
  });

  test('same player dropped history appends previous drops', () {
    final controller = LocalKangGameController();
    final previousDrop = card(KangRank.three, KangSuit.clubs);
    final nextDrop = card(KangRank.king, KangSuit.spades);
    final state = KangRoundState(
      players: [
        KangPlayerState(id: 'you', name: 'You', hand: [nextDrop]),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [card(KangRank.nine, KangSuit.diamonds)],
        ),
      ],
      drawPile: const [],
      discardPile: [previousDrop],
      currentTurnIndex: 0,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.drew,
      droppedCardsByPlayer: {
        'you': [previousDrop],
      },
    );

    final next = controller.dropCard(state, nextDrop);

    expect(next.discardPile, [previousDrop, nextDrop]);
    expect(next.droppedCardsByPlayer['you'], [previousDrop, nextDrop]);
  });

  test('current player can drop multiple same-rank cards', () {
    final controller = LocalKangGameController();
    final firstFour = card(KangRank.four, KangSuit.spades);
    final secondFour = card(KangRank.four, KangSuit.hearts);
    final state = KangRoundState(
      players: [
        KangPlayerState(
          id: 'you',
          name: 'You',
          hand: [firstFour, secondFour, card(KangRank.ace, KangSuit.clubs)],
        ),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [card(KangRank.nine, KangSuit.diamonds)],
        ),
      ],
      drawPile: const [],
      discardPile: const [],
      currentTurnIndex: 0,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.drew,
    );

    final next = controller.dropCards(state, [firstFour, secondFour]);

    expect(next.discardPile, [firstFour, secondFour]);
    expect(next.players[0].hand, isNot(contains(firstFour)));
    expect(next.players[0].hand, isNot(contains(secondFour)));
    expect(next.players[0].hand, hasLength(1));
    expect(next.currentPlayer?.id, 'benji');
  });

  test('current player wins one point when dropping every card', () {
    final controller = LocalKangGameController();
    final firstFour = card(KangRank.four, KangSuit.spades);
    final secondFour = card(KangRank.four, KangSuit.hearts);
    final state = KangRoundState(
      players: [
        KangPlayerState(id: 'you', name: 'You', hand: [firstFour, secondFour]),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [card(KangRank.four, KangSuit.diamonds)],
        ),
      ],
      drawPile: const [],
      discardPile: const [],
      currentTurnIndex: 0,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.drew,
    );

    final next = controller.dropCards(state, [firstFour, secondFour]);

    expect(next.status, KangRoundStatus.finished);
    expect(next.winnerId, 'you');
    expect(next.winReason, KangWinReason.emptyHand);
    expect(next.players[0].gamePoints, 1);
    expect(next.players[0].hand, isEmpty);
  });

  test('opponent response wins one point and risks losing two next round', () {
    final controller = LocalKangGameController();
    final droppedCard = card(KangRank.ace, KangSuit.spades);
    final matchingCard = card(KangRank.ace, KangSuit.hearts);
    final state = KangRoundState(
      players: [
        KangPlayerState(id: 'you', name: 'You', hand: const []),
        KangPlayerState(id: 'benji', name: 'Benji', hand: [matchingCard]),
      ],
      drawPile: const [],
      discardPile: [droppedCard],
      currentTurnIndex: 1,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.respondingToDrop,
      pendingDroppedCard: droppedCard,
      pendingDropperIndex: 0,
    );

    final next = controller.respondToDroppedCard(state, matchingCard);

    expect(next.status, KangRoundStatus.finished);
    expect(next.winnerId, 'benji');
    expect(next.winReason, KangWinReason.emptyHand);
    expect(next.players[1].gamePoints, 1);
    expect(next.players[1].pendingLossPenaltyPoints, 2);
    expect(next.players[1].hand, isEmpty);
  });

  test('pending response-empty penalty is lost only on next round loss', () {
    final controller = LocalKangGameController();
    final state = KangRoundState(
      players: [
        KangPlayerState(
          id: 'you',
          name: 'You',
          hand: [card(KangRank.two, KangSuit.spades)],
          gamePoints: 0,
        ),
        KangPlayerState(
          id: 'benji',
          name: 'Benji',
          hand: [card(KangRank.king, KangSuit.hearts)],
          gamePoints: 1,
          pendingLossPenaltyPoints: 2,
        ),
      ],
      drawPile: const [],
      discardPile: const [],
      currentTurnIndex: 0,
      roundNumber: 2,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.start,
    );

    final next = controller.declareKang(state, 'you');

    expect(next.winnerId, 'you');
    expect(next.players[0].gamePoints, 1);
    expect(next.players[1].gamePoints, -1);
    expect(next.players[1].pendingLossPenaltyPoints, 0);
  });
}
