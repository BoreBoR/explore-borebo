enum KangSuit {
  spades('S', false),
  hearts('H', true),
  diamonds('D', true),
  clubs('C', false);

  const KangSuit(this.label, this.isRed);

  final String label;
  final bool isRed;

  String get assetName {
    switch (this) {
      case KangSuit.spades:
        return 'spades';
      case KangSuit.hearts:
        return 'hearts';
      case KangSuit.diamonds:
        return 'diamonds';
      case KangSuit.clubs:
        return 'clubs';
    }
  }
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

  String get assetName {
    switch (this) {
      case KangRank.ace:
        return 'ace';
      case KangRank.two:
        return '2';
      case KangRank.three:
        return '3';
      case KangRank.four:
        return '4';
      case KangRank.five:
        return '5';
      case KangRank.six:
        return '6';
      case KangRank.seven:
        return '7';
      case KangRank.eight:
        return '8';
      case KangRank.nine:
        return '9';
      case KangRank.ten:
        return '10';
      case KangRank.jack:
        return 'jack';
      case KangRank.queen:
        return 'queen';
      case KangRank.king:
        return 'king';
    }
  }

  bool get usesAlternateAsset {
    switch (this) {
      case KangRank.jack:
      case KangRank.queen:
      case KangRank.king:
        return true;
      case KangRank.ace:
      case KangRank.two:
      case KangRank.three:
      case KangRank.four:
      case KangRank.five:
      case KangRank.six:
      case KangRank.seven:
      case KangRank.eight:
      case KangRank.nine:
      case KangRank.ten:
        return false;
    }
  }
}

class KangCard {
  const KangCard({required this.rank, required this.suit});

  final KangRank rank;
  final KangSuit suit;

  String get id => '${rank.label}${suit.label}';

  String get assetPath =>
      'assets/images/SVG-cards-1.3/${rank.assetName}_of_${suit.assetName}${rank.usesAlternateAsset ? '2' : ''}.svg';

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
