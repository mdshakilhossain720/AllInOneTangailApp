import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../core/utils/context_ext.dart';
import '../core/utils/test_mode.dart';
import 'feedback.dart';

/// Network image with shimmer placeholder and a graceful fallback.
class AppImage extends StatelessWidget {
  const AppImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String url;
  final BoxFit fit;
  final double radius;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (UiTestMode.enabled) {
      return Container(width: width, height: height, color: context.palette.surfaceAlt);
    }
    final img = CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, _) => const ShimmerBox(),
      errorWidget: (_, _, _) => Container(
        color: context.palette.surfaceAlt,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_rounded, color: context.palette.muted),
      ),
    );
    final child = semanticLabel == null ? img : Semantics(label: semanticLabel, image: true, child: img);
    if (radius == 0) return child;
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

/// Circular avatar from a network image.
class AppAvatar extends StatelessWidget {
  const AppAvatar(this.url, {super.key, this.size = 48, this.heroTag});

  final String url;
  final double size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget child = ClipOval(
      child: AppImage(url, width: size, height: size),
    );
    if (heroTag != null) child = Hero(tag: heroTag!, child: child);
    return SizedBox.square(dimension: size, child: child);
  }
}
