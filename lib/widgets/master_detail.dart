import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/responsive/responsive.dart';
import '../core/utils/context_ext.dart';

typedef SelectFn = void Function(String id);

/// List on the left and detail on the right on tablets (≥ 840 px available
/// width); on smaller screens selecting an item pushes the detail route.
class MasterDetail extends StatefulWidget {
  const MasterDetail({
    super.key,
    required this.list,
    required this.detail,
    required this.routeFor,
    this.initialId,
    this.listWidth = 400,
  });

  final Widget Function(BuildContext context, SelectFn select, String? selectedId) list;
  final Widget Function(BuildContext context, String id) detail;
  final String Function(String id) routeFor;
  final String? initialId;
  final double listWidth;

  @override
  State<MasterDetail> createState() => _MasterDetailState();
}

class _MasterDetailState extends State<MasterDetail> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialId;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= AppBreakpoints.tablet;
        if (!wide) {
          return widget.list(context, (id) => context.push(widget.routeFor(id)), null);
        }
        final id = _selected;
        return Row(
          children: [
            SizedBox(width: widget.listWidth, child: widget.list(context, (v) => setState(() => _selected = v), id)),
            VerticalDivider(width: 1, color: context.palette.border),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: id == null
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Icon(Icons.touch_app_rounded, size: 48, color: context.palette.border),
                      )
                    : KeyedSubtree(key: ValueKey(id), child: widget.detail(context, id)),
              ),
            ),
          ],
        );
      },
    );
  }
}
