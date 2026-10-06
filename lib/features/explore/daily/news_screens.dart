import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo/common_data.dart';
import '../../../widgets/widgets.dart';
import '../../home/home_screen.dart' show NewsTile;
import '../health/hospitals_screen.dart' show DetailHeader;
import '../module_scaffold.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cats = ['all', ...newsCategories];
    return DefaultTabController(
      length: cats.length,
      child: AppScaffold(
        title: l.news,
        bottom: TabBar(isScrollable: true, tabs: [for (final c in cats) Tab(text: c == 'all' ? l.all : c)]),
        body: TabBarView(
          children: [
            for (final c in cats)
              Builder(
                builder: (context) {
                  final items = newsArticles.where((n) => c == 'all' || n.category == c).toList();
                  return AppRefresh(
                    child: DemoLoader(
                      builder: (_) => ListView.separated(
                        padding: listPadding(context),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                        itemBuilder: (_, i) =>
                            i == 0 && c == 'all' ? _Featured(id: items[i].id) : NewsTile(article: items[i]),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Featured extends StatelessWidget {
  const _Featured({required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final n = newsArticles.firstWhere((x) => x.id == id);
    return PressableScale(
      onTap: () => context.push('/explore/news/${n.id}'),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.card)),
                child: Hero(tag: 'news-${n.id}', child: AppImage(n.image)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Gap.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Pill(n.category, color: context.palette.info, dense: true),
                  const SizedBox(height: Gap.xs),
                  Text(n.title, style: context.text.titleMedium),
                  const SizedBox(height: Gap.xs),
                  Text(n.summary, style: context.text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final n = newsArticles.firstWhere((x) => x.id == id);
    final p = context.palette;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailHeader(title: n.category, image: n.image, heroTag: 'news-${n.id}'),
          SliverToBoxAdapter(
            child: MaxWidth(
              maxWidth: 720,
              child: Padding(
                padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.lg, context.pagePadding, Gap.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pill(n.category, color: p.info),
                    const SizedBox(height: Gap.sm),
                    Text(n.title, style: context.text.headlineMedium),
                    const SizedBox(height: Gap.sm),
                    Row(
                      children: [
                        Icon(Icons.newspaper_rounded, size: 16, color: p.muted),
                        const SizedBox(width: Gap.xs),
                        Expanded(
                          child: Text(context.digits('${n.source} · ${n.hoursAgo}h'), style: context.text.bodySmall),
                        ),
                      ],
                    ),
                    const Divider(height: Gap.xxl),
                    Text(
                      n.summary,
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: p.muted),
                    ),
                    const SizedBox(height: Gap.lg),
                    Text(n.body, style: context.text.bodyLarge?.copyWith(height: 1.7)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
