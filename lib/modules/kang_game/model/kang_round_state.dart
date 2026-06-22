import 'package:benjii/modules/kang_game/model/kang_card.dart';

enum KangRoundStatus { notStarted, playing, finished }

enum KangWinReason { kang, winOut, draw }

enum KangTurnPhase { start, drew, respondingToDrop, discarded }

class KangPlayerState {
  const KangPlayerState({
    required this.id,
    required this.name,
    required this.hand,
    this.placedPairs = const [],
    this.gamePoints = 0,
  });

  final String id;
  final String name;
  final List<KangCard> hand;
  final List<List<KangCard>> placedPairs;
  final int gamePoints;

  int get remainingAces => hand.where((card) => card.isAce).length;

  KangPlayerState copyWith({
    List<KangCard>? hand,
    List<List<KangCard>>? placedPairs,
    int? gamePoints,
  }) {
    return KangPlayerState(
      id: id,
      name: name,
      hand: hand ?? this.hand,
      placedPairs: placedPairs ?? this.placedPairs,
      gamePoints: gamePoints ?? this.gamePoints,
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
}
