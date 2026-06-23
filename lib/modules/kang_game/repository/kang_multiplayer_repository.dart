import 'package:benjii/modules/kang_game/controller/local_kang_game_controller.dart';
import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_multiplayer_match.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef KangRoundAction =
    KangRoundState Function(
      LocalKangGameController controller,
      KangRoundState round,
    );

class KangMultiplayerRepository {
  KangMultiplayerRepository({
    FirebaseFirestore? firestore,
    LocalKangGameController? controller,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _controller = controller ?? LocalKangGameController();

  final FirebaseFirestore _firestore;
  final LocalKangGameController _controller;

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('kang_matches');

  Stream<List<KangMultiplayerMatch>> watchOpenMatches() {
    return _matches
        .where('status', isEqualTo: KangMatchStatus.waiting.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        KangMultiplayerMatch.fromFirestore(doc.id, doc.data()),
                  )
                  .toList()
                ..sort((a, b) => a.hostName.compareTo(b.hostName)),
        );
  }

  Stream<KangMultiplayerMatch?> watchMatch(String matchId) {
    return _matches.doc(matchId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return KangMultiplayerMatch.fromFirestore(snapshot.id, data);
    });
  }

  Future<String> createMatch({
    required String hostUserId,
    required String hostName,
  }) async {
    final initialRound = KangRoundState(
      players: [
        KangPlayerState(id: hostUserId, name: hostName, hand: const []),
        const KangPlayerState(id: 'guest', name: 'Waiting...', hand: []),
      ],
      drawPile: const [],
      discardPile: const [],
      currentTurnIndex: 0,
      roundNumber: 0,
      status: KangRoundStatus.notStarted,
      turnPhase: KangTurnPhase.start,
      message: 'Waiting for another player.',
    );

    final doc = await _matches.add({
      'hostUserId': hostUserId,
      'hostName': hostName,
      'guestUserId': null,
      'guestName': null,
      'status': KangMatchStatus.waiting.name,
      'round': initialRound.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> joinMatch({
    required String matchId,
    required String guestUserId,
    required String guestName,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _matches.doc(matchId);
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null) {
        throw StateError('Match no longer exists.');
      }

      final match = KangMultiplayerMatch.fromFirestore(snapshot.id, data);
      if (match.hostUserId == guestUserId) {
        return;
      }
      if (match.guestUserId != null && match.guestUserId != guestUserId) {
        throw StateError('Match is already full.');
      }

      final updatedRound = match.round.copyWith(
        players: [
          KangPlayerState(
            id: match.hostUserId,
            name: match.hostName,
            hand: const [],
          ),
          KangPlayerState(id: guestUserId, name: guestName, hand: const []),
        ],
        message: 'Both players joined. Start the first round.',
      );

      transaction.update(ref, {
        'guestUserId': guestUserId,
        'guestName': guestName,
        'round': updatedRound.toJson(),
        'status': KangMatchStatus.playing.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> startRound({
    required String matchId,
    required String userId,
  }) async {
    await updateRound(
      matchId: matchId,
      userId: userId,
      action: (controller, round) => controller.startRound(round),
      allowFinishedRound: true,
    );
  }

  Future<void> declareKang({required String matchId, required String userId}) {
    return updateRound(
      matchId: matchId,
      userId: userId,
      action: (controller, round) => controller.declareKang(round, userId),
    );
  }

  Future<void> draw({required String matchId, required String userId}) {
    return updateRound(
      matchId: matchId,
      userId: userId,
      action: (controller, round) => controller.drawForCurrentPlayer(round),
    );
  }

  Future<void> dropCards({
    required String matchId,
    required String userId,
    required List<KangCard> cards,
  }) {
    return updateRound(
      matchId: matchId,
      userId: userId,
      action: (controller, round) =>
          round.turnPhase == KangTurnPhase.respondingToDrop
          ? controller.respondToDroppedCards(round, cards)
          : controller.dropCards(round, cards),
    );
  }

  Future<void> updateRound({
    required String matchId,
    required String userId,
    required KangRoundAction action,
    bool allowFinishedRound = false,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final ref = _matches.doc(matchId);
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null) {
        throw StateError('Match no longer exists.');
      }

      final match = KangMultiplayerMatch.fromFirestore(snapshot.id, data);
      if (!match.isPlayer(userId)) {
        throw StateError('You are not a player in this match.');
      }
      if (!match.isReady) {
        throw StateError('Wait for another player to join.');
      }
      if (match.round.status == KangRoundStatus.playing &&
          match.round.currentPlayer?.id != userId) {
        throw StateError('Wait for your turn.');
      }
      if (match.round.status == KangRoundStatus.finished &&
          !allowFinishedRound) {
        throw StateError('Round is already finished.');
      }

      final nextRound = action(_controller, match.round);
      transaction.update(ref, {
        'round': nextRound.toJson(),
        'status': nextRound.status == KangRoundStatus.finished
            ? KangMatchStatus.finished.name
            : KangMatchStatus.playing.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
