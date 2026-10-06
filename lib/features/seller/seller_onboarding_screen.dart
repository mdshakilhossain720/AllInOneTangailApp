import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/demo/shop_data.dart';
import '../../widgets/widgets.dart';

/// 3-step seller onboarding: store info → NID upload → payment account.
class SellerOnboardingScreen extends ConsumerStatefulWidget {
  const SellerOnboardingScreen({super.key});

  @override
  ConsumerState<SellerOnboardingScreen> createState() => _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState extends ConsumerState<SellerOnboardingScreen> {
  final _forms = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  int _step = 0;
  bool _nidFront = false;
  bool _nidBack = false;
  String _account = 'bKash';
  String _category = 'saree';
  String _upazila = upazilas.first.name.en;
  bool _done = false;

  void _next() {
    final l = context.l10n;
    if (!_forms[_step].currentState!.validate()) return;
    if (_step == 1 && (!_nidFront || !_nidBack)) {
      context.toast(l.required);
      return;
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      ref.read(isSellerProvider.notifier).set(true);
      setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    if (_done) {
      return AppScaffold(
        title: l.sellerOnbTitle,
        body: EmptyState(
          icon: Icons.storefront_rounded,
          color: p.success,
          title: l.sellerReady,
          message: context.isBn ? 'এখন আপনার প্রথম পণ্য যোগ করুন।' : 'Add your first product to start selling.',
          actionLabel: l.sellerCenter,
          onAction: () => context.pushReplacement('/seller'),
        ),
      );
    }
    final titles = [l.storeInfoStep, l.nidStep, l.payoutStep];
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.required : null;

    return AppScaffold(
      title: l.becomeSeller,
      bottomBar: Row(
        children: [
          if (_step > 0) ...[
            Expanded(
              child: OutlinedButton(onPressed: () => setState(() => _step--), child: Text(l.back)),
            ),
            const SizedBox(width: Gap.md),
          ],
          Expanded(
            flex: 2,
            child: FilledButton(onPressed: _next, child: Text(_step < 2 ? l.next : l.submit)),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(context.pagePadding),
        children: [
          // Progress indicator with step labels.
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: Gap.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: Motion.medium,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= _step ? p.primary : p.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        titles[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          color: i <= _step ? p.primary : p.muted,
                          fontWeight: i == _step ? FontWeight.w700 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Gap.xl),
          Text(titles[_step], style: context.text.headlineSmall),
          const SizedBox(height: Gap.lg),
          IndexedStack(
            index: _step,
            children: [
              Form(
                key: _forms[0],
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: p.primarySoft,
                            child: Icon(Icons.storefront_rounded, size: 40, color: p.primary),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: p.primary,
                              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Gap.lg),
                    AppTextField(
                      label: l.storeName,
                      prefixIcon: Icons.store_outlined,
                      validator: req,
                      initialValue: 'Rahim Tant Bitan',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gap.lg),
                      child: DropdownButtonFormField<String>(
                        initialValue: _category,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l.category,
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: [
                          for (final c in shopCategories)
                            DropdownMenuItem(value: c.id, child: Text(categoryLabel(l, c.id))),
                        ],
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: Gap.lg),
                      child: DropdownButtonFormField<String>(
                        initialValue: _upazila,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l.upazila,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        items: [
                          for (final u in upazilas) DropdownMenuItem(value: u.name.en, child: Text(u.name.of(context))),
                        ],
                        onChanged: (v) => setState(() => _upazila = v!),
                      ),
                    ),
                    AppTextField(label: l.storeDescription, maxLines: 3),
                  ],
                ),
              ),
              Form(
                key: _forms[1],
                child: Column(
                  children: [
                    _UploadTile(label: l.nidFront, done: _nidFront, onTap: () => setState(() => _nidFront = true)),
                    const SizedBox(height: Gap.md),
                    _UploadTile(label: l.nidBack, done: _nidBack, onTap: () => setState(() => _nidBack = true)),
                    const SizedBox(height: Gap.lg),
                    AppTextField(
                      label: l.nidNumber,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.badge_outlined,
                      validator: req,
                    ),
                  ],
                ),
              ),
              Form(
                key: _forms[2],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.accountType, style: context.text.labelLarge),
                    const SizedBox(height: Gap.sm),
                    Wrap(
                      spacing: Gap.sm,
                      runSpacing: Gap.sm,
                      children: [
                        for (final (name, color) in [
                          ('bKash', AppColors.bkash),
                          ('Nagad', AppColors.nagad),
                          ('Rocket', AppColors.rocket),
                          ('Bank', AppColors.info),
                        ])
                          ChoiceChip(
                            label: Text(name),
                            selected: _account == name,
                            selectedColor: color,
                            labelStyle: TextStyle(color: _account == name ? Colors.white : null),
                            onSelected: (_) => setState(() => _account = name),
                          ),
                      ],
                    ),
                    const SizedBox(height: Gap.lg),
                    AppTextField(
                      label: l.accountNumber,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.account_balance_wallet_outlined,
                      validator: req,
                    ),
                    AppTextField(
                      label: l.fullName,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: req,
                      initialValue: 'Rahim Uddin',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.label, required this.done, required this.onTap});
  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: Radii.cardBorder,
        child: AspectRatio(
          aspectRatio: 1.9,
          child: AnimatedContainer(
            duration: Motion.medium,
            decoration: BoxDecoration(
              color: done ? p.primarySoft : p.surfaceAlt,
              borderRadius: Radii.cardBorder,
              border: Border.all(color: done ? p.primary : p.border, width: 1.5),
            ),
            child: done
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Gap.md),
                        child: AppImage('https://picsum.photos/seed/${label.hashCode}/600/320', radius: 10),
                      ),
                      Positioned(
                        right: Gap.lg,
                        top: Gap.lg,
                        child: Pill(context.l10n.uploaded, color: p.success, icon: Icons.check_rounded, solid: true),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.badge_outlined, size: 36, color: p.muted),
                      const SizedBox(height: Gap.sm),
                      Text(label, style: context.text.titleSmall),
                      Text(context.l10n.tapToUpload, style: context.text.bodySmall),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
