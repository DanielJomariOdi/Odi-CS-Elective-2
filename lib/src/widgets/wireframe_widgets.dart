import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/responsive_layout.dart';

class DashboardPalette {
  const DashboardPalette._();

  static const background = Color(0xFFE6E7E9);
  static const surface = Color(0xFFF8F8F8);
  static const surfaceSoft = Color(0xFFF0F1F3);
  static const wire = Color(0xFFB9BABC);
  static const wireLight = Color(0xFFEDEEEF);
  static const line = Color(0xFFD5D7DA);
  static const ink = Color(0xFF1D1D20);
  static const muted = Color(0xFF696D73);
  static const accent = Color(0xFF0A84FF);
  static const mint = Color(0xFF28B7A7);
  static const darkBar = Color(0xFF18191B);
}

class DashboardPageFrame extends StatelessWidget {
  const DashboardPageFrame({
    required this.layout,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    super.key,
  });

  final ResponsiveLayoutInfo layout;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = layout.isMobile ? 92.0 : layout.pagePadding;

    return ColoredBox(
      color: DashboardPalette.background,
      child: SingleChildScrollView(
        physics: kIsWeb
            ? const ClampingScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          layout.pagePadding,
          layout.pagePadding,
          layout.pagePadding,
          bottomPadding,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(
                  title: title,
                  subtitle: subtitle,
                  actions: actions,
                  compact: layout.isMobile,
                ),
                SizedBox(height: layout.gap),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.actions,
    required this.compact,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: DashboardPalette.ink,
              fontSize: compact ? 26 : 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: compact ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DashboardPalette.muted,
                fontSize: 14,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [titleBlock]),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleBlock,
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: actions,
          ),
        ],
      ],
    );
  }
}

class ResponsiveWireGrid extends StatelessWidget {
  const ResponsiveWireGrid({
    required this.columns,
    required this.spacing,
    required this.childAspectRatio,
    required this.children,
    super.key,
  });

  final int columns;
  final double spacing;
  final double childAspectRatio;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

class WireframePanel extends StatelessWidget {
  const WireframePanel({
    this.child,
    this.height,
    this.minHeight,
    this.padding = const EdgeInsets.all(16),
    this.fill = DashboardPalette.surface,
    this.borderColor = DashboardPalette.line,
    super.key,
  });

  final Widget? child;
  final double? height;
  final double? minHeight;
  final EdgeInsetsGeometry padding;
  final Color fill;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class WireMetricCard extends StatelessWidget {
  const WireMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return WireframePanel(
      fill: DashboardPalette.wire,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(190),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 21),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DashboardPalette.ink,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DashboardPalette.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class WireListSection extends StatelessWidget {
  const WireListSection({
    required this.title,
    required this.itemCount,
    required this.layout,
    super.key,
  });

  final String title;
  final int itemCount;
  final ResponsiveLayoutInfo layout;

  @override
  Widget build(BuildContext context) {
    return WireframePanel(
      padding: EdgeInsets.all(layout.isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: DashboardPalette.ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            itemCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 10),
              child: WireListItem(index: index, compact: layout.isMobile),
            ),
          ),
        ],
      ),
    );
  }
}

class WireListItem extends StatelessWidget {
  const WireListItem({required this.index, required this.compact, super.key});

  final int index;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 70 : 78,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DashboardPalette.wireLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 42 : 48,
            height: compact ? 42 : 48,
            decoration: BoxDecoration(
              color: index.isEven
                  ? DashboardPalette.wire
                  : DashboardPalette.line,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(widthFactor: compact ? 0.78 : 0.52),
                const SizedBox(height: 8),
                _SkeletonLine(
                  widthFactor: compact ? 0.56 : 0.34,
                  height: 8,
                  color: DashboardPalette.line,
                ),
              ],
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 12),
            _SkeletonLine(width: 76, height: 10),
          ],
        ],
      ),
    );
  }
}

class SkeletonColumn extends StatelessWidget {
  const SkeletonColumn({required this.lines, this.compact = false, super.key});

  final int lines;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lines,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == lines - 1 ? 0 : 10),
          child: _SkeletonLine(
            widthFactor: 0.9 - (index % 3) * 0.16,
            height: compact ? 9 : 11,
            color: index.isEven ? DashboardPalette.wire : DashboardPalette.line,
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    this.width,
    this.widthFactor,
    this.height = 11,
    this.color = DashboardPalette.wire,
  });

  final double? width;
  final double? widthFactor;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );

    if (widthFactor == null) {
      return line;
    }

    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: line,
    );
  }
}

class PlatformBadge extends StatelessWidget {
  const PlatformBadge({required this.label, required this.isWeb, super.key});

  final String label;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isWeb ? DashboardPalette.mint : DashboardPalette.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
