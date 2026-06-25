import 'dart:async';

import 'package:flutter/material.dart';

class AppAssetPreloader extends StatefulWidget {
  const AppAssetPreloader({
    super.key,
    required this.child,
    required this.imageAssets,
    this.cacheWidth,
  });

  final Widget child;
  final List<String> imageAssets;
  final int? cacheWidth;

  @override
  State<AppAssetPreloader> createState() => _AppAssetPreloaderState();
}

class _AppAssetPreloaderState extends State<AppAssetPreloader> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_preloadAssets());
    });
  }

  Future<void> _preloadAssets() async {
    for (final asset in widget.imageAssets) {
      if (!mounted) {
        return;
      }
      try {
        await precacheImage(
          ResizeImage.resizeIfNeeded(
            widget.cacheWidth,
            null,
            AssetImage(asset),
          ),
          context,
          onError: (_, _) {},
        );
      } catch (_) {}
      await Future<void>.delayed(Duration.zero);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
