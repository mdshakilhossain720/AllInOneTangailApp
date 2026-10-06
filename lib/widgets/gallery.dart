import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';
import 'app_image.dart';

/// Swipeable gallery with dots and counter. Tapping opens a full-screen
/// zoomable viewer (pinch / double-tap) with a shared Hero.
class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key, required this.images, this.heroTag, this.aspectRatio = 1, this.radius = 0});

  final List<String> images;
  final String? heroTag;
  final double aspectRatio;
  final double radius;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _tag(int i) => i == 0 && widget.heroTag != null ? widget.heroTag! : '${widget.images[i]}#$i';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  PageRouteBuilder<void>(
                    opaque: false,
                    barrierColor: Colors.black,
                    pageBuilder: (_, _, _) => _FullScreenViewer(images: widget.images, initial: i, tagOf: _tag),
                    transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
                  ),
                ),
                child: Hero(
                  tag: _tag(i),
                  child: AppImage(widget.images[i], semanticLabel: 'Image ${i + 1} of ${widget.images.length}'),
                ),
              ),
            ),
            Positioned(
              right: Gap.md,
              bottom: Gap.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: Radii.chipBorder),
                child: Text(
                  context.digits('${_index + 1}/${widget.images.length}'),
                  style: context.text.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: Gap.md,
              child: PageDots(count: widget.images.length, index: _index, activeColor: p.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index, this.activeColor, this.inactiveColor});

  final int count;
  final int index;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: Motion.medium,
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 20 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == index
                  ? (activeColor ?? Colors.white)
                  : (inactiveColor ?? Colors.white.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _FullScreenViewer extends StatefulWidget {
  const _FullScreenViewer({required this.images, required this.initial, required this.tagOf});

  final List<String> images;
  final int initial;
  final String Function(int) tagOf;

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  late final _controller = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  final _zoom = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    _zoom.dispose();
    super.dispose();
  }

  void _doubleTap(TapDownDetails d) {
    if (_zoom.value.getMaxScaleOnAxis() > 1) {
      _zoom.value = Matrix4.identity();
    } else {
      final p = d.localPosition;
      _zoom.value = Matrix4.identity()
        ..translateByDouble(-p.dx * 1.5, -p.dy * 1.5, 0, 1)
        ..scaleByDouble(2.5, 2.5, 1, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() {
              _index = i;
              _zoom.value = Matrix4.identity();
            }),
            itemBuilder: (_, i) {
              TapDownDetails? last;
              return GestureDetector(
                onDoubleTapDown: (d) => last = d,
                onDoubleTap: () => last == null ? null : _doubleTap(last!),
                child: InteractiveViewer(
                  transformationController: i == _index ? _zoom : null,
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Hero(
                      tag: widget.tagOf(i),
                      child: AppImage(widget.images[i], fit: BoxFit.contain),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Gap.sm),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.close,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    context.digits('${_index + 1}/${widget.images.length}'),
                    style: context.text.titleSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: Gap.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
