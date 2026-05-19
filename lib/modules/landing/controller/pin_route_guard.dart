import 'package:benjii/modules/landing/controller/pin_gate_controller.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PinRouteGuard extends RouteGuard {
  PinRouteGuard() : super(redirectTo: '/benji-message/');

  @override
  bool canActivate(String path, ParallelRoute route) {
    return PinGateController.isUnlocked;
  }
}
