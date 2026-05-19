import 'package:flutter/material.dart';

enum StoryPageKind {
  standard,
  list,
  memoryCards,
  gallery,
  letter,
  wish,
  restart,
}

class StoryPageData {
  const StoryPageData({
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.icon,
    this.kind = StoryPageKind.standard,
    this.items = const [],
    this.footer,
  });

  final String title;
  final String body;
  final String buttonLabel;
  final IconData icon;
  final StoryPageKind kind;
  final List<String> items;
  final String? footer;
}
