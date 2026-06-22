import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:benjii/modules/kang_game/view/kang_game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a dialog when Kang declaration wins the round', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: KangGamePage(
          initialRound: KangRoundState(
            players: const [
              KangPlayerState(
                id: 'you',
                name: 'You',
                hand: [
                  KangCard(rank: KangRank.ace, suit: KangSuit.spades),
                  KangCard(rank: KangRank.two, suit: KangSuit.hearts),
                ],
              ),
              KangPlayerState(
                id: 'benji',
                name: 'Benji',
                hand: [
                  KangCard(rank: KangRank.king, suit: KangSuit.clubs),
                  KangCard(rank: KangRank.queen, suit: KangSuit.diamonds),
                ],
              ),
            ],
            drawPile: const [],
            discardPile: const [],
            currentTurnIndex: 0,
            roundNumber: 1,
            status: KangRoundStatus.playing,
            turnPhase: KangTurnPhase.start,
            message: 'Testing Kang result.',
          ),
        ),
      ),
    );

    final declareButton = find.byKey(const ValueKey('kang-declare-button'));
    await tester.ensureVisible(declareButton);
    await tester.tap(declareButton);
    await tester.pumpAndSettle();

    final resultDialog = find.byKey(const ValueKey('kang-round-result-dialog'));
    expect(resultDialog, findsOneWidget);
    expect(find.text('You wins'), findsOneWidget);
    expect(
      find.descendant(
        of: resultDialog,
        matching: find.textContaining('You wins by Kang'),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('kang-round-result-close-button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('kang-round-result-dialog')),
      findsNothing,
    );
  });
}
