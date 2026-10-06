import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/demo/health_data.dart';
import '../../data/demo/services_data.dart';
import '../../data/demo/shop_data.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../explore/community/event_sheet.dart';
import '../explore/explore_modules.dart';

DateTime get flashSaleEnds {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, 23, 59, 59);
}

String greetingFor(AppLocalizations l, DateTime now) {
  final h = now.hour;
  if (h >= 5 && h < 12) return l.goodMorning;
  if (h >= 12 && h < 17) return l.goodAfternoon;
  if (h >= 17 && h < 21) return l.goodEvening;
  return l.goodNight;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final pad = context.pagePadding;
    final wide = context.screenWidth >= AppBreakpoints.largePhone;
    return Scaffold(
      body: AppRefresh(
        child: CustomScrollView(
          slivers: [
            const _HomeHeader(),
            SliverToBoxAdapter(
              child: MaxWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, Gap.lg, pad, 0),
                      child: wide
                          ? const IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: _WeatherCard()),
                                  SizedBox(width: Gap.md),
                                  Expanded(child: _PrayerCard()),
                                ],
                              ),
                            )
                          : const _WeatherCard(),
                    ),
                    const SizedBox(height: Gap.lg),
                    const _BannerCarousel(),
                    SectionHeader(l.emergency, icon: Icons.emergency_share_rounded),
                    const _EmergencyRow(),
                    SectionHeader(l.categories, onSeeAll: () => context.push('/categories')),
                    const _CategoryGrid(),
                    if (!wide) Padding(padding: EdgeInsets.fromLTRB(pad, Gap.lg, pad, 0), child: const _PrayerCard()),
                    SectionHeader(l.bazarToday, onSeeAll: () => context.push('/explore/bazar')),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: const BazarMiniTable(),
                    ),
                    const SizedBox(height: Gap.lg),
                    const _FlashSaleStrip(),
                    SectionHeader(
                      l.madeInTangail,
                      icon: Icons.verified_rounded,
                      onSeeAll: () => context.push('/shop/products?mit=1'),
                    ),
                    ProductCarousel(
                      heroScope: 'mit',
                      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 2),
                      products: products.where((p) => p.madeInTangail).take(8).toList(),
                    ),
                    SectionHeader(l.upcomingEvents, onSeeAll: () => context.push('/explore/community?tab=2')),
                    SizedBox(
                      height: context.scaled(232),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 2),
                        itemCount: localEvents.length,
                        separatorBuilder: (_, _) => const SizedBox(width: Gap.md),
                        itemBuilder: (_, i) => EventCard(event: localEvents[i]),
                      ),
                    ),
                    SectionHeader(l.latestNews, onSeeAll: () => context.push('/explore/news')),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: Column(
                        children: [
                          for (final n in newsArticles.take(3)) ...[
                            NewsTile(article: n),
                            const SizedBox(height: Gap.md),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 96), // room for the SOS button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Header

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final name = ref.watch(userNameProvider);
    final upazila = upazilaById(ref.watch(upazilaProvider));
    final unread = notificationsSeed.length - ref.watch(readNotificationsProvider).length;
    final searchH = context.scaled(50) + Gap.lg;
    final greetH = context.scaled(68);

    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: p.primary,
      foregroundColor: Colors.white,
      expandedHeight: kToolbarHeight + greetH + searchH,
      titleSpacing: context.pagePadding - 4,
      title: Row(
        children: [
          Flexible(
            child: Semantics(
              button: true,
              label: '${l.selectUpazila}: ${upazila.name.of(context)}',
              child: InkWell(
                borderRadius: Radii.chipBorder,
                onTap: () => showUpazilaSheet(context, ref),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: Radii.chipBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          upazila.name.of(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Gap.sm),
          const DemoBadge(onDark: true),
        ],
      ),
      actions: [
        IconButton(
          tooltip: l.notifications,
          onPressed: () => context.push('/notifications'),
          icon: CountBadge(
            count: unread,
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ),
        ),
        SizedBox(width: context.pagePadding - 8),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(searchH),
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.pagePadding, 0, context.pagePadding, Gap.lg),
          child: MaxWidth(
            child: SearchBarWidget(
              hint: l.searchHint,
              elevated: false,
              onTap: () => context.push('/search'),
              trailing: IconButton(
                tooltip: l.voiceHint,
                onPressed: () => context.push('/search?voice=1'),
                icon: Icon(Icons.mic_rounded, color: p.primary),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, c) {
          final top = MediaQuery.paddingOf(context).top;
          final minH = top + kToolbarHeight + searchH;
          final maxH = minH + greetH;
          final t = ((c.maxHeight - minH) / (maxH - minH)).clamp(0.0, 1.0);
          return Container(
            decoration: BoxDecoration(gradient: p.headerGradient),
            child: Stack(
              children: [
                Positioned(right: -30, top: -20, child: _blob(160)),
                Positioned(left: -40, bottom: -50, child: _blob(130)),
                Positioned(
                  left: context.pagePadding,
                  right: context.pagePadding,
                  top: top + kToolbarHeight,
                  height: greetH,
                  child: Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, -12 * (1 - t)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${greetingFor(l, DateTime.now())}, ${name.split(' ').first} 👋',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.headlineMedium?.copyWith(color: Colors.white),
                          ),
                          Text(
                            context.digits(
                              DateFormat('EEEE, d MMMM', context.isBn ? 'bn' : 'en').format(DateTime.now()),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _blob(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), shape: BoxShape.circle),
  );
}

Future<void> showUpazilaSheet(BuildContext context, WidgetRef ref) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Consumer(
      builder: (ctx, ref, _) {
        final selected = ref.watch(upazilaProvider);
        return RadioGroup<String>(
          groupValue: selected,
          onChanged: (v) {
            ref.read(upazilaProvider.notifier).set(v!);
            Navigator.pop(ctx);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetTitle(ctx.l10n.selectUpazila),
              for (final u in upazilas)
                RadioListTile<String>(
                  value: u.id,
                  contentPadding: EdgeInsets.zero,
                  title: Text(u.name.of(ctx)),
                  secondary: const Icon(Icons.location_on_outlined),
                ),
            ],
          ),
        );
      },
    ),
  );
}

// ---------------------------------------------------------------- Weather & prayer

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return AppCard(
      onTap: () => _showForecast(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Gap.sm),
            decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.wb_cloudy_rounded, color: Color(0xFFF0A202), size: 32),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(context.digits('31°'), style: context.text.headlineMedium),
                    const SizedBox(width: Gap.sm),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          context.isBn ? 'আংশিক মেঘলা' : 'Partly cloudy',
                          style: context.text.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${l.weatherTangail} · ${l.humidity(context.digits(78))} · ${l.feelsLike(context.digits(35))}',
                  style: context.text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.muted),
        ],
      ),
    );
  }

  void _showForecast(BuildContext context) {
    const days = [
      ('Tue', Icons.wb_sunny_rounded, 33, 26),
      ('Wed', Icons.wb_cloudy_rounded, 31, 25),
      ('Thu', Icons.thunderstorm_rounded, 28, 24),
      ('Fri', Icons.grain_rounded, 29, 24),
      ('Sat', Icons.wb_sunny_rounded, 32, 25),
    ];
    showAppSheet<void>(
      context,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(ctx.l10n.weatherTangail, subtitle: ctx.l10n.weatherForecast),
          for (final (d, icon, hi, lo) in days)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: const Color(0xFFF0A202)),
              title: Text(DateFormat('EEEE', ctx.isBn ? 'bn' : 'en').format(_nextWeekday(d))),
              trailing: Text(ctx.digits('$hi° / $lo°'), style: ctx.text.titleSmall),
            ),
        ],
      ),
    );
  }

  DateTime _nextWeekday(String d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final target = names.indexOf(d) + 1;
    var day = DateTime.now();
    while (day.weekday != target) {
      day = day.add(const Duration(days: 1));
    }
    return day;
  }
}

String prayerName(AppLocalizations l, String key) => switch (key) {
  'fajr' => l.fajr,
  'sunrise' => l.sunrise,
  'dhuhr' => l.dhuhr,
  'asr' => l.asr,
  'maghrib' => l.maghrib,
  _ => l.isha,
};

class _PrayerCard extends StatelessWidget {
  const _PrayerCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final next = nextPrayer(DateTime.now());
    return AppCard(
      onTap: () => context.push('/explore/prayer'),
      color: p.isDark ? null : const Color(0xFF0E5A45),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(Gap.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.nextPrayer, style: context.text.bodySmall?.copyWith(color: Colors.white70)),
                Text(
                  '${prayerName(l, next.key)} · ${context.clock(next.time)}',
                  style: context.text.titleMedium?.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CountdownBuilder(
            target: next.time,
            builder: (context, d) => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l.startsIn, style: context.text.labelSmall?.copyWith(color: Colors.white70)),
                Text(
                  formatRemaining(context, d),
                  style: context.text.titleSmall?.copyWith(
                    color: const Color(0xFFFFD58A),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Banner

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel();

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  PageController? _pc;
  double _fraction = 0;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      final pc = _pc;
      if (pc == null || !pc.hasClients) return;
      final next = (_index + 1) % homeBanners.length;
      pc.animateToPage(next, duration: Motion.slow, curve: Curves.easeOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final fraction = c.maxWidth >= AppBreakpoints.largePhone ? 0.5 : 0.9;
        if (fraction != _fraction) {
          _pc?.dispose();
          _pc = PageController(viewportFraction: fraction, initialPage: _index);
          _fraction = fraction;
        }
        final height = c.maxWidth * fraction / 2.1;
        return Column(
          children: [
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: _pc,
                padEnds: fraction > 0.6,
                itemCount: homeBanners.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _BannerCard(banner: homeBanners[i]),
                ),
              ),
            ),
            const SizedBox(height: Gap.md),
            PageDots(
              count: homeBanners.length,
              index: _index,
              activeColor: context.palette.primary,
              inactiveColor: context.palette.border,
            ),
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});
  final HomeBanner banner;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => context.push(banner.route),
      child: ClipRRect(
        borderRadius: Radii.cardBorder,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(banner.image),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xE60B6E4F), Color(0x330B6E4F)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Gap.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      banner.title.of(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: Gap.xs),
                  Flexible(
                    child: Text(
                      banner.subtitle.of(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ),
                  const SizedBox(height: Gap.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: Radii.chipBorder),
                    child: Text(
                      banner.cta.of(context),
                      style: context.text.labelMedium?.copyWith(
                        color: const Color(0xFF3B2410),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Emergency & categories

class _EmergencyRow extends StatelessWidget {
  const _EmergencyRow();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (l.nationalEmergency, '999', Icons.local_phone_rounded),
      (l.ambulance, ambulances.first.phone, Icons.emergency_rounded),
      (
        l.fireService,
        emergencyServices.firstWhere((e) => e.kind == ServiceKind.fire).phone,
        Icons.local_fire_department_rounded,
      ),
      (l.police, emergencyServices.first.phone, Icons.local_police_rounded),
      (l.nearestHospital, hospitals.first.phone, Icons.local_hospital_rounded),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Row(
        children: [
          for (final (label, number, icon) in items)
            Padding(
              padding: const EdgeInsets.only(right: Gap.sm),
              child: EmergencyChip(label: label, number: number, icon: icon),
            ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return LayoutBuilder(
      builder: (context, c) {
        final cols = AppBreakpoints.categoryColumns(c.maxWidth);
        final shown = exploreModules.take(cols * 2 - 1).toList();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding - 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisExtent: 52 + Gap.sm + Gap.sm + 36 * context.textScale.clamp(1.0, 1.6),
            crossAxisSpacing: Gap.xs,
            mainAxisSpacing: Gap.sm,
          ),
          itemCount: shown.length + 1,
          itemBuilder: (context, i) {
            if (i == shown.length) {
              return CategoryTile(
                icon: Icons.grid_view_rounded,
                label: l.allCategories,
                index: 7,
                onTap: () => context.push('/categories'),
              );
            }
            final m = shown[i];
            return CategoryTile(icon: m.icon, label: m.label(l), index: i, onTap: () => context.push(m.route));
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Bazar

class BazarMiniTable extends StatelessWidget {
  const BazarMiniTable({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.sm),
      onTap: () => context.push('/explore/bazar'),
      child: Column(
        children: [
          for (final (i, item) in bazarItems.take(count).indexed) ...[
            if (i > 0) Divider(color: context.palette.border),
            BazarRow(item: item),
          ],
        ],
      ),
    );
  }
}

class BazarRow extends StatelessWidget {
  const BazarRow({super.key, required this.item});
  final BazarItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.sm),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.of(context),
                  style: context.text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('/${item.unit.of(context)}', style: context.text.bodySmall),
              ],
            ),
          ),
          Text(context.taka(item.price), style: context.text.titleSmall),
          const SizedBox(width: Gap.md),
          ChangeIndicator(pct: item.changePct),
        ],
      ),
    );
  }
}

/// ▲ red when prices go up (bad for buyers), ▼ green when they fall.
class ChangeIndicator extends StatelessWidget {
  const ChangeIndicator({super.key, required this.pct});
  final double pct;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final up = pct > 0.05;
    final down = pct < -0.05;
    final color = up ? p.emergency : (down ? p.success : p.muted);
    final icon = up ? Icons.arrow_drop_up_rounded : (down ? Icons.arrow_drop_down_rounded : Icons.remove_rounded);
    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          Text(
            context.digits('${pct.abs().toStringAsFixed(1)}%'),
            style: context.text.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Flash sale

class _FlashSaleStrip extends StatelessWidget {
  const _FlashSaleStrip();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pad = context.pagePadding;
    final p = context.palette;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: pad),
      decoration: BoxDecoration(
        borderRadius: Radii.cardBorder,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.secondary.withValues(alpha: p.isDark ? 0.25 : 0.35),
            p.background,
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.xs, Gap.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded, color: Color(0xFFE76F00)),
                          Flexible(
                            child: Text(l.flashSale, style: context.text.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      // Countdown scales down rather than overflowing on narrow screens.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(l.endsIn, style: context.text.bodySmall),
                            const SizedBox(width: Gap.xs),
                            CountdownTimer(target: flashSaleEnds, compact: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: () => context.push('/shop/products?flash=1'), child: Text(l.seeAll)),
              ],
            ),
          ),
          ProductCarousel(
            heroScope: 'flash',
            padding: const EdgeInsets.fromLTRB(Gap.md, 2, Gap.md, Gap.md),
            products: [for (final id in flashSaleIds) productById(id)],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- News

class NewsTile extends StatelessWidget {
  const NewsTile({super.key, required this.article});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Gap.sm),
      onTap: () => context.push('/explore/news/${article.id}'),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Hero(
                tag: 'news-${article.id}',
                child: AppImage(article.image, radius: Radii.button),
              ),
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: Gap.xs),
                Row(
                  children: [
                    Pill(article.category, color: context.palette.info, dense: true),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Text(
                        context.digits('${article.hoursAgo}h · ${article.source}'),
                        style: context.text.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
