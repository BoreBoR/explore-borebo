import 'package:benjii/modules/kang_game/model/kang_card.dart';

enum KangRoundStatus { notStarted, playing, finished }

enum KangWinReason { kang, winOut, emptyHand, draw }

enum KangTurnPhase { start, drew, respondingToDrop, discarded }

class KangPlayerState {
  const KangPlayerState({
    required this.id,
    required this.name,
    required this.hand,
    this.placedPairs = const [],
    this.gamePoints = 0,
    this.pendingLossPenaltyPoints = 0,
  });

  final String id;
  final String name;
  final List<KangCard> hand;
  final List<List<KangCard>> placedPairs;
  final int gamePoints;
  final int pendingLossPenaltyPoints;

  int get remainingAces => hand.where((card) => card.isAce).length;

  KangPlayerState copyWith({
    List<KangCard>? hand,
    List<List<KangCard>>? placedPairs,
    int? gamePoints,
    int? pendingLossPenaltyPoints,
  }) {
    return KangPlayerState(
      id: id,
      name: name,
      hand: hand ?? this.hand,
      placedPairs: placedPairs ?? this.placedPairs,
      gamePoints: gamePoints ?? this.gamePoints,
      pendingLossPenaltyPoints:
          pendingLossPenaltyPoints ?? this.pendingLossPenaltyPoints,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'hand': hand.map((card) => card.toJson()).toList(),
      'placedPairs': placedPairs
          .map((pair) => pair.map((card) => card.toJson()).toList())
          .toList(),
      'gamePoints': gamePoints,
      'pendingLossPenaltyPoints': pendingLossPenaltyPoints,
    };
  }

  factory KangPlayerState.fromJson(Map<String, Object?> json) {
    return KangPlayerState(
      id: json['id']! as String,
      name: json['name']! as String,
      hand: (json['hand']! as List<Object?>)
          .cast<Map<Object?, Object?>>()
          .map(
            (card) => KangCard.fromJson(
              card.map((key, value) => MapEntry(key! as String, value)),
            ),
          )
          .toList(),
      placedPairs: ((json['placedPairs'] as List<Object?>?) ?? const [])
          .cast<List<Object?>>()
          .map(
            (pair) => pair
                .cast<Map<Object?, Object?>>()
                .map(
                  (card) => KangCard.fromJson(
                    card.map((key, value) => MapEntry(key! as String, value)),
                  ),
                )
                .toList(),
          )
          .toList(),
      gamePoints: (json['gamePoints'] as num?)?.toInt() ?? 0,
      pendingLossPenaltyPoints:
          (json['pendingLossPenaltyPoints'] as num?)?.toInt() ?? 0,
    );
  }
}

class KangRoundState {
  const KangRoundState({
    required this.players,
    required this.drawPile,
    required this.discardPile,
    required this.currentTurnIndex,
    required this.roundNumber,
    required this.status,
    required this.turnPhase,
    this.winnerId,
    this.winReason,
    this.pendingDroppedCard,
    this.pendingDropperIndex,
    this.lastDrawnCard,
    this.message,
  });

  factory KangRoundState.notStarted() {
    return const KangRoundState(
      players: [],
      drawPile: [],
      discardPile: [],
      currentTurnIndex: 0,
      roundNumber: 0,
      status: KangRoundStatus.notStarted,
      turnPhase: KangTurnPhase.start,
    );
  }

  final List<KangPlayerState> players;
  final List<KangCard> drawPile;
  final List<KangCard> discardPile;
  final int currentTurnIndex;
  final int roundNumber;
  final KangRoundStatus status;
  final KangTurnPhase turnPhase;
  final String? winnerId;
  final KangWinReason? winReason;
  final KangCard? pendingDroppedCard;
  final int? pendingDropperIndex;
  final KangCard? lastDrawnCard;
  final String? message;

  KangPlayerState? get winner {
    final id = winnerId;
    if (id == null) {
      return null;
    }
    for (final player in players) {
      if (player.id == id) {
        return player;
      }
    }
    return null;
  }

  KangPlayerState? get currentPlayer {
    if (players.isEmpty) {
      return null;
    }
    return players[currentTurnIndex];
  }

  KangCard? get discardTop => discardPile.isEmpty ? null : discardPile.last;

  KangRoundState copyWith({
    List<KangPlayerState>? players,
    List<KangCard>? drawPile,
    List<KangCard>? discardPile,
    int? currentTurnIndex,
    int? roundNumber,
    KangRoundStatus? status,
    KangTurnPhase? turnPhase,
    String? winnerId,
    KangWinReason? winReason,
    KangCard? pendingDroppedCard,
    int? pendingDropperIndex,
    KangCard? lastDrawnCard,
    String? message,
    bool clearWinner = false,
    bool clearPendingDrop = false,
    bool clearLastDrawnCard = false,
  }) {
    return KangRoundState(
      players: players ?? this.players,
      drawPile: drawPile ?? this.drawPile,
      discardPile: discardPile ?? this.discardPile,
      currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex,
      roundNumber: roundNumber ?? this.roundNumber,
      status: status ?? this.status,
      turnPhase: turnPhase ?? this.turnPhase,
      winnerId: clearWinner ? null : winnerId ?? this.winnerId,
      winReason: clearWinner ? null : winReason ?? this.winReason,
      pendingDroppedCard: clearPendingDrop
          ? null
          : pendingDroppedCard ?? this.pendingDroppedCard,
      pendingDropperIndex: clearPendingDrop
          ? null
          : pendingDropperIndex ?? this.pendingDropperIndex,
      lastDrawnCard: clearLastDrawnCard
          ? null
          : lastDrawnCard ?? this.lastDrawnCard,
      message: message,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'players': players.map((player) => player.toJson()).toList(),
      'drawPile': drawPile.map((card) => card.toJson()).toList(),
      'discardPile': discardPile.map((card) => card.toJson()).toList(),
      'currentTurnIndex': currentTurnIndex,
      'roundNumber': roundNumber,
      'status': status.name,
      'turnPhase': turnPhase.name,
      'winnerId': winnerId,
      'winReason': winReason?.name,
      'pendingDroppedCard': pendingDroppedCard?.toJson(),
      'pendingDropperIndex': pendingDropperIndex,
      'lastDrawnCard': lastDrawnCard?.toJson(),
      'message': message,
    };
  }

  factory KangRoundState.fromJson(Map<String, Object?> json) {
    KangCard? nullableCard(Object? value) {
      if (value == null) {
        return null;
      }
      final cardJson = (value as Map<Object?, Object?>).map(
        (key, value) => MapEntry(key! as String, value),
      );
      return KangCard.fromJson(cardJson);
    }

    List<KangCard> cardsFromJson(Object? value) {
      return ((value as List<Object?>?) ?? const [])
          .cast<Map<Object?, Object?>>()
          .map(
            (card) => KangCard.fromJson(
              card.map((key, value) => MapEntry(key! as String, value)),
            ),
          )
          .toList();
    }

    return KangRoundState(
      players: ((json['players'] as List<Object?>?) ?? const [])
          .cast<Map<Object?, Object?>>()
          .map(
            (player) => KangPlayerState.fromJson(
              player.map((key, value) => MapEntry(key! as String, value)),
            ),
          )
          .toList(),
      drawPile: cardsFromJson(json['drawPile']),
      discardPile: cardsFromJson(json['discardPile']),
      currentTurnIndex: (json['currentTurnIndex'] as num?)?.toInt() ?? 0,
      roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 0,
      status: KangRoundStatus.values.byName(
        json['status'] as String? ?? KangRoundStatus.notStarted.name,
      ),
      turnPhase: KangTurnPhase.values.byName(
        json['turnPhase'] as String? ?? KangTurnPhase.start.name,
      ),
      winnerId: json['winnerId'] as String?,
      winReason: json['winReason'] == null
          ? null
          : KangWinReason.values.byName(json['winReason']! as String),
      pendingDroppedCard: nullableCard(json['pendingDroppedCard']),
      pendingDropperIndex: (json['pendingDropperIndex'] as num?)?.toInt(),
      lastDrawnCard: nullableCard(json['lastDrawnCard']),
      message: json['message'] as String?,
    );
  }
}
