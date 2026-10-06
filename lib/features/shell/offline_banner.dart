import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/utils/context_ext.dart';

/// Shows an animated "you're offline" strip above the whole app when the
/// demo offline toggle is on (Profile → Settings → Simulate offline), and a
/// brief "back online" strip when it's turned off.
class OfflineBannerHost extends ConsumerStatefulWidget {
  const OfflineBannerHost({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<OfflineBannerHost> createState() => _OfflineBannerHostState();
}

class _OfflineBannerHostState extends ConsumerState<OfflineBannerHost> {
  bool _showBackOnline = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(offlineProvider, (prev, next) {
      if (prev == true && !next) {
        setState(() => _showBackOnline = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showBackOnline = false);
        });
      }
    });
    final offline = ref.watch(offlineProvider);
    final visible = offline || _showBackOnline;
    final mq = MediaQuery.of(context);
    final color = offline ? const Color(0xFF3A3F47) : const Color(0xFF2A9D8F);

    return Column(
      children: [
        AnimatedSize(
          duration: Motion.medium,
          curve: Curves.easeOut,
          child: visible
              ? Material(
                  color: color,
                  child: Padding(
                    padding: EdgeInsets.only(top: mq.padding.top),
                    child: Semantics(
                      liveRegion: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              offline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: Gap.sm),
                            Flexible(
                              child: Text(
                                offline ? context.l10n.offlineBanner : context.l10n.backOnline,
                                style: context.text.labelMedium?.copyWith(color: Colors.white),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          child: visible ? MediaQuery(data: mq.removePadding(removeTop: true), child: widget.child) : widget.child,
        ),
      ],
    );
  }
}
