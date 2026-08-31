import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/adaptive_platform.dart';
import '../core/responsive_layout.dart';
import '../widgets/adaptive_controls.dart';
import '../widgets/wireframe_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.layout, required this.platform, super.key});

  final ResponsiveLayoutInfo layout;
  final AdaptivePlatform platform;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool compactCards = true;
  bool liveUpdates = true;
  bool reduceMotion = false;
  int density = 1;

  @override
  Widget build(BuildContext context) {
    final layout = widget.layout;

    return DashboardPageFrame(
      layout: layout,
      title: 'Settings',
      subtitle: 'Adaptive controls and native-feeling inputs',
      actions: [
        AdaptiveActionButton(
          label: 'Apply',
          materialIcon: Icons.check_rounded,
          cupertinoIcon: CupertinoIcons.check_mark,
          onPressed: () {},
        ),
      ],
      child: layout.isDesktop
          ? _DesktopSettings(
              compactCards: compactCards,
              liveUpdates: liveUpdates,
              reduceMotion: reduceMotion,
              density: density,
              onCompactChanged: _setCompactCards,
              onLiveChanged: _setLiveUpdates,
              onMotionChanged: _setReduceMotion,
              onDensityChanged: _setDensity,
              layout: layout,
            )
          : _CompactSettings(
              compactCards: compactCards,
              liveUpdates: liveUpdates,
              reduceMotion: reduceMotion,
              density: density,
              onCompactChanged: _setCompactCards,
              onLiveChanged: _setLiveUpdates,
              onMotionChanged: _setReduceMotion,
              onDensityChanged: _setDensity,
              layout: layout,
            ),
    );
  }

  void _setCompactCards(bool value) {
    setState(() {
      compactCards = value;
    });
  }

  void _setLiveUpdates(bool value) {
    setState(() {
      liveUpdates = value;
    });
  }

  void _setReduceMotion(bool value) {
    setState(() {
      reduceMotion = value;
    });
  }

  void _setDensity(int value) {
    setState(() {
      density = value;
    });
  }
}

class _CompactSettings extends StatelessWidget {
  const _CompactSettings({
    required this.compactCards,
    required this.liveUpdates,
    required this.reduceMotion,
    required this.density,
    required this.onCompactChanged,
    required this.onLiveChanged,
    required this.onMotionChanged,
    required this.onDensityChanged,
    required this.layout,
  });

  final bool compactCards;
  final bool liveUpdates;
  final bool reduceMotion;
  final int density;
  final ValueChanged<bool> onCompactChanged;
  final ValueChanged<bool> onLiveChanged;
  final ValueChanged<bool> onMotionChanged;
  final ValueChanged<int> onDensityChanged;
  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ControlsPanel(
          compactCards: compactCards,
          liveUpdates: liveUpdates,
          reduceMotion: reduceMotion,
          density: density,
          onCompactChanged: onCompactChanged,
          onLiveChanged: onLiveChanged,
          onMotionChanged: onMotionChanged,
          onDensityChanged: onDensityChanged,
        ),
        SizedBox(height: layout.gap),
        _ButtonPreviewPanel(layout: layout),
      ],
    );
  }
}

class _DesktopSettings extends StatelessWidget {
  const _DesktopSettings({
    required this.compactCards,
    required this.liveUpdates,
    required this.reduceMotion,
    required this.density,
    required this.onCompactChanged,
    required this.onLiveChanged,
    required this.onMotionChanged,
    required this.onDensityChanged,
    required this.layout,
  });

  final bool compactCards;
  final bool liveUpdates;
  final bool reduceMotion;
  final int density;
  final ValueChanged<bool> onCompactChanged;
  final ValueChanged<bool> onLiveChanged;
  final ValueChanged<bool> onMotionChanged;
  final ValueChanged<int> onDensityChanged;
  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ControlsPanel(
            compactCards: compactCards,
            liveUpdates: liveUpdates,
            reduceMotion: reduceMotion,
            density: density,
            onCompactChanged: onCompactChanged,
            onLiveChanged: onLiveChanged,
            onMotionChanged: onMotionChanged,
            onDensityChanged: onDensityChanged,
          ),
        ),
        SizedBox(width: layout.gap),
        Expanded(
          child: Column(
            children: [
              _ButtonPreviewPanel(layout: layout),
              SizedBox(height: layout.gap),
              WireframePanel(
                minHeight: 174,
                child: const SkeletonColumn(lines: 6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.compactCards,
    required this.liveUpdates,
    required this.reduceMotion,
    required this.density,
    required this.onCompactChanged,
    required this.onLiveChanged,
    required this.onMotionChanged,
    required this.onDensityChanged,
  });

  final bool compactCards;
  final bool liveUpdates;
  final bool reduceMotion;
  final int density;
  final ValueChanged<bool> onCompactChanged;
  final ValueChanged<bool> onLiveChanged;
  final ValueChanged<bool> onMotionChanged;
  final ValueChanged<int> onDensityChanged;

  @override
  Widget build(BuildContext context) {
    return WireframePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Controls',
            style: TextStyle(
              color: DashboardPalette.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          _SettingRow(
            label: 'Compact cards',
            child: AdaptiveSwitch(
              value: compactCards,
              onChanged: onCompactChanged,
            ),
          ),
          _SettingRow(
            label: 'Live updates',
            child: AdaptiveSwitch(value: liveUpdates, onChanged: onLiveChanged),
          ),
          _SettingRow(
            label: 'Reduce motion',
            child: AdaptiveSwitch(
              value: reduceMotion,
              onChanged: onMotionChanged,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Density',
            style: TextStyle(
              color: DashboardPalette.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          AdaptiveSegmentedPicker(
            value: density,
            labels: const ['Cozy', 'Normal', 'Tight'],
            onChanged: onDensityChanged,
          ),
        ],
      ),
    );
  }
}

class _ButtonPreviewPanel extends StatelessWidget {
  const _ButtonPreviewPanel({required this.layout});

  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return WireframePanel(
      minHeight: layout.isMobile ? 220 : 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              color: DashboardPalette.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          AdaptiveActionButton(
            label: 'Primary',
            materialIcon: Icons.touch_app_rounded,
            cupertinoIcon: CupertinoIcons.hand_point_right_fill,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          AdaptiveActionButton(
            label: 'Secondary',
            materialIcon: Icons.favorite_rounded,
            cupertinoIcon: CupertinoIcons.heart_fill,
            filled: false,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          const AdaptiveActionButton(
            label: 'Disabled',
            materialIcon: Icons.block_rounded,
            cupertinoIcon: CupertinoIcons.slash_circle,
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: DashboardPalette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
