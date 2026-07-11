import 'dart:io';

import '../../../domain/entities/category_entity.dart';

class ProductFormState {
  final File? imageFile;
  final String? imageUrl;
  final String? name;
  final int? price;
  final int? stock;
  final String? description;
  final int? categoryId;
  final List<CategoryEntity>? categories;
  final bool isLoaded;

  const ProductFormState({
    this.imageFile,
    this.imageUrl,
    this.name,
    this.price,
    this.stock,
    this.description,
    this.categoryId,
    this.categories,
    this.isLoaded = false,
  });

  ProductFormState copyWith({
    File? imageFile,
    String? imageUrl,
    String? name,
    int? price,
    int? stock,
    String? description,
    int? categoryId,
    List<CategoryEntity>? categories,
    bool? isLoaded,
  }) {
    return ProductFormState(
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categories: categories ?? this.categories,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
