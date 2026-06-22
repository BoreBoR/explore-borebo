import 'package:benjii/modules/final_message/view/final_message_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum FinalMessagePageType { finalMessage }

extension FinalMessagePageTypePath on FinalMessagePageType {
  String get path {
    switch (this) {
      case FinalMessagePageType.finalMessage:
        return '${FinalMessageModule.baseRoute}/';
    }
  }
}

class FinalMessageModule extends Module {
  static const baseRoute = '/final-message';

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const FinalMessagePage());
  }
}
