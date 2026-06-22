import 'package:benjii/modular/final_message.dart';
import 'package:benjii/modular/home.dart';
import 'package:benjii/modular/kang_game.dart';
import 'package:benjii/modular/landing.dart';
import 'package:benjii/modular/mode_select.dart';
import 'package:benjii/modular/number_random.dart';
import 'package:benjii/modular/timer_together.dart';
import 'package:benjii/modules/landing/controller/pin_route_guard.dart';
import 'package:benjii/util/app_route_transitions.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MainModule extends Module {
  @override
  void routes(RouteManager r) {
    r.module(
      HomeModule.baseRoute,
      module: HomeModule(),
      guards: [PinRouteGuard()],
      transition: TransitionType.custom,
      customTransition: AppRouteTransitions.softSlide,
    );
    r.module(
      TimerTogetherModule.baseRoute,
      module: TimerTogetherModule(),
      guards: [PinRouteGuard()],
      transition: TransitionType.custom,
      customTransition: AppRouteTransitions.softSlide,
    );
    r.module(
      FinalMessageModule.baseRoute,
      module: FinalMessageModule(),
      guards: [PinRouteGuard()],
      transition: TransitionType.custom,
      customTransition: AppRouteTransitions.softSlide,
    );
    r.module(
      NumberRandomModule.baseRoute,
      module: NumberRandomModule(),
      transition: TransitionType.custom,
      customTransition: AppRouteTransitions.softSlide,
    );
    r.module(
      KangGameModule.baseRoute,
      module: KangGameModule(),
      transition: TransitionType.custom,
      customTransition: AppRouteTransitions.softSlide,
    );
    r.module(
      LandingModule.baseRoute,
      module: LandingModule(),
      transition: TransitionType.custom,
      customTransition: AppRouteTransitions.softSlide,
    );
    r.module(
      ModeSelectModule.baseRoute,
      module: ModeSelectModule(),
      transition: TransitionType.custom,
      customTransition: AppRouteTransitions.softSlide,
    );
  }
}
