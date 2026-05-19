import 'package:benjii/modules/number_random/view/number_random_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum NumberRandomPageType { numberRandom }

extension NumberRandomPageTypePath on NumberRandomPageType {
  String get path {
    switch (this) {
      case NumberRandomPageType.numberRandom:
        return '${NumberRandomModule.baseRoute}/';
    }
  }
}

class NumberRandomModule extends Module {
  static const baseRoute = '/number-random';

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const NumberRandomPage());
  }
}
