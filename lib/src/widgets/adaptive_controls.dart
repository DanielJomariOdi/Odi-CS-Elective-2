import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/adaptive_platform.dart';
import 'wireframe_widgets.dart';

class AdaptiveActionButton extends StatelessWidget {
  const AdaptiveActionButton({
    required this.label,
    required this.materialIcon,
    required this.cupertinoIcon,
    this.onPressed,
    this.filled = true,
    super.key,
  });

  final String label;
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final platform = AdaptivePlatform.current();

    if (platform.usesCupertinoControls) {
      return CupertinoButton(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: filled ? DashboardPalette.accent : DashboardPalette.surface,
        disabledColor: DashboardPalette.line,
        borderRadius: BorderRadius.circular(8),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              cupertinoIcon,
              size: 18,
              color: filled ? Colors.white : DashboardPalette.accent,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : DashboardPalette.accent,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      );
    }

    final minimumSize = platform.isWeb ? const Size(132, 44) : null;

    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(materialIcon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(materialIcon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: minimumSize,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final platform = AdaptivePlatform.current();

    if (platform.usesCupertinoControls) {
      return CupertinoSwitch(
        value: value,
        activeTrackColor: DashboardPalette.accent,
        onChanged: onChanged,
      );
    }

    return Switch(
      value: value,
      activeThumbColor: DashboardPalette.accent,
      onChanged: onChanged,
    );
  }
}

class AdaptiveSegmentedPicker extends StatelessWidget {
  const AdaptiveSegmentedPicker({
    required this.value,
    required this.onChanged,
    required this.labels,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final platform = AdaptivePlatform.current();

    if (platform.usesCupertinoControls) {
      return CupertinoSlidingSegmentedControl<int>(
        groupValue: value,
        children: {
          for (var i = 0; i < labels.length; i++)
            i: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                labels[i],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
        },
        onValueChanged: (nextValue) {
          if (nextValue != null) {
            onChanged(nextValue);
          }
        },
      );
    }

    return SegmentedButton<int>(
      segments: [
        for (var i = 0; i < labels.length; i++)
          ButtonSegment<int>(value: i, label: Text(labels[i])),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
