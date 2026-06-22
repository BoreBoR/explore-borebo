import 'package:benjii/modules/kang_game/controller/local_kang_game_controller.dart';
import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  KangCard card(KangRank rank, KangSuit suit) {
    return KangCard(rank: rank, suit: suit);
  }

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
          hand: [matchingCard, secondMatchingCard],
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
    );

    final next = controller.respondToDroppedCards(state, [
      matchingCard,
      secondMatchingCard,
    ]);

    expect(next.currentPlayer?.id, 'you');
    expect(next.turnPhase, KangTurnPhase.start);
    expect(next.pendingDroppedCard, isNull);
    expect(next.discardPile, [droppedCard, matchingCard, secondMatchingCard]);
    expect(next.players[1].hand, isEmpty);
  });

  test('dropping without opponent match passes turn', () {
    final controller = LocalKangGameController();
    final droppedCard = card(KangRank.ace, KangSuit.spades);
    final state = KangRoundState(
      players: [
        KangPlayerState(id: 'you', name: 'You', hand: [droppedCard]),
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
}
