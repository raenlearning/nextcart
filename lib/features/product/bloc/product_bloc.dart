
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/data/repository/product_repository.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({required this._productRepository})
      : super(ProductInitial()) {
    on<FetchPopularProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await _productRepository.getPopularProducts();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<FetchProductsByCategory>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await _productRepository.getProductsByCategory(event.categoryId);
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });

    on<SearchProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await _productRepository.searchProducts(event.query);
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    });
  }
}