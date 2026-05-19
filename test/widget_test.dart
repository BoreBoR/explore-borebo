import 'package:benjii/app.dart';
import 'package:benjii/app_module.dart';
import 'package:benjii/modules/home/bloc/home_bloc.dart';
import 'package:benjii/modules/home/view/homepage.dart';
import 'package:benjii/modules/landing/view/landing_screen.dart';
import 'package:benjii/modules/timer_together/view/timer_together_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  Future<void> setPhoneSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Finder pinDisplayText(String text) {
    return find.descendant(
      of: find.byKey(const ValueKey('pin-display')),
      matching: find.text(text),
    );
  }

  Future<void> pumpLandingScreen(WidgetTester tester) async {
    await setPhoneSurface(tester);
    await tester.pumpWidget(const MaterialApp(home: LandingScreen()));
  }

  Future<void> pumpModularApp(WidgetTester tester) async {
    await setPhoneSurface(tester);
    Modular.destroy();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ModularApp(module: MainModule(), child: const App()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpHomepage(WidgetTester tester) async {
    await setPhoneSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => HomeBloc()..add(const HomeStarted()),
          child: const Homepage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpTimerTogetherPage(WidgetTester tester) async {
    await setPhoneSurface(tester);
    await tester.pumpWidget(const MaterialApp(home: TimerTogetherPage()));
  }

  Future<void> enterPinWithKeyboard(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.byKey(ValueKey('pin-key-$digit')));
      await tester.pump();
    }
  }

  Future<void> tapStoryNext(WidgetTester tester) async {
    final nextButton = find.byKey(const ValueKey('surprise-next-button'));
    await tester.ensureVisible(nextButton);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
  }

  testWidgets('app starts on landing module', (WidgetTester tester) async {
    await pumpModularApp(tester);

    expect(find.text('For someone special'), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-display')), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-keyboard')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('developer-floating-button')),
      findsOneWidget,
    );
  });

  testWidgets('renders landing pin widget', (WidgetTester tester) async {
    await pumpLandingScreen(tester);

    expect(find.text('For someone special'), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-display')), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-keyboard')), findsOneWidget);
  });

  testWidgets('displays entered pin digits', (WidgetTester tester) async {
    await pumpLandingScreen(tester);

    await enterPinWithKeyboard(tester, '14022');

    for (final digit in {'1', '4', '0', '2'}) {
      expect(pinDisplayText(digit), findsAtLeastNWidgets(1));
    }
  });

  testWidgets('pin can only be entered with numeric keypad', (
    WidgetTester tester,
  ) async {
    await pumpLandingScreen(tester);

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byKey(const ValueKey('pin-key-a')), findsNothing);
    expect(find.byKey(const ValueKey('pin-key-1')), findsOneWidget);
  });

  testWidgets('six digits trigger validation automatically', (
    WidgetTester tester,
  ) async {
    await pumpLandingScreen(tester);

    await enterPinWithKeyboard(tester, '12345');
    await tester.pump();
    expect(
      find.text('Hmm, not that one. Try the day that matters to us.'),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('pin-key-6')));
    await tester.pump();
    expect(
      find.text('Hmm, not that one. Try the day that matters to us.'),
      findsOneWidget,
    );
  });

  testWidgets('valid pin navigates to birthday surprise flow', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    await enterPinWithKeyboard(tester, '140226');
    await tester.pumpAndSettle();

    expect(find.text('Hi love'), findsOneWidget);
    expect(find.text('1 / 10'), findsOneWidget);
  });

  testWidgets('shows wrong number error for known invalid pin', (
    WidgetTester tester,
  ) async {
    await pumpLandingScreen(tester);

    await enterPinWithKeyboard(tester, '123456');
    await tester.pump();

    expect(
      find.text('Hmm, not that one. Try the day that matters to us.'),
      findsOneWidget,
    );
  });

  testWidgets('does not validate before six digits are filled', (
    WidgetTester tester,
  ) async {
    await pumpLandingScreen(tester);

    await enterPinWithKeyboard(tester, '12345');
    await tester.pump();

    expect(find.text('PIN must be 6 digits'), findsNothing);
    expect(
      find.text('Hmm, not that one. Try the day that matters to us.'),
      findsNothing,
    );
  });

  testWidgets('clears wrong pin when user starts next attempt', (
    WidgetTester tester,
  ) async {
    await pumpLandingScreen(tester);

    await enterPinWithKeyboard(tester, '123456');
    await tester.pump();
    expect(
      find.text('Hmm, not that one. Try the day that matters to us.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('pin-key-6')));
    await tester.pump();

    expect(
      find.text('Hmm, not that one. Try the day that matters to us.'),
      findsNothing,
    );
    expect(pinDisplayText('6'), findsAtLeastNWidgets(1));
    expect(pinDisplayText('1'), findsNothing);
    expect(pinDisplayText('2'), findsNothing);
    expect(pinDisplayText('3'), findsNothing);
    expect(pinDisplayText('4'), findsNothing);
    expect(pinDisplayText('5'), findsNothing);
  });

  testWidgets('retry pin can navigate after previous wrong pin', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    await enterPinWithKeyboard(tester, '123456');
    await tester.pump();
    expect(
      find.text('Hmm, not that one. Try the day that matters to us.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('pin-key-1')));
    await enterPinWithKeyboard(tester, '40226');
    await tester.pumpAndSettle();

    expect(find.text('Hi love'), findsOneWidget);
  });

  testWidgets('birthday surprise flow reaches page four', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    expect(find.text('Hi love'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text('Happy Birthday'), findsOneWidget);
    expect(find.text('2 / 10'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text('Things I love about you'), findsOneWidget);
    expect(find.text('3 / 10'), findsOneWidget);
    expect(find.text('Simply being you.'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text('Little memories I keep'), findsOneWidget);
    expect(find.text('4 / 10'), findsOneWidget);
    expect(find.text('The first moment: [Add memory here]'), findsOneWidget);
  });

  testWidgets('birthday surprise flow reaches all ten story pages', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    expect(find.text('Hi love'), findsOneWidget);
    expect(find.text('1 / 10'), findsOneWidget);

    final expectedPages = [
      ('Happy Birthday', '2 / 10'),
      ('Things I love about you', '3 / 10'),
      ('Little memories I keep', '4 / 10'),
      ('Moments with you', '5 / 10'),
      ('A small letter for you', '6 / 10'),
      ('Make a wish', '7 / 10'),
    ];

    for (final expected in expectedPages) {
      await tapStoryNext(tester);
      expect(find.text(expected.$1), findsOneWidget);
      expect(find.text(expected.$2), findsOneWidget);
    }

    await tapStoryNext(tester);
    expect(find.text('One more thing'), findsOneWidget);
    expect(find.text('8 / 10'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text('Happy Birthday, my love'), findsOneWidget);
    expect(find.text('9 / 10'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text('Whenever you want to smile again'), findsOneWidget);
    expect(find.text('10 / 10'), findsOneWidget);
    expect(find.text('Read it again'), findsOneWidget);
  });

  testWidgets('timer together module renders relationship timer', (
    WidgetTester tester,
  ) async {
    await pumpTimerTogetherPage(tester);

    expect(find.text('Since we became us'), findsOneWidget);
    expect(find.text('Days'), findsOneWidget);
    expect(find.text('Hours'), findsOneWidget);
    expect(find.text('Minutes'), findsOneWidget);
    expect(find.text('Seconds'), findsOneWidget);
  });

  testWidgets('story page five renders gallery placeholders', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    for (var i = 0; i < 4; i++) {
      await tapStoryNext(tester);
    }

    expect(find.text('Moments with you'), findsOneWidget);
    expect(find.byKey(const ValueKey('gallery-placeholders')), findsOneWidget);
    expect(find.text('[Add photo or memory 1]'), findsOneWidget);
  });

  testWidgets('wish page reveals message before moving forward', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    for (var i = 0; i < 6; i++) {
      await tapStoryNext(tester);
    }

    expect(find.text('Make a wish'), findsOneWidget);
    expect(find.text('I made one'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text('One more thing'), findsOneWidget);
    expect(find.text('8 / 10'), findsOneWidget);
  });

  testWidgets('final story page restarts part two at story page one', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    for (var i = 0; i < 9; i++) {
      await tapStoryNext(tester);
    }

    expect(find.text('Whenever you want to smile again'), findsOneWidget);
    expect(find.text('10 / 10'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text('Hi love'), findsOneWidget);
    expect(find.text('1 / 10'), findsOneWidget);
  });

  testWidgets('developer button can skip pin and open any story page', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    await tester.tap(find.byKey(const ValueKey('developer-floating-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('developer-navigation-menu')),
      findsOneWidget,
    );
    expect(find.text('Timer together'), findsOneWidget);

    await tester.tap(find.text('Happy Birthday'));
    await tester.pumpAndSettle();

    expect(find.text('Happy Birthday'), findsOneWidget);
    expect(find.text('2 / 10'), findsOneWidget);
  });

  testWidgets('delete key removes the last pin digit', (
    WidgetTester tester,
  ) async {
    await pumpLandingScreen(tester);

    await enterPinWithKeyboard(tester, '123');
    await tester.tap(find.byKey(const ValueKey('pin-key-delete')));
    await tester.pump();

    expect(pinDisplayText('1'), findsAtLeastNWidgets(1));
    expect(pinDisplayText('2'), findsAtLeastNWidgets(1));
    expect(pinDisplayText('3'), findsNothing);
  });

  testWidgets('validate button is not rendered', (WidgetTester tester) async {
    await pumpLandingScreen(tester);

    expect(find.byKey(const ValueKey('pin-validate-button')), findsNothing);
    expect(find.text('Validate'), findsNothing);
  });
}
