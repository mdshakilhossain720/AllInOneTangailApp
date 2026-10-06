import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/state/providers.dart';
import '../../data/demo/common_data.dart';
import '../../data/models.dart';
import '../../widgets/widgets.dart';

/// Bottom-sheet form to add an address. Returns the saved address.
Future<Address?> showAddressForm(BuildContext context, WidgetRef ref) {
  return showAppSheet<Address>(context, builder: (_) => const _AddressForm());
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm();

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _form = GlobalKey<FormState>();
  String _label = 'Home';
  String _upazila = upazilas.first.name.en;
  final _name = TextEditingController(text: 'Rahim Uddin');
  final _phone = TextEditingController(text: '01700000001');
  final _line = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String? req(String? v) => (v == null || v.trim().isEmpty) ? l.required : null;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetTitle(l.addNewAddress),
          Text(l.label, style: context.text.labelLarge),
          const SizedBox(height: Gap.sm),
          Wrap(
            spacing: Gap.sm,
            children: [
              for (final (v, icon) in [
                ('Home', Icons.home_rounded),
                ('Office', Icons.work_rounded),
                ('Other', Icons.place_rounded),
              ])
                ChoiceChip(
                  avatar: Icon(icon, size: 16),
                  label: Text(v),
                  selected: _label == v,
                  onSelected: (_) => setState(() => _label = v),
                ),
            ],
          ),
          const SizedBox(height: Gap.lg),
          AppTextField(label: l.fullName, controller: _name, prefixIcon: Icons.person_outline_rounded, validator: req),
          AppTextField(
            label: l.mobileNumber,
            controller: _phone,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
            validator: (v) => (v == null || !RegExp(r'^01[3-9]\d{8}$').hasMatch(v)) ? l.invalidPhone : null,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.lg),
            child: DropdownButtonFormField<String>(
              initialValue: _upazila,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.upazila, prefixIcon: const Icon(Icons.map_outlined)),
              items: [for (final u in upazilas) DropdownMenuItem(value: u.name.en, child: Text(u.name.of(context)))],
              onChanged: (v) => setState(() => _upazila = v!),
            ),
          ),
          AppTextField(
            label: l.addressLine,
            controller: _line,
            maxLines: 2,
            prefixIcon: Icons.home_work_outlined,
            validator: req,
          ),
          PrimaryButton(
            label: l.save,
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              final a = Address(
                id: 'ad${DateTime.now().millisecondsSinceEpoch}',
                label: _label,
                name: _name.text.trim(),
                phone: _phone.text.trim(),
                line: _line.text.trim(),
                upazila: _upazila,
              );
              ref.read(addressesProvider.notifier).set([...ref.read(addressesProvider), a]);
              Navigator.pop(context, a);
              context.toast(l.addressSaved);
            },
          ),
        ],
      ),
    );
  }
}
