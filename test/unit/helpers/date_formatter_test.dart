import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/helper/date_formatter.dart';

void main() {
  group('formatDate', () {
    test('formats a full date with Indonesian month abbreviation', () {
      expect(formatDate(DateTime(2026, 8, 16)), '16 Agu 2026');
    });

    test('pads single digit days', () {
      expect(formatDate(DateTime(2026, 3, 5)), '5 Mar 2026');
    });

    test('handles January and December boundaries', () {
      expect(formatDate(DateTime(2026, 1, 1)), '1 Jan 2026');
      expect(formatDate(DateTime(2026, 12, 31)), '31 Des 2026');
    });
  });

  group('formatDateTime', () {
    test('formats date and time with colon separator', () {
      expect(
        formatDateTime(DateTime(2026, 8, 16, 14, 5)),
        '16 Agu 2026, 14:05',
      );
    });

    test('pads hours and minutes to two digits', () {
      expect(
        formatDateTime(DateTime(2026, 1, 2, 9, 3)),
        '2 Jan 2026, 09:03',
      );
    });

    test('handles midnight correctly', () {
      expect(
        formatDateTime(DateTime(2026, 8, 16, 0, 0)),
        '16 Agu 2026, 00:00',
      );
    });
  });
}