import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/demo/services_data.dart';
import '../../widgets/widgets.dart';
import 'address_form.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final list = ref.watch(addressesProvider);
    final def = ref.watch(defaultAddressProvider);
    return AppScaffold(
      title: l.addresses,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddressForm(context, ref),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(l.addNewAddress),
      ),
      body: list.isEmpty
          ? EmptyState(icon: Icons.location_off_outlined, title: l.nothingHere)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.md, context.pagePadding, 100),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
              itemBuilder: (_, i) {
                final a = list[i];
                final isDefault = a.id == def;
                return AppCard(
                  border: isDefault ? Border.all(color: p.primary, width: 1.5) : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(a.label == 'Office' ? Icons.work_rounded : Icons.home_rounded, color: p.primary),
                          const SizedBox(width: Gap.sm),
                          Expanded(child: Text(a.label, style: context.text.titleSmall)),
                          if (isDefault)
                            Pill(l.defaultAddress, color: p.primary, icon: Icons.check_rounded, dense: true),
                        ],
                      ),
                      const SizedBox(height: Gap.sm),
                      Text('${a.name} · ${context.digits(a.phone)}', style: context.text.bodySmall),
                      Text('${a.line}, ${upazilaName(a.upazila).of(context)}'),
                      const SizedBox(height: Gap.sm),
                      Row(
                        children: [
                          if (!isDefault)
                            Flexible(
                              child: TextButton(
                                onPressed: () => ref.read(defaultAddressProvider.notifier).set(a.id),
                                child: Text(l.setDefault, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          const Spacer(),
                          IconButton(
                            tooltip: l.delete,
                            onPressed: isDefault
                                ? null
                                : () {
                                    ref.read(addressesProvider.notifier).set(list.where((x) => x.id != a.id).toList());
                                    context.toast(
                                      l.itemRemoved,
                                      actionLabel: l.undo,
                                      onAction: () => ref.read(addressesProvider.notifier).set(list),
                                    );
                                  },
                            icon: Icon(Icons.delete_outline_rounded, color: isDefault ? p.border : p.emergency),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        title: l.myListings,
        bottom: TabBar(
          tabAlignment: TabAlignment.fill,
          tabs: [
            Tab(text: l.businesses),
            Tab(text: l.lostFound),
          ],
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: EdgeInsets.all(context.pagePadding),
              children: [
                InfoCard(
                  leading: const PastelIcon(Icons.storefront_rounded, index: 1),
                  title: 'Rahim Tea Stall',
                  subtitle: 'Restaurant · Tangail Sadar',
                  chips: [StatusChip(l.pendingApproval, tone: StatusTone.warning, icon: Icons.hourglass_top_rounded)],
                ),
                const SizedBox(height: Gap.md),
                InfoCard(
                  onTap: () => context.push('/explore/business/bz9'),
                  leading: SizedBox.square(dimension: 48, child: AppImage(businesses[8].images.first, radius: 10)),
                  title: businesses[8].name,
                  subtitle: businesses[8].category,
                  chips: [
                    StatusChip(l.published, tone: StatusTone.success, icon: Icons.check_rounded),
                    RatingLabel(businesses[8].rating),
                  ],
                ),
                const SizedBox(height: Gap.lg),
                OutlinedButton.icon(
                  onPressed: () => context.push('/explore/business/add'),
                  icon: const Icon(Icons.add_business_rounded),
                  label: Text(l.addBusiness),
                ),
              ],
            ),
            ListView(
              padding: EdgeInsets.all(context.pagePadding),
              children: [
                InfoCard(
                  leading: SizedBox.square(dimension: 56, child: AppImage(lostFoundItems.first.image, radius: 10)),
                  title: lostFoundItems.first.title,
                  subtitle: lostFoundItems.first.location,
                  chips: [
                    Pill(l.lost, color: p.emergency, solid: true, dense: true),
                    StatusChip(l.published, tone: StatusTone.success),
                  ],
                  trailing: IconButton(
                    tooltip: l.edit,
                    onPressed: () => context.push('/explore/community/post'),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: Gap.lg),
                OutlinedButton.icon(
                  onPressed: () => context.push('/explore/community/post'),
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(l.postItem),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DonorProfileScreen extends ConsumerWidget {
  const DonorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final last = DateTime(2026, 7, 12);
    final next = last.add(const Duration(days: 120));
    final history = [
      (DateTime(2026, 7, 12), 'Tangail General Hospital'),
      (DateTime(2026, 2, 28), 'Kumudini Hospital'),
      (DateTime(2025, 10, 3), 'Sandhani, MBSTU unit'),
      (DateTime(2025, 5, 20), 'Nirapod Clinic'),
    ];
    return AppScaffold(
      title: l.donorProfile,
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          MaxWidth(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(Gap.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [p.emergency, const Color(0xFFB5179E)]),
                    borderRadius: Radii.cardBorder,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Text(
                          'O+',
                          style: context.text.headlineMedium?.copyWith(color: p.emergency, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: Gap.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(userNameProvider),
                              style: context.text.titleLarge?.copyWith(color: Colors.white),
                            ),
                            Text(
                              l.donations(context.digits(history.length)),
                              style: context.text.bodyMedium?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: Gap.xs),
                            Text(
                              l.nextEligible(context.shortDate(next)),
                              style: context.text.bodySmall?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.md),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(Icons.visibility_outlined, color: p.primary),
                        title: Text(l.donorVisible),
                        value: ref.watch(donorVisibleProvider),
                        onChanged: (v) => ref.read(donorVisibleProvider.notifier).set(v),
                      ),
                      Divider(height: 1, color: p.border),
                      ListTile(
                        leading: Icon(Icons.history_rounded, color: p.primary),
                        title: Text(l.lastDonationDate),
                        trailing: Text(context.shortDate(last), style: context.text.titleSmall),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.md),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.donationHistory, style: context.text.titleMedium),
                      const SizedBox(height: Gap.lg),
                      for (final (i, (date, place)) in history.indexed)
                        TimelineTile(
                          title: place,
                          time: context.shortDate(date),
                          isFirst: i == 0,
                          isLast: i == history.length - 1,
                          icon: Icons.favorite_rounded,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.md),
                PrimaryButton(
                  label: l.bloodDonors,
                  icon: Icons.bloodtype_rounded,
                  color: p.emergency,
                  onPressed: () => context.push('/explore/blood'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, this.item});
  final String? item;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _form = GlobalKey<FormState>();
  final Set<String> _issues = {};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final issues = context.isBn
        ? ['ভুল ফোন নম্বর', 'ভুল ঠিকানা', 'সময়সূচি পুরনো', 'স্থায়ীভাবে বন্ধ', 'ডুপ্লিকেট', 'অন্যান্য']
        : ['Wrong phone number', 'Wrong address', 'Outdated hours', 'Permanently closed', 'Duplicate', 'Other'];
    return AppScaffold(
      title: l.reportWrongInfo,
      bottomBar: PrimaryButton(
        label: l.submit,
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          if (_issues.isEmpty) {
            context.toast(l.whatsWrong);
            return;
          }
          context.toast(l.reportSent);
          context.pop();
        },
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            AppTextField(
              label: l.whichListing,
              initialValue: widget.item,
              prefixIcon: Icons.search_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            Text(l.whatsWrong, style: context.text.titleSmall),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                for (final i in issues)
                  FilterChip(
                    label: Text(i),
                    selected: _issues.contains(i),
                    onSelected: (v) => setState(() => v ? _issues.add(i) : _issues.remove(i)),
                  ),
              ],
            ),
            const SizedBox(height: Gap.lg),
            AppTextField(label: l.details, maxLines: 4),
            Text(l.addPhoto, style: context.text.titleSmall),
            const SizedBox(height: Gap.sm),
            const PhotoPickerGrid(max: 3, seed: 'report'),
          ],
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final faqs = context.isBn
        ? [
            (
              'অর্ডার কীভাবে ট্র্যাক করব?',
              'প্রোফাইল → আমার অর্ডার থেকে যেকোনো অর্ডারে ট্যাপ করুন। সেখানে ট্র্যাকিং টাইমলাইন দেখতে পাবেন।',
            ),
            (
              'ক্যাশ অন ডেলিভারি কি সব উপজেলায় আছে?',
              'হ্যাঁ, টাঙ্গাইলের ১২টি উপজেলাতেই ক্যাশ অন ডেলিভারি পাওয়া যায়।',
            ),
            ('কীভাবে বিক্রেতা হব?', 'প্রোফাইল → বিক্রেতা হোন থেকে ৩ ধাপের ফর্ম পূরণ করুন।'),
            (
              'SOS বাটন কীভাবে কাজ করে?',
              'ট্যাপ করলে জরুরি নম্বরগুলো দেখাবে। ২ সেকেন্ড চেপে ধরলে সরাসরি ৯৯৯-এ কল হবে (কাউন্টডাউনসহ)।',
            ),
          ]
        : [
            ('How do I track my order?', 'Go to Profile → My orders and tap any order to see its tracking timeline.'),
            ('Is cash on delivery available everywhere?', 'Yes, COD is available in all 12 upazilas of Tangail.'),
            ('How do I become a seller?', 'Go to Profile → Become a seller and complete the 3-step form.'),
            (
              'How does the SOS button work?',
              'Tap to see emergency numbers. Press and hold for 2 seconds to call 999 directly (with a countdown to cancel).',
            ),
          ];
    return AppScaffold(
      title: l.helpSupport,
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          MaxWidth(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.contactUs, style: context.text.titleMedium),
                const SizedBox(height: Gap.sm),
                Row(
                  children: [
                    for (final (icon, label, onTap) in [
                      (
                        Icons.call_rounded,
                        l.call,
                        () => confirmCall(context, name: l.helpSupport, number: '01700-000100'),
                      ),
                      (Icons.chat_rounded, l.liveChat, () => context.push('/shop/chat/s2')),
                      (Icons.email_rounded, l.email, () => context.toast('support@tangail.demo')),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
                          child: AppCard(
                            onTap: onTap,
                            padding: const EdgeInsets.symmetric(vertical: Gap.lg, horizontal: Gap.xs),
                            child: Column(
                              children: [
                                Icon(icon, color: p.primary),
                                const SizedBox(height: Gap.xs),
                                Text(
                                  label,
                                  style: context.text.labelMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.xl),
                Text(l.faq, style: context.text.titleMedium),
                const SizedBox(height: Gap.sm),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final (q, a) in faqs)
                        ExpansionTile(
                          shape: const Border(),
                          title: Text(q, style: context.text.titleSmall),
                          childrenPadding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
                          expandedAlignment: Alignment.centerLeft,
                          children: [Text(a, style: context.text.bodyMedium?.copyWith(color: p.muted))],
                        ),
                    ],
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

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return AppScaffold(
      title: l.aboutApp,
      body: ListView(
        padding: const EdgeInsets.all(Gap.xl),
        children: [
          MaxWidth(
            maxWidth: 560,
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(gradient: p.headerGradient, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 48),
                ),
                const SizedBox(height: Gap.lg),
                Text(l.appName, style: context.text.headlineSmall, textAlign: TextAlign.center),
                Text(l.version(context.digits('1.0.0 (demo)')), style: context.text.bodySmall),
                const SizedBox(height: Gap.sm),
                const DemoBadge(),
                const SizedBox(height: Gap.xl),
                Text(l.aboutBody, style: context.text.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: Gap.xl),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final (icon, label, onTap) in [
                        (Icons.description_outlined, l.terms, () => context.toast(l.comingSoonDemo)),
                        (Icons.privacy_tip_outlined, l.privacy, () => context.toast(l.comingSoonDemo)),
                        (
                          Icons.code_rounded,
                          l.licences,
                          () => showLicensePage(context: context, applicationName: l.appName),
                        ),
                      ])
                        ListTile(
                          leading: Icon(icon, color: p.primary),
                          title: Text(label),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: onTap,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Text(l.madeWithLove, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
