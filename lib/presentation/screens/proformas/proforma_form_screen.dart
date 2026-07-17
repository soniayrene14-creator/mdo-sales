import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/ordered_product_entity.dart';
import '../../providers/products/products_notifier.dart';
import '../../providers/proformas/proforma_form_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_text_field.dart';

class ProformaFormScreen extends ConsumerStatefulWidget {
  final int? id;

  const ProformaFormScreen({super.key, this.id});

  @override
  ConsumerState<ProformaFormScreen> createState() => _ProformaFormScreenState();
}

class _ProformaFormScreenState extends ConsumerState<ProformaFormScreen> {
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(proformaFormNotifierProvider.notifier).initProformaForm(widget.id);

      final state = ref.read(proformaFormNotifierProvider);
      customerNameController.text = state.customerName ?? '';
      customerPhoneController.text = state.customerPhone ?? '';
    });
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void addProduct() {
    final notifier = ref.read(proformaFormNotifierProvider.notifier);
    final selectedProductId = ref.read(proformaFormNotifierProvider).selectedProductId;
    final allProducts = ref.read(productsNotifierProvider).allProducts ?? [];
    final product = allProducts.where((p) => p.id == selectedProductId).firstOrNull;

    if (product == null) return;

    notifier.addSelectedProductToCart(product);
    quantityController.text = '1';
    FocusScope.of(context).unfocus();
  }

  void submitProforma() async {
    final router = ref.read(appRoutesProvider).router;
    final notifier = ref.read(proformaFormNotifierProvider.notifier);

    var res = await AppDialog.showProgress(() {
      return widget.id == null ? notifier.createProforma() : notifier.updateProforma(widget.id!);
    });

    if (res.isSuccess) {
      router.go('/account/proformas/proforma-detail/${res.data}');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(proformaFormNotifierProvider.notifier);

    final isLoaded = ref.watch(proformaFormNotifierProvider.select((s) => s.isLoaded));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Créer un proforma' : 'Modifier le proforma'),
        titleSpacing: 0,
      ),
      body: !isLoaded
          ? const AppProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameField(
                    controller: customerNameController,
                    onChanged: notifier.onChangedCustomerName,
                  ),
                  _PhoneField(
                    controller: customerPhoneController,
                    onChanged: notifier.onChangedCustomerPhone,
                  ),
                  const _ProductField(),
                  _QuantityField(controller: quantityController),
                  _AddProductButton(onTap: addProduct),
                  const _CartSection(),
                  _CreateButton(isEditing: widget.id != null, onTap: submitProforma),
                ],
              ),
            ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NameField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Nom du client (Optionnel)',
        hintText: 'Nom du client...',
        onChanged: onChanged,
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PhoneField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Téléphone du client (Optionnel)',
        hintText: 'Téléphone du client...',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
      ),
    );
  }
}

class _ProductField extends ConsumerWidget {
  const _ProductField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts = ref.watch(productsNotifierProvider.select((s) => s.allProducts)) ?? [];
    final selectedProductId = ref.watch(proformaFormNotifierProvider.select((s) => s.selectedProductId));

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppDropDown<int>(
        labelText: 'Produit',
        hintText: 'Sélectionner un produit',
        selectedValue: selectedProductId,
        dropdownItems: allProducts.map((product) {
          return DropdownMenuItem<int>(
            value: product.id,
            child: Text(
              '${product.name} — ${CurrencyFormatter.format(product.price)} (stock : ${product.stock})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value == null) return;
          ref.read(proformaFormNotifierProvider.notifier).onChangedSelectedProduct(value);
        },
      ),
    );
  }
}

class _QuantityField extends ConsumerWidget {
  final TextEditingController controller;

  const _QuantityField({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Quantité',
        hintText: 'Quantité...',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (v) {
          ref.read(proformaFormNotifierProvider.notifier).onChangedPickerQuantity(int.tryParse(v) ?? 1);
        },
      ),
    );
  }
}

class _AddProductButton extends ConsumerWidget {
  final VoidCallback onTap;

  const _AddProductButton({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProductId = ref.watch(proformaFormNotifierProvider.select((s) => s.selectedProductId));

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        text: 'Ajouter le produit',
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.primary,
        textColor: Theme.of(context).colorScheme.primary,
        enabled: selectedProductId != null,
        onTap: onTap,
      ),
    );
  }
}

class _CartSection extends ConsumerWidget {
  const _CartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(proformaFormNotifierProvider.select((s) => s.items));
    final totalAmount = ref.watch(proformaFormNotifierProvider.notifier).getTotalAmount();

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panier (${items.length})',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.padding / 2),
          if (items.isEmpty)
            Text('Aucun produit ajouté', style: Theme.of(context).textTheme.bodySmall)
          else
            for (final item in items) _CartItemRow(item: item),
          const SizedBox(height: AppSizes.padding / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                CurrencyFormatter.format(totalAmount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends ConsumerWidget {
  final OrderedProductEntity item;

  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.padding / 4),
      child: Row(
        children: [
          Expanded(
            child: Text('${item.name} x${item.quantity}', style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            CurrencyFormatter.format(item.price * item.quantity),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () => ref.read(proformaFormNotifierProvider.notifier).onRemoveOrderedProduct(item),
          ),
        ],
      ),
    );
  }
}

class _CreateButton extends ConsumerWidget {
  final bool isEditing;
  final VoidCallback onTap;

  const _CreateButton({required this.isEditing, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsCount = ref.watch(proformaFormNotifierProvider.select((s) => s.items.length));

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.padding * 1.5,
        bottom: AppSizes.padding * 2,
      ),
      child: AppButton(
        text: isEditing ? 'Mettre à jour le proforma' : 'Créer le proforma',
        enabled: itemsCount > 0,
        onTap: onTap,
      ),
    );
  }
}
