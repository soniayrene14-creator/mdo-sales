import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/categories/categories_notifier.dart';
import '../../providers/main/main_notifier.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_text_field.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesNotifierProvider);
    final isAdmin = ref.watch(mainNotifierProvider.select((p) => p.user?.isAdmin ?? false));

    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(categoriesNotifierProvider.notifier).loadCategories(),
        child: categoriesState.isLoading && categoriesState.categories == null
            ? const Center(child: CircularProgressIndicator())
            : categoriesState.categories == null || categoriesState.categories!.isEmpty
            ? const Center(child: Text('Aucune catégorie trouvée'))
            : ListView.builder(
                padding: const EdgeInsets.all(AppSizes.padding),
                itemCount: categoriesState.categories!.length,
                itemBuilder: (context, index) {
                  final category = categoriesState.categories![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.padding),
                    child: ListTile(
                      title: Text(category.name),
                      subtitle: Text(category.description ?? ''),
                      onTap: () {
                        context.push('/products/category/${category.id}?name=${Uri.encodeComponent(category.name)}');
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${category.productCount} produits'),
                          if (isAdmin)
                            PopupMenuButton<_CategoryAction>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (action) {
                                if (action == _CategoryAction.edit) {
                                  _showCategoryFormDialog(context, category: category);
                                } else {
                                  _confirmDeleteCategory(context, category);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: _CategoryAction.edit, child: Text('Modifier')),
                                PopupMenuItem(value: _CategoryAction.delete, child: Text('Supprimer')),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showCategoryFormDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showCategoryFormDialog(BuildContext context, {CategoryEntity? category}) {
    final nameController = TextEditingController(text: category?.name);
    final descriptionController = TextEditingController(text: category?.description);
    final isEditing = category != null;

    AppDialog.show(
      title: isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: nameController,
            labelText: 'Nom',
            hintText: 'Nom de la catégorie',
          ),
          const SizedBox(height: AppSizes.padding),
          AppTextField(
            controller: descriptionController,
            labelText: 'Description',
            hintText: 'Description optionnelle',
          ),
        ],
      ),
      rightButtonText: 'Enregistrer',
      onTapRightButton: (context) async {
        final name = nameController.text.trim();
        if (name.isEmpty) return;

        final description = descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim();

        final notifier = ref.read(categoriesNotifierProvider.notifier);
        final res = isEditing
            ? await notifier.updateCategory(
                category.copyWith(name: name, description: description),
              )
            : await notifier.addCategory(name, description);

        if (res.isSuccess) {
          if (!context.mounted) return;
          Navigator.of(context).pop();
        } else {
          AppDialog.showError(error: res.error?.toString() ?? 'Échec de l\'enregistrement de la catégorie');
        }
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, CategoryEntity category) {
    AppDialog.show(
      title: 'Confirmer',
      text: 'Voulez-vous vraiment supprimer "${category.name}" ?',
      leftButtonText: 'Annuler',
      rightButtonText: 'Supprimer',
      rightButtonColor: Theme.of(context).colorScheme.errorContainer,
      rightButtonTextColor: Theme.of(context).colorScheme.error,
      onTapRightButton: (context) async {
        Navigator.of(context).pop();

        final res = await ref.read(categoriesNotifierProvider.notifier).deleteCategory(category.id);

        if (res.isFailure) {
          AppDialog.showError(error: res.error?.toString() ?? 'Échec de la suppression de la catégorie');
        }
      },
    );
  }
}

enum _CategoryAction { edit, delete }
