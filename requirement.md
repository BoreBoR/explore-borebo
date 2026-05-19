# Birthday Surprise App Requirements

## 1. Project Goal

Build a romantic, soft birthday surprise web app for your girlfriend. The app should feel personal, private, and made only for her.

The app is not only a 10-page story. It should be structured as 4 main parts:
- Part 1: PIN Unlock.
- Part 2: Birthday Story Flow with 10 inside pages.
- Part 3: Future Feature Placeholder.
- Part 4: Future Feature Placeholder.

Current implementation focus:
- Part 1 is implemented.
- Part 2 is being implemented as a 10-page story.
- Part 3 and Part 4 are intentionally undecided and should stay as documented placeholders for now.

Secondary goals:
- Work well on iPhone 13 first.
- Also look polished on iPad portrait and landscape.
- Be deployable for free on GitHub Pages as a Flutter web app.
- Keep personal text easy to edit later.

## 2. Target Devices and Responsive Rules

Primary target:
- iPhone 13 size: approximately `390 x 844`.

Secondary targets:
- iPad portrait.
- iPad landscape.
- Desktop browser as a centered fallback.

Responsive behavior:
- Main content should be centered.
- On phone, use full available width with safe padding.
- On tablet/desktop, constrain content to a readable max width, around `480-640`.
- Text must never overflow or be cut off.
- Buttons must be easy to tap on mobile.
- Avoid layouts that require hover.
- Avoid desktop-only interactions.

## 3. App Tone and Design Direction

Tone:
- Romantic.
- Soft.
- Warm.
- Personal.
- Calm and sincere.

Visual direction:
- Light background.
- Soft colors.
- Rounded but not overly playful UI.
- Gentle spacing.
- Message-first screens.
- Avoid busy dashboards or complex layouts.

Animation direction:
- Fade in text.
- Slide up content gently.
- Stagger message lines.
- Soft page transitions.
- Small celebratory animation on final/reveal moments.

Avoid:
- Loud game-like UI.
- Too many effects on one screen.
- Fast or distracting animations.
- Dense text blocks that are hard to read on phone.

## 4. Main App Structure and Progress

### Part 1: PIN Unlock

Progress:
- [x] Implemented with romantic copy and custom wrong PIN text.

Purpose:
- Make the experience feel private and secret.

Current behavior:
- Route: `/`.
- Valid PIN: `140226`.
- Wrong PIN text: `Hmm, not that one. Try the day that matters to us.`
- Correct PIN opens Part 2 at Story Page 1.

Suggested copy:
- Title: `For someone special`
- Subtitle: `Enter the secret date to open your surprise`

### Part 2: Birthday Story Flow

Progress:
- [x] Story Page 1: Welcome Reveal.
- [x] Story Page 2: Birthday Greeting.
- [x] Story Page 3: Things I Love About You.
- [x] Story Page 4: Shared Memories.
- [x] Story Page 5: Photo or Memory Gallery.
- [x] Story Page 6: Personal Letter.
- [x] Story Page 7: Wish / Cake Interaction.
- [x] Story Page 8: Final Surprise.
- [x] Story Page 9: Closing Happy Birthday.
- [x] Story Page 10: Soft Ending / Restart Moment.

Purpose:
- Create a focused 10-page birthday story after the PIN unlock.
- This part should feel like one guided experience, but it is only one main part of the full app.

Current behavior:
- Route: `/home/`.
- Progress should display as `1 / 10` through `10 / 10`.
- The PIN screen is not counted in story progress.
- Story Page 10 can restart Part 2 from Story Page 1 without returning to the PIN screen.

### Part 3: Future Feature Placeholder

Progress:
- [ ] Not decided.

Purpose:
- Reserved for a larger future feature outside the 10-page story.

Rules for now:
- Do not build UI for this part yet.
- Do not force this part into the story flow.
- Decide later whether this becomes a gallery, interactive memory area, music feature, gift reveal, or another experience.

### Part 4: Future Feature Placeholder

Progress:
- [ ] Not decided.

Purpose:
- Reserved for another larger future feature outside the 10-page story.

Rules for now:
- Do not build UI for this part yet.
- Do not force this part into the story flow.
- Decide later after Part 2 feels complete.

## 5. Part 2 Story Page Details

### Story Page 1: Welcome Reveal

Purpose:
- Confirm she opened the right surprise.

Copy:
- Title: `Hi love`
- Body: `I made this little place just for you. Take your time, there are a few birthday notes waiting inside.`
- Button: `Start`

### Story Page 2: Birthday Greeting

Purpose:
- Main birthday message.

Copy:
- Title: `Happy Birthday`
- Body: `Today is about you, your smile, your heart, and every small thing that makes you unforgettable.`
- Button: `Next`

### Story Page 3: Things I Love About You

Purpose:
- Show a short list of reasons she is special.

Copy:
- Title: `Things I love about you`
- Body: `A few reasons, with many more still kept in my heart.`
- Items:
  - `The way you make ordinary days feel softer.`
  - `Your smile when something makes you truly happy.`
  - `How much care you put into the people you love.`
  - `The little things you do without even noticing.`
  - `Simply being you.`
- Button: `Keep going`

### Story Page 4: Shared Memories

Purpose:
- Bring back meaningful moments.

Copy:
- Title: `Little memories I keep`
- Body: `Some moments stay with me because they had you in them.`
- Memory cards:
  - `The first moment: [Add memory here]`
  - `A day I still smile about: [Add memory here]`
  - `Something small but precious: [Add memory here]`
- Button: `Next memory`

### Story Page 5: Photo or Memory Gallery

Purpose:
- Leave space for photos or visual memories.

Copy:
- Title: `Moments with you`
- Body: `Photos can go here later. For now, these are little spaces for our favorite memories.`
- Placeholder cards:
  - `[Add photo or memory 1]`
  - `[Add photo or memory 2]`
  - `[Add photo or memory 3]`
  - `[Add photo or memory 4]`
- Button: `Next surprise`

Implementation note:
- Do not block the app if final image assets are not ready.
- Use placeholders first.
- Add real assets later under an app assets directory and register them in `pubspec.yaml`.

### Story Page 6: Personal Letter

Purpose:
- Longer emotional message.

Copy:
- Title: `A small letter for you`
- Body: `[Write a longer personal letter here. Keep this page scrollable so the message can grow later without breaking iPhone layout.]`
- Button: `I read it`

Layout:
- Use readable paragraph width.
- Allow vertical scrolling if the letter is long.
- Keep navigation reachable.

### Story Page 7: Wish / Cake Interaction

Purpose:
- Add one small interactive birthday moment.

Behavior:
- Show a wish card before tapping.
- User taps `I made one`.
- After tap, show a reveal message and change the button to `Open the final surprise`.

Copy:
- Title before tap: `Make a wish`
- Body before tap: `Close your eyes for a second and keep one little wish in your heart.`
- Button before tap: `I made one`
- Title after tap: `I hope it finds you`
- Body after tap: `[Write a sweet wish reveal here]`
- Button after tap: `Open the final surprise`

### Story Page 8: Final Surprise

Purpose:
- Emotional peak before the closing screens.

Copy:
- Title: `One more thing`
- Body: `[Write the most important message here]`
- Button: `Final page`

Interaction:
- Use a slower reveal or soft celebratory accent.

### Story Page 9: Closing Happy Birthday

Purpose:
- End the emotional message clearly and warmly.

Copy:
- Title: `Happy Birthday, my love`
- Body: `[Write final closing sentence here]`
- Footer: `Made with love, just for you`
- Button: `One last page`

### Story Page 10: Soft Ending / Restart Moment

Purpose:
- Give the story a calm ending and a way to replay it.

Copy:
- Title: `Whenever you want to smile again`
- Body: `This little surprise will be here for you.`
- Button: `Read it again`

Behavior:
- Button restarts Part 2 at Story Page 1.
- Do not return to the PIN screen.

## 6. Navigation Requirements

Main navigation:
- Part 1 opens Part 2 after valid PIN.
- Part 2 is a linear 10-page story.
- Part 3 and Part 4 are not visible yet.

Part 2 navigation:
- One primary button moves forward.
- Back button can move to the previous story page.
- Story Page 10 button restarts to Story Page 1.
- Progress should show `1 / 10` through `10 / 10`.

State:
- The flow can be local in memory only.
- Track current story page index.
- Track whether Story Page 7 wish interaction has been completed.
- No backend is required.
- No login is required.
- No analytics are required for the first version.

## 7. Implementation Task Breakdown

Foundation:
- Keep current Flutter structure with `flutter_modular`, `bloc`, `pinput`, and Material 3.
- Keep `/` for PIN landing.
- Keep `/home/` for Part 2 story flow.
- Keep personal content easy to edit in one story data list.

Reusable UI:
- Birthday story page shell.
- Animated page transition.
- Page progress indicator.
- Primary navigation button.
- Optional back navigation button.
- List/card layout for reasons and memories.
- Placeholder grid for future photo/memory assets.
- Wish interaction state.
- Restart behavior on final page.

Visual assets:
- Initial version uses text, icons, and simple decorative UI only.
- Real photos can be added later.

## 8. Deployment Plan

Default target:
- GitHub Pages.

Build command:

```sh
fvm flutter build web --release --base-href /benji/
```

Use the repository name in `--base-href`.

Deployment checklist:
- Build Flutter web release.
- Confirm `build/web` output works locally.
- Publish `build/web` to GitHub Pages.
- Open the GitHub Pages URL on iPhone 13 or mobile browser.
- Confirm PIN and all story pages work after refresh.

Alternative free platforms:
- Netlify.
- Vercel.
- Firebase Hosting.

## 9. Test Plan

Automated checks:

```sh
fvm flutter analyze
fvm flutter test
```

Manual checks:
- Open app on iPhone 13 viewport.
- Open app on iPad portrait viewport.
- Open app on iPad landscape viewport.
- Enter wrong PIN and confirm custom error appears.
- Enter correct PIN `140226` and confirm Story Page 1 opens.
- Move through all 10 story pages.
- Confirm Story Page 7 wish interaction changes after tapping.
- Confirm Story Page 10 restart returns to Story Page 1.
- Confirm text does not overflow on phone.
- Confirm final page feels complete.
- Refresh browser on deployed build and confirm app still loads.

## 10. Acceptance Criteria

The app is ready for this milestone when:
- Part 1 PIN unlock works.
- Correct PIN opens Part 2 Story Page 1.
- Wrong PIN shows a soft custom message.
- Part 2 contains 10 story pages.
- Story progress counts `1 / 10` through `10 / 10`.
- Story Page 7 has a working wish interaction.
- Story Page 10 restarts Part 2 without returning to PIN.
- Part 3 and Part 4 are documented as future placeholders.
- The app is comfortable to use on iPhone 13.
- `fvm flutter analyze` passes.
- `fvm flutter test` passes.

## 11. Content To Fill Later

Use this checklist before final delivery:

- Girlfriend name or nickname: `[Add here]`
- Main birthday message: `[Add here]`
- Five things I love about you: `[Add here]`
- Three shared memories: `[Add here]`
- Photo choices or memory placeholders: `[Add here]`
- Long personal letter: `[Add here]`
- Wish reveal text: `[Add here]`
- Final surprise message: `[Add here]`
- Final closing sentence: `[Add here]`
- Final definitions for Part 3 and Part 4: `[Add here]`

## 12. Open Decisions For Later

These do not block the current milestone:
- What Part 3 should become.
- What Part 4 should become.
- Whether to add real photos.
- Whether to add music.
- Whether the final surprise links to an external gift, video, or message.
- Whether to rename the app title from `Benjii` to something more personal.
