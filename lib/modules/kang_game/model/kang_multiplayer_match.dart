import 'package:benjii/modules/kang_game/model/kang_round_state.dart';

enum KangMatchStatus { waiting, playing, finished }

class KangMultiplayerMatch {
  const KangMultiplayerMatch({
    required this.id,
    required this.hostUserId,
    required this.hostName,
    required this.round,
    required this.status,
    this.guestUserId,
    this.guestName,
  });

  final String id;
  final String hostUserId;
  final String hostName;
  final String? guestUserId;
  final String? guestName;
  final KangRoundState round;
  final KangMatchStatus status;

  bool get isReady => guestUserId != null;

  List<KangPlayerState> get players {
    return [
      KangPlayerState(id: hostUserId, name: hostName, hand: const []),
      KangPlayerState(
        id: guestUserId ?? 'guest',
        name: guestName ?? 'Waiting...',
        hand: const [],
      ),
    ];
  }

  String? playerName(String userId) {
    if (userId == hostUserId) {
      return hostName;
    }
    if (userId == guestUserId) {
      return guestName;
    }
    return null;
  }

  bool isPlayer(String userId) {
    return userId == hostUserId || userId == guestUserId;
  }

  factory KangMultiplayerMatch.fromFirestore(
    String id,
    Map<String, Object?> json,
  ) {
    return KangMultiplayerMatch(
      id: id,
      hostUserId: json['hostUserId']! as String,
      hostName: json['hostName']! as String,
      guestUserId: json['guestUserId'] as String?,
      guestName: json['guestName'] as String?,
      status: KangMatchStatus.values.byName(
        json['status'] as String? ?? KangMatchStatus.waiting.name,
      ),
      round: KangRoundState.fromJson(
        (json['round']! as Map<Object?, Object?>).map(
          (key, value) => MapEntry(key! as String, value),
        ),
      ),
    );
  }
}
