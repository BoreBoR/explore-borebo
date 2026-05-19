import 'package:benjii/modules/home/bloc/home_bloc.dart';
import 'package:benjii/modules/home/view/homepage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum HomePageType { homepage }

extension HomePageTypePath on HomePageType {
  String get path {
    switch (this) {
      case HomePageType.homepage:
        return '${HomeModule.baseRoute}/';
    }
  }
}

class HomeModule extends Module {
  static const baseRoute = '/home';

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => BlocProvider(
        create: (_) => HomeBloc()..add(const HomeStarted()),
        child: const Homepage(),
      ),
    );
  }
}
