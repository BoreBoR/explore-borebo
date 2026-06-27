import 'package:benjii/app.dart';
import 'package:benjii/app_module.dart';
import 'package:benjii/modules/final_message/view/final_message_page.dart';
import 'package:benjii/modules/home/bloc/home_bloc.dart';
import 'package:benjii/modules/home/view/homepage.dart';
import 'package:benjii/modules/home/view/widget/story_pages.dart';
import 'package:benjii/modules/landing/controller/pin_gate_controller.dart';
import 'package:benjii/modules/landing/view/landing_screen.dart';
import 'package:benjii/modules/mode_select/view/mode_select_page.dart';
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
    PinGateController.lock();
    Modular.destroy();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MaterialApp(home: LandingScreen()));
  }

  Future<void> pumpModularApp(WidgetTester tester) async {
    await setPhoneSurface(tester);
    PinGateController.lock();
    Modular.destroy();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      ModularApp(module: MainModule(), child: const App()),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpHomepage(
    WidgetTester tester, {
    VoidCallback? onStoryComplete,
  }) async {
    await setPhoneSurface(tester);
    Modular.destroy();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => HomeBloc()..add(const HomeStarted()),
          child: Homepage(onStoryComplete: onStoryComplete),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpTimerTogetherPage(WidgetTester tester) async {
    await setPhoneSurface(tester);
    Modular.destroy();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MaterialApp(home: TimerTogetherPage()));
  }

  Future<void> pumpFinalMessagePage(WidgetTester tester) async {
    await setPhoneSurface(tester);
    Modular.destroy();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const MaterialApp(home: FinalMessagePage()));
  }

  Future<void> enterPinWithKeyboard(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      final key = find.byKey(ValueKey('pin-key-$digit'));
      await tester.ensureVisible(key);
      await tester.tap(key);
      await tester.pump();
    }
  }

  Future<void> tapStoryNext(WidgetTester tester) async {
    final nextButton = find.byKey(const ValueKey('surprise-next-button'));
    await tester.ensureVisible(nextButton);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
  }

  testWidgets('app starts on mode select module', (WidgetTester tester) async {
    await pumpModularApp(tester);

    expect(find.text('Choose mode'), findsOneWidget);
    expect(find.text('Number Random'), findsOneWidget);
    expect(find.text('Kang Game'), findsOneWidget);
    expect(find.text('Kang Online'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('benji-message-mode-button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('developer-floating-button')),
      findsOneWidget,
    );
  });

  testWidgets('home route redirects to pin before unlock', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    Modular.to.navigate('/home/');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('For someone special'), findsOneWidget);
    expect(find.text(StoryPages.all[0].title), findsNothing);
  });

  testWidgets('benji message mode is only shown with access', (
    WidgetTester tester,
  ) async {
    await setPhoneSurface(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: ModeSelectPage(canViewBenjiiMessageOverride: false),
      ),
    );

    expect(
      find.byKey(const ValueKey('benji-message-mode-button')),
      findsNothing,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ModeSelectPage(canViewBenjiiMessageOverride: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('benji-message-mode-button')),
      findsOneWidget,
    );
  });

  testWidgets('number random mode opens generator', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    await tester.tap(find.byKey(const ValueKey('number-random-mode-button')));
    await tester.pumpAndSettle();

    expect(find.text('Number Random'), findsOneWidget);
    expect(find.byKey(const ValueKey('random-result-boxes')), findsOneWidget);
    for (var index = 0; index < 6; index++) {
      expect(
        find.byKey(ValueKey('random-result-digit-$index')),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(const ValueKey('generate-number-button')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('random-history')), findsOneWidget);
    expect(find.text('No guesses yet'), findsOneWidget);
  });

  testWidgets('number random keeps latest ten guesses', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    await tester.tap(find.byKey(const ValueKey('number-random-mode-button')));
    await tester.pumpAndSettle();

    for (var i = 0; i < 11; i++) {
      await tester.tap(find.byKey(const ValueKey('generate-number-button')));
      await tester.pump();
    }

    expect(find.text('No guesses yet'), findsNothing);
    for (var index = 1; index <= 10; index++) {
      expect(
        find.byKey(ValueKey('random-history-item-$index')),
        findsOneWidget,
      );
    }
    expect(find.byKey(const ValueKey('random-history-item-11')), findsNothing);
  });

  testWidgets('kang game mode opens local prototype and starts round', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('kang-game-mode-button')),
    );
    await tester.tap(find.byKey(const ValueKey('kang-game-mode-button')));
    await tester.pumpAndSettle();

    expect(find.text('Kang Game'), findsOneWidget);
    expect(find.byKey(const ValueKey('kang-round-summary')), findsOneWidget);
    expect(find.text('No round started'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('kang-start-round-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('kang-player-you')), findsOneWidget);
    expect(find.byKey(const ValueKey('kang-player-benji')), findsOneWidget);
    expect(find.textContaining('Round 1'), findsWidgets);
    final dropButton = find.byKey(const ValueKey('kang-drop-card-button'));
    if (dropButton.evaluate().isEmpty) {
      expect(
        find.byKey(const ValueKey('kang-round-result-dialog')),
        findsOneWidget,
      );
      return;
    }

    expect(tester.widget<FilledButton>(dropButton).onPressed, isNull);

    final drawButton = find.byKey(const ValueKey('kang-draw-card-button'));
    await tester.ensureVisible(drawButton);
    await tester.tap(drawButton);
    await tester.pumpAndSettle();
    final firstCard = find
        .descendant(
          of: find.byKey(const ValueKey('kang-player-you')).first,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget.key is ValueKey<String> &&
                (widget.key! as ValueKey<String>).value.startsWith(
                  'kang-card-',
                ),
          ),
        )
        .first;
    await tester.ensureVisible(firstCard);
    await tester.tap(firstCard);
    await tester.pump();

    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('kang-drop-card-button')),
          )
          .onPressed,
      isNotNull,
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
    await tester.pump(const Duration(milliseconds: 250));
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

  testWidgets('birthday surprise flow reaches page four', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    expect(find.text(StoryPages.all[0].title), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text(StoryPages.all[1].title), findsOneWidget);
    expect(find.text('2 / 10'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text(StoryPages.all[2].title), findsOneWidget);
    expect(find.text('3 / 10'), findsOneWidget);
    expect(find.textContaining('ที่รักเอาใจใส่ม๊ากกก'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text(StoryPages.all[3].title), findsOneWidget);
    expect(find.text('4 / 10'), findsOneWidget);
    expect(find.textContaining('เค้ากลัวเธอด้วยช่วงแรกๆ'), findsOneWidget);
  });

  testWidgets('birthday surprise flow reaches all ten story pages', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    expect(find.text(StoryPages.all[0].title), findsOneWidget);
    expect(find.text('1 / 10'), findsOneWidget);

    final expectedPages = [
      (StoryPages.all[1].title, '2 / 10'),
      (StoryPages.all[2].title, '3 / 10'),
      (StoryPages.all[3].title, '4 / 10'),
      (StoryPages.all[4].title, '5 / 10'),
      (StoryPages.all[5].title, '6 / 10'),
      (StoryPages.all[6].title, '7 / 10'),
    ];

    for (final expected in expectedPages) {
      await tapStoryNext(tester);
      expect(find.text(expected.$1), findsOneWidget);
      expect(find.text(expected.$2), findsOneWidget);
    }

    await tapStoryNext(tester);
    expect(find.text(StoryPages.all[7].title), findsOneWidget);
    expect(find.text('8 / 10'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text(StoryPages.all[8].title), findsOneWidget);
    expect(find.text('9 / 10'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text(StoryPages.all[9].title), findsOneWidget);
    expect(find.text('10 / 10'), findsOneWidget);
    expect(find.text(StoryPages.all[9].buttonLabel), findsOneWidget);
  });

  testWidgets('timer together module renders relationship timer', (
    WidgetTester tester,
  ) async {
    await pumpTimerTogetherPage(tester);

    expect(find.text('ตั้งแต่เราเป็นเรา'), findsOneWidget);
    expect(find.text('วัน'), findsOneWidget);
    expect(find.text('ชั่วโมง'), findsOneWidget);
    expect(find.text('นาที'), findsOneWidget);
    expect(find.text('วินาที'), findsOneWidget);
  });

  testWidgets('timer together reveals final message button after delay', (
    WidgetTester tester,
  ) async {
    await pumpTimerTogetherPage(tester);

    expect(
      find.byKey(const ValueKey('timer-final-message-button')),
      findsNothing,
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 700));

    expect(
      find.byKey(const ValueKey('timer-final-message-button')),
      findsOneWidget,
    );
  });

  testWidgets('final message page cycles messages and reveals quit button', (
    WidgetTester tester,
  ) async {
    await pumpFinalMessagePage(tester);

    expect(find.text(FinalMessagePage.messages[0]), findsOneWidget);
    expect(find.byKey(const ValueKey('quit-program-button')), findsNothing);

    await tester.pump(const Duration(milliseconds: 2220));
    expect(find.text(FinalMessagePage.messages[1]), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2220));
    expect(find.text(FinalMessagePage.messages[2]), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2220));
    expect(find.text(FinalMessagePage.messages[3]), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    expect(find.text(FinalMessagePage.messages[3]), findsOneWidget);
    expect(find.byKey(const ValueKey('quit-program-button')), findsOneWidget);
  });

  testWidgets('story page five renders photo gallery', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    for (var i = 0; i < 4; i++) {
      await tapStoryNext(tester);
    }

    expect(find.text(StoryPages.all[4].title), findsOneWidget);
    final gallery = find.byKey(const ValueKey('photo-gallery'));
    expect(gallery, findsOneWidget);
    expect(
      find.descendant(of: gallery, matching: find.byType(Image)),
      findsNWidgets(StoryPages.all[4].imageAssets.length),
    );
    expect(find.text(StoryPages.all[4].items.first), findsOneWidget);
  });

  testWidgets('gallery photo opens a zoomable full-screen viewer', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    for (var i = 0; i < 4; i++) {
      await tapStoryNext(tester);
    }

    await tester.tap(find.byKey(const ValueKey('gallery-image-0')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('full-screen-image-viewer')),
      findsOneWidget,
    );
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('close-image-viewer')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('full-screen-image-viewer')),
      findsNothing,
    );
  });

  testWidgets('wish page reveals message before moving forward', (
    WidgetTester tester,
  ) async {
    await pumpHomepage(tester);

    for (var i = 0; i < 6; i++) {
      await tapStoryNext(tester);
    }

    expect(find.text(StoryPages.all[6].title), findsOneWidget);
    expect(find.text('ต่อเลย'), findsOneWidget);

    await tapStoryNext(tester);
    expect(find.text(StoryPages.all[7].title), findsOneWidget);
    expect(find.text('8 / 10'), findsOneWidget);
  });

  testWidgets('final story page opens time together page', (
    WidgetTester tester,
  ) async {
    var didOpenTimeTogether = false;
    await pumpHomepage(
      tester,
      onStoryComplete: () => didOpenTimeTogether = true,
    );

    for (var i = 0; i < 9; i++) {
      await tapStoryNext(tester);
    }

    expect(find.text(StoryPages.all[9].title), findsOneWidget);
    expect(find.text('10 / 10'), findsOneWidget);

    await tapStoryNext(tester);
    expect(didOpenTimeTogether, isTrue);
  });

  testWidgets('timer together opens final page and quits to mode select', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    PinGateController.unlock();
    Modular.to.navigate('/timer-together/');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.ensureVisible(
      find.byKey(const ValueKey('timer-final-message-button')),
    );
    await tester.tap(find.byKey(const ValueKey('timer-final-message-button')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text(FinalMessagePage.messages[0]), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 11200));
    await tester.ensureVisible(
      find.byKey(const ValueKey('quit-program-button')),
    );
    await tester.tap(find.byKey(const ValueKey('quit-program-button')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Choose mode'), findsOneWidget);
  });

  testWidgets('developer button can open any story page when unlocked', (
    WidgetTester tester,
  ) async {
    await pumpModularApp(tester);

    PinGateController.unlock();
    Modular.to.navigate('/home/');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('developer-floating-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('developer-navigation-menu')),
      findsOneWidget,
    );
    expect(find.text('Timer together'), findsOneWidget);

    await tester.tap(find.text(StoryPages.all[1].title));
    await tester.pumpAndSettle();

    expect(find.text(StoryPages.all[1].title), findsOneWidget);
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
