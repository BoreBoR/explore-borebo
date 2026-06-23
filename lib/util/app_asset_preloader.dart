import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssetPreloader extends StatefulWidget {
  const AppAssetPreloader({super.key, required this.child});

  final Widget child;

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
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest
        .listAssets()
        .where((asset) => asset.startsWith('assets/images/'))
        .toList();

    final rasterAssets = assets.where(_isRasterImage);
    for (final asset in rasterAssets) {
      if (!mounted) {
        return;
      }
      try {
        await precacheImage(AssetImage(asset), context);
      } catch (_) {}
    }

    final svgAssets = assets.where((asset) => asset.endsWith('.svg'));
    svg.cache.maximumSize = svgAssets.length + 16;
    for (final asset in svgAssets) {
      if (!mounted) {
        return;
      }
      try {
        await SvgAssetLoader(asset).loadBytes(context);
      } catch (_) {}
    }
  }

  bool _isRasterImage(String asset) {
    return asset.endsWith('.png') ||
        asset.endsWith('.jpg') ||
        asset.endsWith('.jpeg') ||
        asset.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
