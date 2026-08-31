import 'package:flutter/foundation.dart';

class AdaptivePlatform {
  const AdaptivePlatform._({required this.targetPlatform, required this.isWeb});

  final TargetPlatform targetPlatform;
  final bool isWeb;

  static AdaptivePlatform current() {
    return AdaptivePlatform._(
      targetPlatform: defaultTargetPlatform,
      isWeb: kIsWeb,
    );
  }

  bool get isApple {
    return targetPlatform == TargetPlatform.iOS ||
        targetPlatform == TargetPlatform.macOS;
  }

  bool get usesCupertinoControls => isApple && !isWeb;

  bool get isDesktopPlatform {
    return targetPlatform == TargetPlatform.linux ||
        targetPlatform == TargetPlatform.macOS ||
        targetPlatform == TargetPlatform.windows;
  }

  String get label {
    if (isWeb) {
      return 'Web';
    }

    return switch (targetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }
}
