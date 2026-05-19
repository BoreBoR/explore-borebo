import 'package:benjii/modular/home.dart';
import 'package:benjii/modular/landing.dart';
import 'package:benjii/modular/mode_select.dart';
import 'package:benjii/modular/number_random.dart';
import 'package:benjii/modular/timer_together.dart';
import 'package:benjii/modules/landing/controller/pin_route_guard.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MainModule extends Module {
  @override
  void routes(RouteManager r) {
    r.module(
      HomeModule.baseRoute,
      module: HomeModule(),
      guards: [PinRouteGuard()],
    );
    r.module(
      TimerTogetherModule.baseRoute,
      module: TimerTogetherModule(),
      guards: [PinRouteGuard()],
    );
    r.module(NumberRandomModule.baseRoute, module: NumberRandomModule());
    r.module(LandingModule.baseRoute, module: LandingModule());
    r.module(ModeSelectModule.baseRoute, module: ModeSelectModule());
  }
}
