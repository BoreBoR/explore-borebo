import 'package:benjii/modules/kang_game/view/kang_game_page.dart';
import 'package:benjii/modules/kang_game/view/kang_multiplayer_game_page.dart';
import 'package:benjii/modules/kang_game/view/kang_multiplayer_lobby_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum KangGamePageType { kangGame, multiplayerLobby }

extension KangGamePageTypePath on KangGamePageType {
  String get path {
    switch (this) {
      case KangGamePageType.kangGame:
        return '${KangGameModule.baseRoute}/';
      case KangGamePageType.multiplayerLobby:
        return '${KangGameModule.baseRoute}/multiplayer';
    }
  }
}

class KangGameModule extends Module {
  static const baseRoute = '/kang-game';

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const KangGamePage());
    r.child('/multiplayer', child: (_) => KangMultiplayerLobbyPage());
    r.child(
      '/multiplayer/:matchId',
      child: (_) => KangMultiplayerGamePage(
        matchId: Modular.args.params['matchId']! as String,
      ),
    );
  }
}
