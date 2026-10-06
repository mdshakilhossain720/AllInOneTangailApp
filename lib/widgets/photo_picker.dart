import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../core/utils/context_ext.dart';
import 'app_image.dart';
import 'badges.dart';

/// UI-only photo picker: tapping a slot "adds" a demo photo.
class PhotoPickerGrid extends StatefulWidget {
  const PhotoPickerGrid({super.key, this.max = 6, this.initial = 0, this.seed = 'upload'});
  final int max;
  final int initial;
  final String seed;

  @override
  State<PhotoPickerGrid> createState() => _PhotoPickerGridState();
}

class _PhotoPickerGridState extends State<PhotoPickerGrid> {
  late int _count = widget.initial;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, c) {
        const cols = 3;
        final size = (c.maxWidth - (cols - 1) * Gap.sm) / cols;
        return Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (var i = 0; i < _count; i++)
              SizedBox.square(
                dimension: size,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage('https://picsum.photos/seed/${widget.seed}$i/300/300', radius: Radii.button),
                    if (i == 0)
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: Pill(context.isBn ? 'কভার' : 'Cover', color: Colors.black87, solid: true, dense: true),
                      ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        tooltip: context.l10n.delete,
                        onPressed: () => setState(() => _count--),
                        icon: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_count < widget.max)
              Semantics(
                button: true,
                label: context.l10n.addPhotos,
                child: InkWell(
                  borderRadius: Radii.buttonBorder,
                  onTap: () => setState(() => _count++),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: p.surfaceAlt,
                      borderRadius: Radii.buttonBorder,
                      border: Border.all(color: p.border, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, color: p.muted),
                        const SizedBox(height: 4),
                        Text(context.digits('$_count/${widget.max}'), style: context.text.labelSmall),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
