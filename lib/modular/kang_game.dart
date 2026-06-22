import 'package:benjii/modules/kang_game/view/kang_game_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum KangGamePageType { kangGame }

extension KangGamePageTypePath on KangGamePageType {
  String get path {
    switch (this) {
      case KangGamePageType.kangGame:
        return '${KangGameModule.baseRoute}/';
    }
  }
}

class KangGameModule extends Module {
  static const baseRoute = '/kang-game';

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const KangGamePage());
  }
}
