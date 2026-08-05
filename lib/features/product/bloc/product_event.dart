
part of 'product_bloc.dart';
abstract class ProductEvent {}
class FetchPopularProducts extends ProductEvent {}

class FetchProductsByCategory extends ProductEvent {
  final String categoryId;
  FetchProductsByCategory(this.categoryId);
}

class SearchProducts extends ProductEvent {
  final String query;
  SearchProducts(this.query);
}

