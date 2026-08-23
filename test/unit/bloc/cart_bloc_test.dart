import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nextcart/data/repository/shipping_repository.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockShippingRepository extends Mock implements ShippingRepository {}

void main() {
  late MockSupabaseClient client;
  late MockShippingRepository shippingRepository;

  setUp(() {
    client = MockSupabaseClient();
    shippingRepository = MockShippingRepository();
  });

  CartBloc buildBloc() => CartBloc(
        client: client,
        shippingRepository: shippingRepository,
      );

  group('calculateDiscount', () {
    late CartBloc bloc;

    setUp(() {
      bloc = buildBloc();
    });

    tearDown(() => bloc.close());

    test('returns 0 when voucher is null or empty', () {
      expect(bloc.calculateDiscount(100000, null), 0);
      expect(bloc.calculateDiscount(100000, const {}), 0);
    });

    test('returns fixed value discount for nominal type', () {
      const voucher = {
        'discount_type': 'nominal',
        'discount_value': 20000,
      };
      expect(bloc.calculateDiscount(100000, voucher), 20000);
    });

    test('returns percent of subtotal for percent type', () {
      const voucher = {
        'discount_type': 'percent',
        'discount_value': 10,
      };
      expect(bloc.calculateDiscount(100000, voucher), 10000);
    });

    test('caps percent discount at max_discount', () {
      const voucher = {
        'discount_type': 'percent',
        'discount_value': 50,
        'max_discount': 15000,
      };
      expect(bloc.calculateDiscount(100000, voucher), 15000);
    });

    test('does not cap discount when max_discount absent', () {
      const voucher = {
        'discount_type': 'percent',
        'discount_value': 50,
      };
      expect(bloc.calculateDiscount(100000, voucher), 50000);
    });
  });

  group('checkoutTotal', () {
    late CartBloc bloc;

    setUp(() {
      bloc = buildBloc();
    });

    tearDown(() => bloc.close());

    test('computes subtotal + shipping + PPN when no voucher', () {
      // PPN 11% dari subtotal: 100000 + 0.11*100000 = 111000 + shipping 10000
      expect(bloc.checkoutTotal(100000, null, 10000), 121000);
    });

    test('computes PPN on discounted subtotal when voucher applied', () {
      const voucher = {
        'discount_type': 'nominal',
        'discount_value': 20000,
      };
      // discounted = 80000, PPN = 8800, + shipping 0 => 88800
      expect(bloc.checkoutTotal(100000, voucher, 0), 88800);
    });

    test('rounds consistently with large values', () {
      // 10000000 + 0.11*10000000 + 25000 = 11125000
      expect(bloc.checkoutTotal(10000000, null, 25000), 11125000);
    });
  });
}