import 'package:benjii/modules/landing/view/landing_screen.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum LandingPageType { landingScreen }

extension LandingPageTypePath on LandingPageType {
  String get path {
    switch (this) {
      case LandingPageType.landingScreen:
        return '${LandingModule.baseRoute}/';
    }
  }
}

class LandingModule extends Module {
  static const baseRoute = '/benji-message';

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const LandingScreen());
  }
}
