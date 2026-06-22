# Kang Multiplayer Game Task Spec

## Summary

Create a v1 multiplayer card game based on Thai Kang.

The game is a 2-player, turn-based card game using a standard 52-card deck. V1 should stay compatible with the Firebase Spark/free plan by using Firebase Auth for player identity and Cloud Firestore for live multiplayer state. Shuffle, deal, action validation, and scoring are handled in the Flutter client for now.

## Key Implementation Tasks

- Progress:
  - [x] Add free-plan Firestore setup config.
  - [x] Add `Kang Game` mode entry and route.
  - [x] Add local/offline rule prototype screen.
  - [x] Add pure Dart card/rule engine for deck, values, pairs, Win Out, Kang winner, and scoring.
  - [x] Add unit/widget tests for the first local slice.
  - [ ] Build Firestore create/join room flow.
  - [ ] Sync room state between two clients.
  - [ ] Replace local prototype actions with Firestore-backed actions.

- Add Firebase multiplayer dependencies:
  - `cloud_firestore`
  - Keep existing `firebase_auth` for player identity.
- Add a new Mode Select entry: `Kang Game`.
- Build a 2-player room flow:
  - Create room generates a short invite code.
  - Join room accepts invite code.
  - Room waits until exactly 2 players are present.
  - After a round ends, both players can start another round in the same room.
- Model each round with:
  - players
  - current turn index
  - draw pile
  - discard pile
  - each player's hand
  - each player's placed pairs
  - game points
  - round number
  - round status
  - winner
  - reason for win: `kang` or `win_out`
- Implement Firestore-backed client actions:
  - `create_room`
  - `join_room`
  - `start_round`
  - `declare_kang`
  - `draw_from_deck`
  - `drop_card`
  - `auto_drop_match`
  - `end_turn`
  - `start_next_round`
- Store v1 room and hand state in Firestore for simplicity:
  - Security and hidden hands are not a concern for the private first version.
  - Both players can read the full room state.
- Use Firestore snapshot listeners in Flutter so both clients update live.

## Game Type

- Turn-based multiplayer card game.
- 2 players.
- Standard 52-card deck.

## Score Types

### 1. Hand Value

Hand Value is used only to compare who wins when Kang is declared.

- Calculated from cards currently remaining in a player's hand.
- Cards already placed down as pairs are not counted.

Card values:

- Ace = 1
- 2-10 = face value
- J, Q, K = 10

### 2. Game Points

Game Points are awarded after a player wins a round.

- Normal win gives 1 game point.
- Each Ace in the winner's remaining hand gives +1 additional game point.
- For Win Out, Aces in the winning hand also give +1 point each.

## Initial Setup

- Shuffle the deck.
- Deal 5 cards to each player.
- Remaining cards become the draw pile.
- One card is placed face-up as the discard pile.
- Check Win Out only from each player's initial 5-card hand.

## Win Out Rules

Win Out can only happen from the initial 5-card hand dealt at the start of the round.

A player wins immediately if their initial hand contains one of these patterns:

- Three of a kind: any 3 cards with the same rank.
- Flush: all 5 cards have the same suit.
- Straight: all 5 cards form consecutive ranks.

If both players have Win Out after the deal, mark the round as a draw for v1 unless a later tie-break rule is defined.

## Turn Rules

At the beginning of a player's turn, before taking any action, the player may declare Kang.

If the player declares Kang:

- The round ends immediately.
- All players reveal their current remaining hand.
- Calculate each player's hand value.
- The lowest hand value wins.
- If the Kang declarer ties for the lowest hand value, the Kang declarer wins.

If the player does not declare Kang:

1. Draw one card from the draw pile.
2. Select one card from hand to drop to the discard pile.
3. If the opponent has a card with the same rank:
- The opponent's matching-rank cards are highlighted.
- The opponent may choose one or more matching-rank cards to drop.
   - The opponent's normal draw turn is skipped.
   - The original player plays again.
4. If the opponent does not have a matching-rank card:
   - Turn passes to the opponent.

Important turn restrictions:

- Once the player draws or drops a card, they can no longer declare Kang during that turn.
- Kang is only allowed at the very start of the player's turn.

## Drop Match Rule

- A dropped card can be matched by the opponent if the opponent has a card with the same rank.
- Matching is by rank, not suit.
- The opponent may choose one or more matching-rank cards to drop.
- The opponent does not get to draw before this auto-drop.
- After the matching response drop, the original player takes another turn.
- Dropped cards are removed from hand value calculation because they are no longer in hand.
- Dropping a card is a select-and-confirm action:
  - Tapping a card selects/highlights it.
  - During a normal drop, multiple selected cards are allowed when they share the same rank.
  - During a matching response, multiple matching-rank cards may be selected.
  - The `Drop card` button is enabled only after a valid card is selected.
  - Pressing `Drop card` confirms the drop.
- Cards should display sorted by rank first, then suit/card type.
- The newly drawn card should be highlighted with a green border until it is dropped or the turn changes.

Example:

```text
Player 1 drops:
A♠

Player 2 has:
A♥ 3♣ 5♦ 8♠

Player 2 sees A♥ highlighted and chooses it to drop.
Player 2's turn is skipped.
Player 1 plays again.
```

## Round Scoring

Normal Kang win:

- Winner gains 1 game point.
- Winner gains +1 point per Ace remaining in hand.

Example:

```text
Winner's remaining hand:
A♠ A♥ 3♣

Hand value = 5
Game points gained = 1 + 2 = 3
```

Win Out scoring:

```text
Initial hand:
A♠ A♥ A♦ 5♣ 9♣

This is Three of a Kind.
Game points gained = 1 + 3 = 4
```

## Multiplayer State Requirements

Each round should track:

- players
- current turn index
- draw pile
- discard pile
- each player's hand
- each player's placed pairs
- game points
- round number
- round status
- winner
- reason for win: `kang` or `win_out`

## Allowed Player Actions

- `declare_kang`
- `draw_from_deck`
- `drop_card`
- `respond_to_drop`
- `end_turn`
- `start_next_round`

## Validation Rules

- `declare_kang` is valid only at the start of turn.
- Draw is valid only once per turn.
- Drop is required after drawing.
- A dropped card must exist in the player's current hand.
- `respond_to_drop` is required when the opponent has the same rank as the dropped card.
- During `respond_to_drop`, only matching-rank cards are valid to drop.
- Turn cannot end until the player has dropped after drawing.
- `start_next_round` is valid only after the current round has ended.

## Multi-Round / Rematch Rules

- A room can continue across multiple rounds.
- Game points persist between rounds.
- After a round ends, show the round result and current total score.
- Provide a `Play again` / `Next round` action.
- For v1, either player may start the next round after the previous round result is shown.
- Starting the next round:
  - increments `roundNumber`
  - creates a fresh shuffled deck
  - deals 5 new cards to each player
  - resets placed pairs
  - resets turn state
  - keeps existing game points
  - checks Win Out from the new initial hands

## Firebase Architecture

- Use Firebase Auth UID as the player identity.
- Use invite-code rooms.
- Use Firestore for live multiplayer state.
- Use client-side game logic for the Spark/free-plan MVP.
- Do not use Cloud Functions in v1.
- Use Firestore security rules to ensure:
  - Only signed-in users can create or join rooms.
  - Only players in a room can read and update that room.
  - Full anti-cheat protection is intentionally out of scope for v1.

Suggested room document:

- `kang_rooms/{roomId}`:
  - players
  - invite code
  - current turn
  - draw pile
  - discard pile
  - each player's hand
  - placed pairs
  - score
  - round number
  - round status
  - winner

## Test Plan

- Unit-test:
  - card value calculation
  - pair removal
  - Kang comparison
  - Ace bonus scoring
  - straight detection
  - flush detection
  - three-of-a-kind detection
- Repository/service-test:
  - each allowed action
  - each invalid action
  - Win Out draw handling
  - Kang tie where declarer wins
- Widget-test:
  - create room
  - join room
  - waiting state
  - turn state
  - Kang declaration
  - draw/discard flow
  - round result screen
  - immediate next round / rematch flow
- Security-rule-test:
  - a signed-out user cannot read or write rooms
  - a non-room user cannot read or write a room
  - both room players can read the complete v1 room state

## Assumptions

- Invite-code rooms are used for v1.
- Cloud Functions are not used in v1 so the game can stay on the Firebase Spark/free plan.
- Firestore is used for live multiplayer state.
- Firebase Auth UID is the player identity.
- Security and anti-cheat protection are not concerns for the private first version.
- Tie Win Out is a draw in v1.
- MVP includes multiple rounds in the same room with persistent game points.
