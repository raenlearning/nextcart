import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextcart/data/repository/wishlist_repository.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';

class MockWishlistRepository extends Mock implements WishlistRepository {}

void main() {
  late MockWishlistRepository repository;

  setUp(() {
    repository = MockWishlistRepository();
  });

  group('WishlistBloc', () {
    blocTest<WishlistBloc, WishlistState>(
      'emits [WishlistLoading, WishlistLoaded] on load',
      build: () => WishlistBloc(repository: repository),
      act: (bloc) => bloc.add(WishlistLoad()),
      setUp: () {
        when(() => repository.fetchWishlistedProductIds())
            .thenAnswer((_) async => {'p1', 'p2'});
      },
      expect: () => [
        isA<WishlistLoaded>().having((s) => s.isLoading, 'isLoading', true),
        isA<WishlistLoaded>().having(
          (s) => s.productIds,
          'productIds',
          {'p1', 'p2'},
        ),
      ],
    );

    blocTest<WishlistBloc, WishlistState>(
      'emits [WishlistLoading, WishlistError] when load fails',
      build: () => WishlistBloc(repository: repository),
      act: (bloc) => bloc.add(WishlistLoad()),
      setUp: () {
        when(() => repository.fetchWishlistedProductIds())
            .thenThrow(Exception('db down'));
      },
      expect: () => [
        isA<WishlistLoaded>(),
        isA<WishlistError>(),
      ],
    );

    blocTest<WishlistBloc, WishlistState>(
      'adds product optimistically on toggle, then persists',
      build: () => WishlistBloc(repository: repository),
      seed: () => const WishlistLoaded(productIds: {'p1'}),
      act: (bloc) => bloc.add(WishlistToggle('p2')),
      setUp: () {
        when(() => repository.addToWishlist('p2')).thenAnswer((_) async {});
      },
      expect: () => [
        isA<WishlistLoaded>().having(
          (s) => s.productIds,
          'productIds',
          {'p1', 'p2'},
        ),
      ],
      verify: (_) {
        verify(() => repository.addToWishlist('p2')).called(1);
      },
    );

    blocTest<WishlistBloc, WishlistState>(
      'removes product optimistically on toggle, then persists',
      build: () => WishlistBloc(repository: repository),
      seed: () => const WishlistLoaded(productIds: {'p1', 'p2'}),
      act: (bloc) => bloc.add(WishlistToggle('p1')),
      setUp: () {
        when(() => repository.removeFromWishlist('p1')).thenAnswer((_) async {});
      },
      expect: () => [
        isA<WishlistLoaded>().having(
          (s) => s.productIds,
          'productIds',
          {'p2'},
        ),
      ],
      verify: (_) {
        verify(() => repository.removeFromWishlist('p1')).called(1);
      },
    );

    blocTest<WishlistBloc, WishlistState>(
      'rolls back optimistic toggle when persistence fails',
      build: () => WishlistBloc(repository: repository),
      seed: () => const WishlistLoaded(productIds: {'p1'}),
      act: (bloc) => bloc.add(WishlistToggle('p2')),
      setUp: () {
        when(() => repository.addToWishlist('p2'))
            .thenThrow(Exception('network'));
      },
      expect: () => [
        isA<WishlistLoaded>().having(
          (s) => s.productIds,
          'productIds',
          {'p1', 'p2'},
        ),
        isA<WishlistLoaded>().having(
          (s) => s.productIds,
          'productIds',
          {'p1'},
        ),
        isA<WishlistError>(),
      ],
    );

    blocTest<WishlistBloc, WishlistState>(
      'loads list with search and merges paginated items',
      build: () => WishlistBloc(repository: repository),
      seed: () => const WishlistListLoaded(items: [
        {'id': 'old'},
      ]),
      act: (bloc) => bloc.add(WishlistLoadList(
        search: 'samsung',
        sortBy: 'price_low',
        page: 2,
      )),
      setUp: () {
        when(() => repository.fetchWishlist(
              search: any(named: 'search'),
              categoryId: any(named: 'categoryId'),
              sortBy: any(named: 'sortBy'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => [
          {'id': 'new'},
        ]);
      },
      expect: () => [
        isA<WishlistListLoaded>().having((s) => s.isLoading, 'isLoading', true),
        isA<WishlistListLoaded>()
            .having((s) => s.items, 'items', hasLength(2))
            .having((s) => s.hasMore, 'hasMore', false),
      ],
    );

    blocTest<WishlistBloc, WishlistState>(
      'reset page 1 replaces items on refresh',
      build: () => WishlistBloc(repository: repository),
      seed: () => const WishlistListLoaded(items: [
        {'id': 'old'},
      ]),
      act: (bloc) => bloc.add(WishlistLoadList(refresh: true, page: 1)),
      setUp: () {
        when(() => repository.fetchWishlist(
              search: any(named: 'search'),
              categoryId: any(named: 'categoryId'),
              sortBy: any(named: 'sortBy'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => [
          {'id': 'new'},
        ]);
      },
      expect: () => [
        isA<WishlistListLoaded>().having((s) => s.isLoading, 'isLoading', true),
        isA<WishlistListLoaded>()
            .having((s) => s.items, 'items', hasLength(1)),
      ],
    );

    blocTest<WishlistBloc, WishlistState>(
      'emits error and keeps existing items when list load fails',
      build: () => WishlistBloc(repository: repository),
      seed: () => const WishlistListLoaded(items: [
        {'id': 'old'},
      ]),
      act: (bloc) => bloc.add(WishlistLoadList(page: 2)),
      setUp: () {
        when(() => repository.fetchWishlist(
              search: any(named: 'search'),
              categoryId: any(named: 'categoryId'),
              sortBy: any(named: 'sortBy'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenThrow(Exception('network'));
      },
      expect: () => [
        isA<WishlistListLoaded>(),
        isA<WishlistListLoaded>(),
        isA<WishlistError>(),
      ],
    );
  });
}