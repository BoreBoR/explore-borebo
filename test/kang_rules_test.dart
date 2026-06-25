import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:benjii/modules/kang_game/model/kang_rules.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  KangCard card(KangRank rank, KangSuit suit) {
    return KangCard(rank: rank, suit: suit);
  }

  test('standard deck has 52 unique cards', () {
    final deck = KangRules.standardDeck();

    expect(deck, hasLength(52));
    expect(deck.map((card) => card.id).toSet(), hasLength(52));
  });

  test('hand value uses Ace as 1 and face cards as 10', () {
    final hand = [
      card(KangRank.ace, KangSuit.spades),
      card(KangRank.jack, KangSuit.hearts),
      card(KangRank.queen, KangSuit.clubs),
      card(KangRank.five, KangSuit.diamonds),
    ];

    expect(KangRules.handValue(hand), 26);
  });

  test('detects win out patterns', () {
    expect(
      KangRules.hasThreeOfAKind([
        card(KangRank.ace, KangSuit.spades),
        card(KangRank.ace, KangSuit.hearts),
        card(KangRank.ace, KangSuit.diamonds),
        card(KangRank.five, KangSuit.clubs),
        card(KangRank.nine, KangSuit.clubs),
      ]),
      isTrue,
    );
    expect(
      KangRules.isFlush([
        card(KangRank.ace, KangSuit.spades),
        card(KangRank.three, KangSuit.spades),
        card(KangRank.five, KangSuit.spades),
        card(KangRank.seven, KangSuit.spades),
        card(KangRank.nine, KangSuit.spades),
      ]),
      isTrue,
    );
    expect(
      KangRules.isStraight([
        card(KangRank.ten, KangSuit.spades),
        card(KangRank.jack, KangSuit.hearts),
        card(KangRank.queen, KangSuit.diamonds),
        card(KangRank.king, KangSuit.clubs),
        card(KangRank.ace, KangSuit.clubs),
      ]),
      isTrue,
    );
  });

  test('place pair removes pair from hand value', () {
    final player = KangPlayerState(
      id: 'you',
      name: 'You',
      hand: [
        card(KangRank.ace, KangSuit.spades),
        card(KangRank.ace, KangSuit.hearts),
        card(KangRank.three, KangSuit.clubs),
        card(KangRank.five, KangSuit.diamonds),
        card(KangRank.eight, KangSuit.spades),
      ],
    );

    final updated = KangRules.placePair(player, KangRank.ace);

    expect(updated.hand, hasLength(3));
    expect(updated.placedPairs.single, hasLength(2));
    expect(KangRules.handValue(updated.hand), 16);
  });

  test('kang declarer wins tied lowest hand value', () {
    final players = [
      KangPlayerState(
        id: 'you',
        name: 'You',
        hand: [
          card(KangRank.ace, KangSuit.spades),
          card(KangRank.four, KangSuit.hearts),
        ],
      ),
      KangPlayerState(
        id: 'benji',
        name: 'Benji',
        hand: [
          card(KangRank.two, KangSuit.spades),
          card(KangRank.three, KangSuit.hearts),
        ],
      ),
    ];

    expect(KangRules.kangWinnerId(players: players, declarerId: 'you'), 'you');
  });

  test('winning hand gains base point plus ace bonus', () {
    final hand = [
      card(KangRank.ace, KangSuit.spades),
      card(KangRank.ace, KangSuit.hearts),
      card(KangRank.three, KangSuit.clubs),
    ];

    expect(KangRules.pointsForWinningHand(hand), 3);
  });

  test('round state serializes for multiplayer storage', () {
    final pendingCard = card(KangRank.five, KangSuit.spades);
    final round = KangRoundState(
      players: [
        KangPlayerState(
          id: 'host',
          name: 'Host',
          hand: [pendingCard, card(KangRank.king, KangSuit.clubs)],
          gamePoints: 2,
        ),
        KangPlayerState(
          id: 'guest',
          name: 'Guest',
          hand: [card(KangRank.five, KangSuit.hearts)],
          pendingLossPenaltyPoints: 2,
        ),
      ],
      drawPile: [card(KangRank.two, KangSuit.diamonds)],
      discardPile: [pendingCard],
      currentTurnIndex: 1,
      roundNumber: 3,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.respondingToDrop,
      pendingDroppedCard: pendingCard,
      pendingDropperIndex: 0,
      tableDroppedCards: {
        'host': [pendingCard],
        'guest': [card(KangRank.five, KangSuit.hearts)],
      },
      droppedCardsByPlayer: {
        'host': [pendingCard],
        'guest': [card(KangRank.five, KangSuit.hearts)],
      },
      lastDrawnCard: card(KangRank.king, KangSuit.clubs),
      message: 'Guest must respond.',
    );

    final restored = KangRoundState.fromJson(round.toJson());

    expect(restored.players[0].id, 'host');
    expect(restored.players[0].gamePoints, 2);
    expect(restored.players[1].pendingLossPenaltyPoints, 2);
    expect(restored.drawPile.single, card(KangRank.two, KangSuit.diamonds));
    expect(restored.discardPile.single, pendingCard);
    expect(restored.currentPlayer?.id, 'guest');
    expect(restored.turnPhase, KangTurnPhase.respondingToDrop);
    expect(restored.pendingDroppedCard, pendingCard);
    expect(restored.pendingDropperIndex, 0);
    expect(restored.tableDroppedCards['host'], [pendingCard]);
    expect(restored.tableDroppedCards['guest'], [
      card(KangRank.five, KangSuit.hearts),
    ]);
    expect(restored.droppedCardsByPlayer['host'], [pendingCard]);
    expect(restored.droppedCardsByPlayer['guest'], [
      card(KangRank.five, KangSuit.hearts),
    ]);
    expect(restored.lastDrawnCard, card(KangRank.king, KangSuit.clubs));
    expect(restored.message, 'Guest must respond.');
  });

  test('every Kang card maps to a bundled SVG asset', () async {
    for (final card in KangRules.standardDeck()) {
      await expectLater(rootBundle.load(card.assetPath), completes);
    }
  });
}
