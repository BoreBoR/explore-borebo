import 'package:benjii/app.dart';
import 'package:benjii/app_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  runApp(ModularApp(module: MainModule(), child: const App()));
}
