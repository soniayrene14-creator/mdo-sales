import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/products/category_products_notifier.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_text_field.dart';
import 'components/products_card.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final int categoryId;
  final String? categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  final scrollController = ScrollController();
  final searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProductsNotifierProvider.notifier).getProducts(widget.categoryId);
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    searchFieldController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    final productsState = ref.read(categoryProductsNotifierProvider);

    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await ref
          .read(categoryProductsNotifierProvider.notifier)
          .getProducts(
            widget.categoryId,
            offset: productsState.products?.length,
            contains: searchFieldController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(categoryProductsNotifierProvider.select((s) => s.products));
    final isLoadingMore = ref.watch(categoryProductsNotifierProvider.select((s) => s.isLoadingMore));

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName ?? 'Produits')),
      body: Scrollbar(
        child: CustomScrollView(
          controller: scrollController,
          physics: (products?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
              collapsedHeight: 70,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                child: _SearchField(
                  controller: searchFieldController,
                  categoryId: widget.categoryId,
                ),
              ),
            ),
            SliverLayoutBuilder(
              builder: (context, _) {
                if (products == null) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: AppProgressIndicator(),
                  );
                }

                if (products.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: true,
                    child: AppEmptyState(subtitle: 'Aucun produit dans cette catégorie'),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 1 / 1.5,
                      crossAxisSpacing: AppSizes.padding / 2,
                      mainAxisSpacing: AppSizes.padding / 2,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, i) {
                      return _ProductCard(product: products[i]);
                    },
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: AppLoadingMoreIndicator(isLoading: isLoadingMore),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  final TextEditingController controller;
  final int categoryId;

  const _SearchField({required this.controller, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppTextField(
      controller: controller,
      hintText: 'Rechercher des produits...',
      type: AppTextFieldType.search,
      textInputAction: TextInputAction.search,
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        ref.read(categoryProductsNotifierProvider.notifier).getProducts(categoryId, contains: controller.text);
      },
      onTapClearButton: () {
        ref.read(categoryProductsNotifierProvider.notifier).getProducts(categoryId, contains: controller.text);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return ProductsCard(
      product: product,
      onTap: () => context.push('/products/product-detail/${product.id}'),
    );
  }
}
