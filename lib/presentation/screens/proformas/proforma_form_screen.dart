import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/ordered_product_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/products/products_notifier.dart';
import '../../providers/proformas/proforma_form_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';
import '../home/components/order_card.dart';
import '../products/components/products_card.dart';

class ProformaFormScreen extends ConsumerStatefulWidget {
  const ProformaFormScreen({super.key});

  @override
  ConsumerState<ProformaFormScreen> createState() => _ProformaFormScreenState();
}

class _ProformaFormScreenState extends ConsumerState<ProformaFormScreen> {
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsNotifierProvider.notifier).getAllProducts();
    });
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerPhoneController.dispose();
    searchFieldController.dispose();
    super.dispose();
  }

  Future<void> onSubmit() async {
    final res = await AppDialog.showProgress(() {
      return ref.read(proformaFormNotifierProvider.notifier).submit();
    });

    if (!mounted) return;

    if (res.isSuccess) {
      context.go('/account/proformas/proforma-detail/${res.data}');
    } else {
      AppSnackBar.showError(res.error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsCount = ref.watch(proformaFormNotifierProvider.select((s) => s.items.length));

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle proforma')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.padding),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: customerNameController,
                    labelText: 'Nom du client (Optionnel)',
                    hintText: 'ex. Jean Dupont',
                    onChanged: (v) => ref.read(proformaFormNotifierProvider.notifier).onChangedCustomerName(v),
                  ),
                  const SizedBox(height: AppSizes.padding),
                  AppTextField(
                    controller: customerPhoneController,
                    keyboardType: TextInputType.phone,
                    labelText: 'Téléphone du client (Optionnel)',
                    hintText: 'ex. 07 00 00 00 00',
                    onChanged: (v) => ref.read(proformaFormNotifierProvider.notifier).onChangedCustomerPhone(v),
                  ),
                  const SizedBox(height: AppSizes.padding * 1.5),
                  Text(
                    'Produits',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.padding / 2),
                  AppTextField(
                    controller: searchFieldController,
                    hintText: 'Rechercher des produits...',
                    type: AppTextFieldType.search,
                    textInputAction: TextInputAction.search,
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      ref.read(productsNotifierProvider.notifier).getAllProducts(contains: searchFieldController.text);
                    },
                    onTapClearButton: () {
                      ref.read(productsNotifierProvider.notifier).getAllProducts(contains: searchFieldController.text);
                    },
                  ),
                ],
              ),
            ),
          ),
          const _ProductGridSliver(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSizes.padding, AppSizes.padding * 1.5, AppSizes.padding, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Panier ($itemsCount)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.padding),
            sliver: const _CartListSliver(),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSizes.padding, 0, AppSizes.padding, AppSizes.padding),
            sliver: const SliverToBoxAdapter(child: _CartTotal()),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: AppButton(
          text: 'Créer la proforma',
          enabled: itemsCount > 0,
          onTap: onSubmit,
        ),
      ),
    );
  }
}

class _ProductGridSliver extends ConsumerWidget {
  const _ProductGridSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts = ref.watch(productsNotifierProvider.select((p) => p.allProducts));

    if (allProducts == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSizes.padding * 2),
          child: AppProgressIndicator(),
        ),
      );
    }

    if (allProducts.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: false,
        child: AppEmptyState(subtitle: 'Aucun produit disponible'),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 1 / 1.5,
          crossAxisSpacing: AppSizes.padding / 2,
          mainAxisSpacing: AppSizes.padding / 2,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _ProductPickerCard(product: allProducts[i]),
          childCount: allProducts.length,
        ),
      ),
    );
  }
}

class _ProductPickerCard extends ConsumerWidget {
  final ProductEntity product;

  const _ProductPickerCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProductsCard(
      product: product,
      onTap: () {
        final formState = ref.read(proformaFormNotifierProvider);
        int currentQty = formState.items.where((e) => e.productId == product.id).firstOrNull?.quantity ?? 0;

        AppDialog.show(
          title: 'Entrer la quantité',
          child: OrderCard(
            name: product.name,
            imageUrl: product.imageUrl,
            stock: product.stock,
            price: product.price,
            initialQuantity: currentQty,
            onChangedQuantity: (val) {
              currentQty = val;
            },
          ),
          rightButtonText: 'Ajouter au panier',
          leftButtonText: 'Annuler',
          onTapLeftButton: (context) {
            context.pop();
          },
          onTapRightButton: (context) {
            ref
                .read(proformaFormNotifierProvider.notifier)
                .onAddOrderedProduct(product, currentQty == 0 ? 1 : currentQty);
            context.pop();
          },
        );
      },
    );
  }
}

class _CartListSliver extends ConsumerWidget {
  const _CartListSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(proformaFormNotifierProvider.select((s) => s.items));

    if (items.isEmpty) {
      return const SliverToBoxAdapter(
        child: AppEmptyState(subtitle: 'Aucun produit ajouté au panier'),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : AppSizes.padding),
          child: _CartItem(item: items[i]),
        );
      }, childCount: items.length),
    );
  }
}

class _CartItem extends ConsumerWidget {
  final OrderedProductEntity item;

  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OrderCard(
      name: item.name,
      imageUrl: item.imageUrl,
      stock: item.stock,
      price: item.price,
      initialQuantity: item.quantity,
      onChangedQuantity: (val) {
        ref
            .read(proformaFormNotifierProvider.notifier)
            .onAddOrderedProduct(
              ProductEntity(
                id: item.productId,
                createdById: '',
                name: item.name,
                imageUrl: item.imageUrl,
                stock: item.stock,
                price: item.price,
              ),
              val,
            );
      },
      onTapRemove: () {
        ref.read(proformaFormNotifierProvider.notifier).onRemoveOrderedProduct(item);
      },
    );
  }
}

class _CartTotal extends ConsumerWidget {
  const _CartTotal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAmount = ref.watch(proformaFormNotifierProvider.notifier).getTotalAmount();

    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            CurrencyFormatter.format(totalAmount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
