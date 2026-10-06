import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/demo/common_data.dart';
import '../../../data/demo/health_data.dart';
import '../../../widgets/widgets.dart';
import '../module_scaffold.dart';

class BloodDonorsScreen extends StatefulWidget {
  const BloodDonorsScreen({super.key});

  @override
  State<BloodDonorsScreen> createState() => _BloodDonorsScreenState();
}

class _BloodDonorsScreenState extends State<BloodDonorsScreen> {
  String _group = 'all';
  bool _availableOnly = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final items = bloodDonors
        .where((d) => (_group == 'all' || d.group == _group) && (!_availableOnly || d.available))
        .toList();
    return ModuleScaffold(
      title: l.bloodDonors,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'blood-request',
        backgroundColor: p.emergency,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/explore/blood/request'),
        icon: const Icon(Icons.bloodtype_rounded),
        label: Text(l.requestBlood),
      ),
      header: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(context.pagePadding, Gap.sm, context.pagePadding, Gap.sm),
            child: AppCard(
              color: p.emergencySoft,
              border: Border.all(color: p.emergency.withValues(alpha: 0.35)),
              padding: const EdgeInsets.all(Gap.md),
              onTap: () => context.push('/explore/blood/register'),
              child: Row(
                children: [
                  Icon(Icons.volunteer_activism_rounded, color: p.emergency, size: 32),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.registerDonor, style: context.text.titleSmall),
                        Text(
                          context.isBn
                              ? 'একজন রক্তদাতা তিনটি জীবন বাঁচাতে পারে'
                              : 'One donation can save up to three lives',
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: p.emergency),
                ],
              ),
            ),
          ),
          FilterChipBar(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            options: ['all', ...bloodGroups],
            selected: _group,
            color: p.emergency,
            labelOf: (o) => o == 'all' ? l.all : o,
            onSelected: (v) => setState(() => _group = v),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding - 8),
            child: SwitchListTile(
              dense: true,
              title: Text(l.availableToDonate, style: context.text.labelLarge),
              value: _availableOnly,
              onChanged: (v) => setState(() => _availableOnly = v),
            ),
          ),
        ],
      ),
      list: (_) => items.isEmpty
          ? EmptyState(
              icon: Icons.bloodtype_outlined,
              color: p.emergency,
              title: l.noResults,
              message: l.noResultsHint,
              actionLabel: l.requestBlood,
              onAction: () => context.push('/explore/blood/request'),
            )
          : ListView.separated(
              padding: listPadding(context),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
              itemBuilder: (_, i) {
                final d = items[i];
                final ago = DateTime.now().difference(d.lastDonated).inDays;
                return InfoCard(
                  leading: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: p.emergency, borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      d.group,
                      style: context.text.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                  title: d.name,
                  meta: [
                    (Icons.location_on_outlined, upazilaName(d.upazila).of(context)),
                    (Icons.history_rounded, l.lastDonated(l.daysShort(context.digits(ago)))),
                  ],
                  chips: [
                    d.available
                        ? Pill(l.available, color: p.success, icon: Icons.check_circle_rounded, dense: true)
                        : Pill(l.unavailable, color: p.muted, dense: true),
                    Pill(
                      l.donations(context.digits(d.donations)),
                      color: p.emergency,
                      icon: Icons.favorite_rounded,
                      dense: true,
                    ),
                  ],
                  trailing: CallButton(name: d.name, number: d.phone, color: d.available ? p.success : p.muted),
                );
              },
            ),
    );
  }
}

/// Blood group picker as a wrap of selectable tiles.
class BloodGroupPicker extends StatelessWidget {
  const BloodGroupPicker({super.key, required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Wrap(
      spacing: Gap.sm,
      runSpacing: Gap.sm,
      children: [
        for (final g in bloodGroups)
          Semantics(
            selected: g == value,
            button: true,
            label: g,
            child: InkWell(
              borderRadius: Radii.buttonBorder,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(g);
              },
              child: AnimatedContainer(
                duration: Motion.fast,
                width: 64,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: g == value ? p.emergency : p.surface,
                  borderRadius: Radii.buttonBorder,
                  border: Border.all(color: g == value ? p.emergency : p.border),
                ),
                child: Text(g, style: context.text.titleMedium?.copyWith(color: g == value ? Colors.white : p.text)),
              ),
            ),
          ),
      ],
    );
  }
}

class RegisterDonorScreen extends StatefulWidget {
  const RegisterDonorScreen({super.key});

  @override
  State<RegisterDonorScreen> createState() => _RegisterDonorScreenState();
}

class _RegisterDonorScreenState extends State<RegisterDonorScreen> {
  final _form = GlobalKey<FormState>();
  String _group = 'O+';
  String _upazila = upazilas.first.name.en;
  DateTime? _last;
  bool _available = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.required : null;
    return AppScaffold(
      title: l.registerDonor,
      bottomBar: PrimaryButton(
        label: l.submit,
        color: context.palette.emergency,
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          context.toast(l.donorRegistered);
          context.pop();
        },
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            AppTextField(label: l.fullName, prefixIcon: Icons.person_outline_rounded, validator: req),
            AppTextField(
              label: l.mobileNumber,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              validator: (v) => (v == null || !RegExp(r'^01[3-9]\d{8}$').hasMatch(v)) ? l.invalidPhone : null,
            ),
            Text(l.bloodGroup, style: context.text.titleSmall),
            const SizedBox(height: Gap.sm),
            BloodGroupPicker(value: _group, onChanged: (g) => setState(() => _group = g)),
            const SizedBox(height: Gap.lg),
            DropdownButtonFormField<String>(
              initialValue: _upazila,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.upazila, prefixIcon: const Icon(Icons.location_on_outlined)),
              items: [for (final u in upazilas) DropdownMenuItem(value: u.name.en, child: Text(u.name.of(context)))],
              onChanged: (v) => setState(() => _upazila = v!),
            ),
            const SizedBox(height: Gap.lg),
            PickerField(
              label: l.lastDonationDate,
              icon: Icons.event_outlined,
              value: _last == null ? null : context.shortDate(_last!),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                );
                if (d != null) setState(() => _last = d);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.availableToDonate),
              value: _available,
              onChanged: (v) => setState(() => _available = v),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestBloodScreen extends StatefulWidget {
  const RequestBloodScreen({super.key});

  @override
  State<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends State<RequestBloodScreen> {
  final _form = GlobalKey<FormState>();
  String _group = 'O-';
  int _bags = 1;
  bool _urgent = true;
  DateTime _needed = DateTime.now().add(const Duration(hours: 6));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.required : null;
    return AppScaffold(
      title: l.requestBlood,
      bottomBar: PrimaryButton(
        label: l.submit,
        icon: Icons.send_rounded,
        color: p.emergency,
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          final matches = bloodDonors.where((d) => d.group == _group && d.available).length;
          context.toast('${l.bloodRequestSent} · ${context.digits(matches)}');
          context.pop();
        },
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: EdgeInsets.all(context.pagePadding),
          children: [
            Text(l.bloodGroup, style: context.text.titleSmall),
            const SizedBox(height: Gap.sm),
            BloodGroupPicker(value: _group, onChanged: (g) => setState(() => _group = g)),
            const SizedBox(height: Gap.lg),
            Row(
              children: [
                Expanded(child: Text(l.bagsNeeded, style: context.text.titleSmall)),
                QuantityStepper(value: _bags, max: 6, onChanged: (v) => setState(() => _bags = v)),
              ],
            ),
            const SizedBox(height: Gap.lg),
            Autocomplete<String>(
              optionsBuilder: (v) =>
                  hospitals.map((h) => h.name).where((n) => n.toLowerCase().contains(v.text.toLowerCase())),
              fieldViewBuilder: (context, controller, focus, onSubmit) => AppTextField(
                label: l.hospitalName,
                controller: controller,
                prefixIcon: Icons.local_hospital_outlined,
                validator: req,
              ),
            ),
            AppTextField(label: l.patientProblem, maxLines: 2, prefixIcon: Icons.healing_outlined),
            PickerField(
              label: l.neededBy,
              icon: Icons.schedule_rounded,
              value: '${context.shortDate(_needed)} · ${context.clock(_needed)}',
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDate: _needed,
                );
                if (d == null || !context.mounted) return;
                final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_needed));
                setState(() => _needed = DateTime(d.year, d.month, d.day, t?.hour ?? 9, t?.minute ?? 0));
              },
            ),
            AppTextField(
              label: l.mobileNumber,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              initialValue: '01700000001',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              validator: req,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(Icons.priority_high_rounded, color: p.emergency),
              title: Text(l.urgent),
              value: _urgent,
              onChanged: (v) => setState(() => _urgent = v),
            ),
            const SizedBox(height: Gap.sm),
            AppCard(
              color: p.surfaceAlt,
              child: Row(
                children: [
                  Icon(Icons.groups_rounded, color: p.emergency),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      context.isBn
                          ? '$_group গ্রুপের ${context.digits(bloodDonors.where((d) => d.group == _group && d.available).length)} জন রক্তদাতা কাছাকাছি আছেন'
                          : '${bloodDonors.where((d) => d.group == _group && d.available).length} available $_group donors nearby',
                      style: context.text.bodyMedium,
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
