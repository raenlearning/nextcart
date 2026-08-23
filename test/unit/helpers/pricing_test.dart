import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/constants/pricing.dart';

void main() {
  group('AppPricing', () {
    test('vatRate is 0.11', () {
      expect(AppPricing.vatRate, 0.11);
    });

    test('vatRate is positive and below 1', () {
      expect(AppPricing.vatRate, greaterThan(0));
      expect(AppPricing.vatRate, lessThan(1));
    });
  });
}