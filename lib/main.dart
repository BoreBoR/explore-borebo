import 'dart:async';

import 'package:benjii/app.dart';
import 'package:benjii/app_module.dart';
import 'package:benjii/firebase_options.dart';
import 'package:benjii/modules/auth/service/user_profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      unawaited(
        UserProfileService.instance.ensureUserProfile(user).catchError((_) {}),
      );
    }
  });

  runApp(ModularApp(module: MainModule(), child: const App()));
}
