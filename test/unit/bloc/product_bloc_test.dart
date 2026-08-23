import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/data/repository/product_repository.dart';
import 'package:nextcart/features/product/bloc/product_bloc.dart';

class MockProductRepository extends Mock implements ProductRepository {}

Product buildProduct(String id) => Product(
      id: id,
      name: 'Produk $id',
      description: 'desc',
      price: 100000,
      stock: 10,
      categoryId: 'c1',
      images: const [],
      sellerId: 's1',
      isActive: true,
    );

void main() {
  late MockProductRepository repository;

  setUp(() {
    repository = MockProductRepository();
  });

  group('ProductBloc', () {
    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] on FetchPopularProducts',
      build: () => ProductBloc(productRepository: repository),
      act: (bloc) => bloc.add(FetchPopularProducts()),
      setUp: () {
        when(() => repository.getPopularProducts())
            .thenAnswer((_) async => [buildProduct('p1')]);
      },
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductLoaded>().having(
          (s) => s.products,
          'products',
          hasLength(1),
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when fetch popular fails',
      build: () => ProductBloc(productRepository: repository),
      act: (bloc) => bloc.add(FetchPopularProducts()),
      setUp: () {
        when(() => repository.getPopularProducts())
            .thenThrow(Exception('network'));
      },
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductError>(),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits loaded products for category fetch',
      build: () => ProductBloc(productRepository: repository),
      act: (bloc) => bloc.add(FetchProductsByCategory('c1')),
      setUp: () {
        when(() => repository.getProductsByCategory('c1'))
            .thenAnswer((_) async => [buildProduct('p1')]);
      },
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductLoaded>(),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits loaded products for search',
      build: () => ProductBloc(productRepository: repository),
      act: (bloc) => bloc.add(SearchProducts('samsung')),
      setUp: () {
        when(() => repository.searchProducts('samsung'))
            .thenAnswer((_) async => [buildProduct('p1')]);
      },
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductLoaded>(),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits error when search fails',
      build: () => ProductBloc(productRepository: repository),
      act: (bloc) => bloc.add(SearchProducts('samsung')),
      setUp: () {
        when(() => repository.searchProducts('samsung'))
            .thenThrow(Exception('network'));
      },
      expect: () => [
        isA<ProductLoading>(),
        isA<ProductError>(),
      ],
    );
  });
}