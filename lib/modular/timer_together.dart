import 'package:benjii/modules/timer_together/view/timer_together_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum TimerTogetherPageType { timerTogether }

extension TimerTogetherPageTypePath on TimerTogetherPageType {
  String get path {
    switch (this) {
      case TimerTogetherPageType.timerTogether:
        return '${TimerTogetherModule.baseRoute}/';
    }
  }
}

class TimerTogetherModule extends Module {
  static const baseRoute = '/timer-together';

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const TimerTogetherPage());
  }
}
