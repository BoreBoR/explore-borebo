import 'dart:math';

import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';

abstract final class KangRules {
  static List<KangCard> standardDeck() {
    return [
      for (final suit in KangSuit.values)
        for (final rank in KangRank.values) KangCard(rank: rank, suit: suit),
    ];
  }

  static List<KangCard> shuffledDeck([Random? random]) {
    final deck = standardDeck();
    deck.shuffle(random);
    return deck;
  }

  static int handValue(List<KangCard> cards) {
    return cards.fold(0, (total, card) => total + card.handValue);
  }

  static int aceCount(List<KangCard> cards) {
    return cards.where((card) => card.isAce).length;
  }

  static bool hasThreeOfAKind(List<KangCard> hand) {
    return _rankCounts(hand).values.any((count) => count >= 3);
  }

  static bool isFlush(List<KangCard> hand) {
    return hand.length == 5 &&
        hand.every((card) => card.suit == hand.first.suit);
  }

  static bool isStraight(List<KangCard> hand) {
    if (hand.length != 5) {
      return false;
    }

    final values = hand.map((card) => card.rank.sequenceValue).toSet();
    if (values.length != 5) {
      return false;
    }

    final sorted = values.toList()..sort();
    final isNormal = sorted.last - sorted.first == 4;
    final isAceHigh = values.containsAll({1, 10, 11, 12, 13});
    return isNormal || isAceHigh;
  }

  static bool hasWinOut(List<KangCard> hand) {
    return hasThreeOfAKind(hand) || isFlush(hand) || isStraight(hand);
  }

  static List<KangRank> availablePairRanks(List<KangCard> hand) {
    return _rankCounts(hand).entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .toList();
  }

  static KangPlayerState placePair(KangPlayerState player, KangRank rank) {
    final matching = player.hand.where((card) => card.rank == rank).take(2);
    if (matching.length < 2) {
      throw StateError('Player does not have a pair of ${rank.label}.');
    }

    final pair = matching.toList();
    final remaining = [...player.hand];
    for (final card in pair) {
      remaining.remove(card);
    }

    return player.copyWith(
      hand: remaining,
      placedPairs: [...player.placedPairs, pair],
    );
  }

  static String kangWinnerId({
    required List<KangPlayerState> players,
    required String declarerId,
  }) {
    final values = {
      for (final player in players) player.id: handValue(player.hand),
    };
    final lowest = values.values.reduce(min);
    final tiedLowest = values.entries
        .where((entry) => entry.value == lowest)
        .map((entry) => entry.key)
        .toSet();

    if (tiedLowest.contains(declarerId)) {
      return declarerId;
    }

    return tiedLowest.first;
  }

  static int pointsForWinningHand(List<KangCard> hand) {
    return 1 + aceCount(hand);
  }

  static List<KangCard> sortedCards(List<KangCard> cards) {
    return [...cards]..sort(compareCards);
  }

  static int compareCards(KangCard a, KangCard b) {
    final rankCompare = a.rank.sequenceValue.compareTo(b.rank.sequenceValue);
    if (rankCompare != 0) {
      return rankCompare;
    }
    return a.suit.index.compareTo(b.suit.index);
  }

  static Map<KangRank, int> _rankCounts(List<KangCard> cards) {
    final counts = <KangRank, int>{};
    for (final card in cards) {
      counts[card.rank] = (counts[card.rank] ?? 0) + 1;
    }
    return counts;
  }
}
