import 'package:benjii/modules/mode_select/view/mode_select_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum ModeSelectPageType { modeSelect }

extension ModeSelectPageTypePath on ModeSelectPageType {
  String get path {
    switch (this) {
      case ModeSelectPageType.modeSelect:
        return '${ModeSelectModule.baseRoute}/';
    }
  }
}

class ModeSelectModule extends Module {
  static const baseRoute = '/';

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const ModeSelectPage());
  }
}
