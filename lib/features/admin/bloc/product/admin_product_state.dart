import 'package:nextcart/data/models/product_model.dart' show Product;

abstract class AdminProductState {}

class AdminProductInitial extends AdminProductState {}

class AdminProductLoading extends AdminProductState {}

class AdminProductLoaded extends AdminProductState {
  final List<Product> products;
  AdminProductLoaded(this.products);
}

class AdminProductActionSuccess extends AdminProductState {
  final String message;
  AdminProductActionSuccess(this.message);
}

class AdminProductError extends AdminProductState {
  final String message;
  AdminProductError(this.message);

  String? get error => null;
}
