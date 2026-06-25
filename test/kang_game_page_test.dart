import 'package:benjii/modules/kang_game/model/kang_card.dart';
import 'package:benjii/modules/kang_game/model/kang_round_state.dart';
import 'package:benjii/modules/kang_game/view/kang_game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  KangRoundState roundWithOpponentStatus(KangRoundStatus status) {
    return KangRoundState(
      players: const [
        KangPlayerState(
          id: 'you',
          name: 'You',
          hand: [KangCard(rank: KangRank.two, suit: KangSuit.hearts)],
        ),
        KangPlayerState(
          id: 'opponent',
          name: 'Opponent',
          hand: [KangCard(rank: KangRank.ace, suit: KangSuit.spades)],
        ),
      ],
      drawPile: const [],
      discardPile: const [
        KangCard(rank: KangRank.nine, suit: KangSuit.diamonds),
        KangCard(rank: KangRank.four, suit: KangSuit.spades),
        KangCard(rank: KangRank.four, suit: KangSuit.hearts),
        KangCard(rank: KangRank.ace, suit: KangSuit.clubs),
      ],
      currentTurnIndex: 0,
      roundNumber: 1,
      status: status,
      turnPhase: KangTurnPhase.start,
      winnerId: status == KangRoundStatus.finished ? 'you' : null,
      winReason: status == KangRoundStatus.finished ? KangWinReason.kang : null,
    );
  }

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

  testWidgets('reveals opponent hand when multiplayer round is finished', (
    tester,
  ) async {
    final round = roundWithOpponentStatus(KangRoundStatus.finished);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KangGameBoard(
            title: 'Kang Multiplayer',
            round: round,
            primaryPlayerId: 'you',
            selectedCards: const [],
            canDropPlayer: (_) => false,
            hideCardsForPlayer: (player) =>
                player.id != 'you' && round.status != KangRoundStatus.finished,
            onCardTap: (_, _) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('kang-card-AS')), findsOneWidget);
  });

  testWidgets('keeps opponent hand hidden while multiplayer round is playing', (
    tester,
  ) async {
    final round = roundWithOpponentStatus(KangRoundStatus.playing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KangGameBoard(
            title: 'Kang Multiplayer',
            round: round,
            primaryPlayerId: 'you',
            selectedCards: const [],
            canDropPlayer: (_) => false,
            hideCardsForPlayer: (player) =>
                player.id != 'you' && round.status != KangRoundStatus.finished,
            onCardTap: (_, _) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('kang-card-AS')), findsNothing);
  });

  testWidgets('shows dropped card history grouped by player', (tester) async {
    final round = KangRoundState(
      players: const [
        KangPlayerState(
          id: 'you',
          name: 'You',
          hand: [KangCard(rank: KangRank.two, suit: KangSuit.hearts)],
        ),
        KangPlayerState(
          id: 'opponent',
          name: 'Opponent',
          hand: [KangCard(rank: KangRank.ace, suit: KangSuit.spades)],
        ),
      ],
      drawPile: const [],
      discardPile: const [
        KangCard(rank: KangRank.nine, suit: KangSuit.diamonds),
        KangCard(rank: KangRank.four, suit: KangSuit.spades),
        KangCard(rank: KangRank.four, suit: KangSuit.hearts),
        KangCard(rank: KangRank.ace, suit: KangSuit.clubs),
      ],
      currentTurnIndex: 0,
      roundNumber: 1,
      status: KangRoundStatus.playing,
      turnPhase: KangTurnPhase.start,
      droppedCardsByPlayer: const {
        'you': [
          KangCard(rank: KangRank.four, suit: KangSuit.spades),
          KangCard(rank: KangRank.four, suit: KangSuit.hearts),
        ],
        'opponent': [KangCard(rank: KangRank.ace, suit: KangSuit.clubs)],
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KangGameBoard(
            title: 'Kang Multiplayer',
            round: round,
            primaryPlayerId: 'you',
            selectedCards: const [],
            canDropPlayer: (_) => false,
            hideCardsForPlayer: (player) => player.id != 'you',
            onCardTap: (_, _) {},
          ),
        ),
      ),
    );

    final historyButton = find.byKey(
      const ValueKey('kang-show-dropped-cards-button'),
    );
    expect(historyButton, findsOneWidget);

    await tester.ensureVisible(historyButton);
    await tester.tap(historyButton);
    await tester.pumpAndSettle();

    final dialog = find.byKey(const ValueKey('kang-dropped-cards-dialog'));
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('All dropped (4)')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Y (2)')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('O (1)')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('kang-card-9D')), findsOneWidget);
    expect(find.byKey(const ValueKey('kang-card-4S')), findsWidgets);
    expect(find.byKey(const ValueKey('kang-card-AC')), findsWidgets);
  });
}
