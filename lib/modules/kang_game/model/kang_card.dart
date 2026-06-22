enum KangSuit {
  spades('S', false),
  hearts('H', true),
  diamonds('D', true),
  clubs('C', false);

  const KangSuit(this.label, this.isRed);

  final String label;
  final bool isRed;
}

enum KangRank {
  ace('A', 1, 1),
  two('2', 2, 2),
  three('3', 3, 3),
  four('4', 4, 4),
  five('5', 5, 5),
  six('6', 6, 6),
  seven('7', 7, 7),
  eight('8', 8, 8),
  nine('9', 9, 9),
  ten('10', 10, 10),
  jack('J', 10, 11),
  queen('Q', 10, 12),
  king('K', 10, 13);

  const KangRank(this.label, this.handValue, this.sequenceValue);

  final String label;
  final int handValue;
  final int sequenceValue;
}

class KangCard {
  const KangCard({required this.rank, required this.suit});

  final KangRank rank;
  final KangSuit suit;

  String get id => '${rank.label}${suit.label}';

  int get handValue => rank.handValue;

  bool get isAce => rank == KangRank.ace;

  Map<String, Object> toJson() => {'rank': rank.name, 'suit': suit.name};

  factory KangCard.fromJson(Map<String, Object?> json) {
    return KangCard(
      rank: KangRank.values.byName(json['rank']! as String),
      suit: KangSuit.values.byName(json['suit']! as String),
    );
  }

  @override
  String toString() => id;

  @override
  bool operator ==(Object other) {
    return other is KangCard && other.rank == rank && other.suit == suit;
  }

  @override
  int get hashCode => Object.hash(rank, suit);
}
