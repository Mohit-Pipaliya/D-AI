import 'dart:ui';

import 'package:flutter/material.dart';

/// Glassmorphism design-system helpers.
///
/// Provides frosted-glass blur, gradient overlays, and subtle
/// border utilities used throughout the UI.
abstract final class Glassmorphism {
  /// Standard corner radius for glass surfaces.
  static final BorderRadius defaultRadius = BorderRadius.circular(20);

  /// Creates a BoxDecoration for glassmorphic cards and tiles.
  static BoxDecoration cardDecoration(
    BuildContext context, {
    Color? tintColor,
    double opacity = 0.12,
    BorderRadius? borderRadius,
  }) {
    final brightness = Theme.of(context).brightness;
    final radius = borderRadius ?? defaultRadius;
    final baseColor = tintColor ??
        (brightness == Brightness.light ? Colors.black : Colors.white);

    return BoxDecoration(
      color: baseColor.withValues(alpha: opacity),
      borderRadius: radius,
      border: Border.all(
        color: borderSide(brightness).color,
        width: 1,
      ),
    );
  }

  /// Creates a subtle glass border for the given [brightness].
  static BorderSide borderSide(Brightness brightness) {
    final color = brightness == Brightness.light
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.12);
    return BorderSide(color: color, width: 1);
  }

  /// Linear gradient overlay applied on top of the blur layer.
  static LinearGradient tintGradient({
    required Brightness brightness,
    double opacity = 0.15,
  }) {
    final base = brightness == Brightness.light ? Colors.white : Colors.white;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        base.withValues(alpha: opacity),
        base.withValues(alpha: opacity * 0.4),
      ],
    );
  }

  /// Wraps [child] in a frosted-glass container.
  ///
  /// Applies a [BackdropFilter] with Gaussian blur, a tinted gradient,
  /// and a subtle glass border.
  static Widget glassContainer({
    required Widget child,
    required Brightness brightness,
    double blurSigma = 24,
    double tintOpacity = 0.15,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    final radius = borderRadius ?? defaultRadius;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: tintGradient(
              brightness: brightness,
              opacity: tintOpacity,
            ),
            borderRadius: radius,
            border: Border.all(
              color: borderSide(brightness).color,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Theme extension carrying glassmorphism design tokens.
///
/// Access via `Theme.of(context).extension<GlassmorphismTheme>()`.
@immutable
class GlassmorphismTheme extends ThemeExtension<GlassmorphismTheme> {
  /// Creates a [GlassmorphismTheme] token set.
  const GlassmorphismTheme({
    required this.blurSigma,
    required this.tintOpacity,
    required this.borderOpacity,
    required this.brightness,
  });

  /// Gaussian blur sigma for frosted glass.
  final double blurSigma;

  /// Opacity of the tint gradient overlay.
  final double tintOpacity;

  /// Opacity of the glass border.
  final double borderOpacity;

  /// Current brightness context.
  final Brightness brightness;

  @override
  GlassmorphismTheme copyWith({
    double? blurSigma,
    double? tintOpacity,
    double? borderOpacity,
    Brightness? brightness,
  }) {
    return GlassmorphismTheme(
      blurSigma: blurSigma ?? this.blurSigma,
      tintOpacity: tintOpacity ?? this.tintOpacity,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  GlassmorphismTheme lerp(
    covariant GlassmorphismTheme? other,
    double t,
  ) {
    if (other == null) return this;
    return GlassmorphismTheme(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
      tintOpacity: lerpDouble(tintOpacity, other.tintOpacity, t) ?? tintOpacity,
      borderOpacity:
          lerpDouble(borderOpacity, other.borderOpacity, t) ?? borderOpacity,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}
