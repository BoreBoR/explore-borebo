import 'package:benjii/modules/home/view/widget/story_page_data.dart';
import 'package:flutter/material.dart';

abstract final class StoryPages {
  static const all = [
    StoryPageData(
      title: 'Hi love',
      body:
          'I made this little place just for you. Take your time, there are a few birthday notes waiting inside.',
      buttonLabel: 'Start',
      icon: Icons.favorite,
    ),
    StoryPageData(
      title: 'Happy Birthday',
      body:
          'Today is about you, your smile, your heart, and every small thing that makes you unforgettable.',
      buttonLabel: 'Next',
      icon: Icons.cake_outlined,
    ),
    StoryPageData(
      title: 'Things I love about you',
      body: 'A few reasons, with many more still kept in my heart.',
      buttonLabel: 'Keep going',
      icon: Icons.auto_awesome,
      kind: StoryPageKind.list,
      items: [
        'The way you make ordinary days feel softer.',
        'Your smile when something makes you truly happy.',
        'How much care you put into the people you love.',
        'The little things you do without even noticing.',
        'Simply being you.',
      ],
    ),
    StoryPageData(
      title: 'Little memories I keep',
      body: 'Some moments stay with me because they had you in them.',
      buttonLabel: 'Next memory',
      icon: Icons.collections_bookmark_outlined,
      kind: StoryPageKind.memoryCards,
      items: [
        'The first moment: [Add memory here]',
        'A day I still smile about: [Add memory here]',
        'Something small but precious: [Add memory here]',
      ],
    ),
    StoryPageData(
      title: 'Moments with you',
      body: 'A few little scenes that remind me of time spent with you.',
      buttonLabel: 'Next surprise',
      icon: Icons.photo_library_outlined,
      kind: StoryPageKind.gallery,
      items: [
        'Golden moments',
        'Our quiet time',
        'Little things I keep',
        'Evenings together',
      ],
      imageAssets: [
        'assets/images/moments/moment_1.png',
        'assets/images/moments/moment_2.png',
        'assets/images/moments/moment_3.png',
        'assets/images/moments/moment_4.png',
      ],
    ),
    StoryPageData(
      title: 'A small letter for you',
      body:
          '[Write a longer personal letter here. Keep this page scrollable so the message can grow later without breaking iPhone layout.]',
      buttonLabel: 'I read it',
      icon: Icons.mail_outline_rounded,
      kind: StoryPageKind.letter,
    ),
    StoryPageData(
      title: 'Make a wish',
      body:
          'Close your eyes for a second and keep one little wish in your heart.',
      buttonLabel: 'I made one',
      icon: Icons.local_fire_department_outlined,
      kind: StoryPageKind.wish,
    ),
    StoryPageData(
      title: 'One more thing',
      body: '[Write the most important message here]',
      buttonLabel: 'Final page',
      icon: Icons.volunteer_activism_outlined,
    ),
    StoryPageData(
      title: 'Happy Birthday, my love',
      body: '[Write final closing sentence here]',
      buttonLabel: 'One last page',
      footer: 'Made with love, just for you',
      icon: Icons.celebration_outlined,
    ),
    StoryPageData(
      title: 'Whenever you want to smile again',
      body: 'This little surprise will be here for you.',
      buttonLabel: 'Time together',
      icon: Icons.hourglass_top_rounded,
      kind: StoryPageKind.timeTogether,
    ),
  ];
}
