import '../../../../data/models/product_model.dart';

abstract class AdminProductEvent {}

class FetchAdminProducts extends AdminProductEvent {}

class AddAdminProduct extends AdminProductEvent {
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final List<String> images;
  final bool isActive;

  AddAdminProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.images,
    required this.isActive,
  });
}

class EditAdminProduct extends AdminProductEvent {
  final Product product;
  EditAdminProduct(this.product);
}

class DeleteAdminProduct extends AdminProductEvent {
  final String id;
  DeleteAdminProduct(this.id);
}

class ResetAdminProductState extends AdminProductEvent {}