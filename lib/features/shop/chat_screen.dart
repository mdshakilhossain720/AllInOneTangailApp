import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/shop_data.dart';
import '../../widgets/widgets.dart';

class _Msg {
  const _Msg(this.text, this.mine, this.time, {this.productId});
  final String text;
  final bool mine;
  final String time;
  final String? productId;
}

/// Chat with a seller: bubbles, product preview card, quick replies and a
/// simulated typing reply.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.storeId, this.productId});
  final String storeId;
  final String? productId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  late final List<_Msg> _messages = [
    const _Msg('Assalamu alaikum! How can we help you today? 😊', false, '10:02 AM'),
    if (widget.productId != null) _Msg('', true, '10:04 AM', productId: widget.productId),
    const _Msg('Is this available for delivery to Kalihati this week?', true, '10:04 AM'),
    const _Msg('Yes! Delivery to Kalihati takes 2 days. Cash on delivery is available too.', false, '10:06 AM'),
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Msg(text.trim(), true, 'now'));
      _typing = true;
    });
    _input.clear();
    _toBottom();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(const _Msg('Thank you! Our team will confirm shortly. (demo auto-reply)', false, 'now'));
      });
      _toBottom();
    });
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent + 80, duration: Motion.medium, curve: Curves.easeOut);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final store = storeById(widget.storeId);
    final quick = context.isBn
        ? ['এটি কি স্টকে আছে?', 'ডেলিভারি চার্জ কত?', 'ক্যাশ অন ডেলিভারি আছে?', 'দাম কমানো যাবে?']
        : ['Is this in stock?', 'Delivery charge?', 'Cash on delivery?', 'Any discount?'];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(store.logo, size: 38),
            const SizedBox(width: Gap.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: context.text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: p.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(l.online, style: context.text.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.call,
            onPressed: () => confirmCall(context, name: store.name, number: store.phone),
            icon: const Icon(Icons.call_outlined),
          ),
          IconButton(
            tooltip: l.visitStore,
            onPressed: () => context.push('/shop/store/${store.id}'),
            icon: const Icon(Icons.storefront_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: MaxWidth(
          maxWidth: 840,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(Gap.lg),
                  itemCount: _messages.length + (_typing ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length) return const _TypingBubble();
                    final m = _messages[i];
                    if (m.productId != null) return _ProductPreview(productId: m.productId!);
                    return _Bubble(msg: m);
                  },
                ),
              ),
              SizedBox(
                height: 48 * context.textScale.clamp(1.0, 1.5),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
                  itemCount: quick.length,
                  separatorBuilder: (_, _) => const SizedBox(width: Gap.sm),
                  itemBuilder: (_, i) => ActionChip(label: Text(quick[i]), onPressed: () => _send(quick[i])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.sm, Gap.sm, Gap.sm, Gap.sm),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l.addPhoto,
                      onPressed: () => context.toast(l.comingSoonDemo),
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _send,
                        decoration: InputDecoration(
                          hintText: l.typeMessage,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: p.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: p.border),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Gap.xs),
                    IconButton.filled(
                      tooltip: l.submit,
                      onPressed: () => _send(_input.text),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});
  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final mine = msg.mine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1),
        duration: Motion.medium,
        curve: Curves.easeOutBack,
        builder: (_, v, child) =>
            Transform.scale(scale: v, alignment: mine ? Alignment.bottomRight : Alignment.bottomLeft, child: child),
        child: Container(
          constraints: BoxConstraints(maxWidth: context.screenWidth * 0.75),
          margin: const EdgeInsets.only(bottom: Gap.sm),
          padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
          decoration: BoxDecoration(
            color: mine ? p.primary : p.surface,
            border: mine || !p.isDark ? null : Border.all(color: p.border),
            boxShadow: mine ? null : softShadow(p.isDark),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 4),
              bottomRight: Radius.circular(mine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(msg.text, style: context.text.bodyMedium?.copyWith(color: mine ? Colors.white : p.text)),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.digits(msg.time),
                    style: context.text.labelSmall?.copyWith(color: mine ? Colors.white70 : p.muted),
                  ),
                  if (mine) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all_rounded, size: 14, color: Colors.white70),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductPreview extends ConsumerWidget {
  const _ProductPreview({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pr = resolveProduct(ref, productId);
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.only(bottom: Gap.sm),
          child: AppCard(
            padding: const EdgeInsets.all(Gap.sm),
            onTap: () => context.push('/shop/product/${pr.id}'),
            child: Row(
              children: [
                SizedBox.square(dimension: 56, child: AppImage(pr.images.first, radius: 8)),
                const SizedBox(width: Gap.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pr.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.labelMedium),
                      PriceText(pr.price, size: PriceSize.small),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: Gap.sm),
        padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.md),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: softShadow(p.isDark),
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: p.muted.withValues(alpha: (((_c.value * 3 - i) % 3) < 1) ? 1 : 0.35),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
