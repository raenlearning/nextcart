import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextcart/data/repository/wishlist_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthUser extends Mock implements User {}

void main() {
  late MockSupabaseClient client;
  late MockGoTrueClient auth;
  late WishlistRepository repository;

  setUp(() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    repository = WishlistRepository(client: client);

    final user = MockAuthUser();
    when(() => user.id).thenReturn('user-1');
    when(() => client.auth).thenReturn(auth);
    when(() => auth.currentUser).thenReturn(user);
  });

  group('sortColumn (PostgREST related-table syntax regression)', () {
    test('price_low and price_high use products(price), not products.price', () {
      expect(WishlistRepository.sortColumn('price_low'), 'products(price)');
      expect(WishlistRepository.sortColumn('price_high'), 'products(price)');
    });

    test('newest uses created_at', () {
      expect(WishlistRepository.sortColumn('newest'), 'created_at');
      expect(WishlistRepository.sortColumn('unknown'), 'created_at');
    });

    test('isPriceSort is true only for price sorts', () {
      expect(WishlistRepository.isPriceSort('price_low'), isTrue);
      expect(WishlistRepository.isPriceSort('price_high'), isTrue);
      expect(WishlistRepository.isPriceSort('newest'), isFalse);
      expect(WishlistRepository.isPriceSort(''), isFalse);
    });

    test('sortColumn never returns the invalid dotted syntax', () {
      final columns = ['price_low', 'price_high', 'newest']
          .map(WishlistRepository.sortColumn)
          .toList();
      expect(columns, isNot(contains('products.price')));
    });
  });

  group('fetchWishlist', () {
    test('returns empty list when user is not logged in (no query issued)',
        () async {
      when(() => auth.currentUser).thenReturn(null);

      final result = await repository.fetchWishlist();
      final ids = await repository.fetchWishlistedProductIds();

      expect(result, isEmpty);
      expect(ids, isEmpty);
      verifyNever(() => client.from(any()));
    });

    test('returns empty list when user is not logged in for add/remove',
        () async {
      when(() => auth.currentUser).thenReturn(null);

      await repository.addToWishlist('p1');
      await repository.removeFromWishlist('p1');

      verifyNever(() => client.from(any()));
    });
  });
}