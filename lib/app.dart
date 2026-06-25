import 'package:benjii/modules/developer/view/developer_floating_button.dart';
import 'package:benjii/util/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Benjii',
      theme: AppTheme.light,
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      builder: (context, child) {
        return Stack(children: [?child, const DeveloperFloatingButton()]);
      },
    );
  }
}
