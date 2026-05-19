import 'package:benjii/modular/home.dart';
import 'package:benjii/modular/landing.dart';
import 'package:benjii/modular/timer_together.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MainModule extends Module {
  @override
  void routes(RouteManager r) {
    r.module(HomeModule.baseRoute, module: HomeModule());
    r.module(TimerTogetherModule.baseRoute, module: TimerTogetherModule());
    r.module(LandingModule.baseRoute, module: LandingModule());
  }
}
