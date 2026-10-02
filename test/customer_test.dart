import 'package:flutter_test/flutter_test.dart';
import 'package:home_debit_ui/models/customer.dart';
import 'package:home_debit_ui/utils/customer_validators.dart';
import 'package:home_debit_ui/utils/string_extension.dart';

void main() {
  group('Customer.fromJson nickname (US-03)', () {
    const base = {
      'id': 1,
      'fullName': 'Jane Doe',
      'email': 'jane.doe@example.com',
      'mobileNumber': '09171234567',
    };

    test('maps a missing nickname key to null', () {
      expect(Customer.fromJson({...base}).nickname, isNull);
    });

    test('maps an explicit null nickname to null', () {
      expect(Customer.fromJson({...base, 'nickname': null}).nickname, isNull);
    });

    test('maps a present nickname', () {
      expect(
        Customer.fromJson({...base, 'nickname': 'Janie'}).nickname,
        'Janie',
      );
    });
  });

  test('Customer equality compares every field', () {
    const a = Customer(
      id: 1,
      fullName: 'Jane',
      email: 'j@example.com',
      mobileNumber: '0917123',
    );
    const b = Customer(
      id: 1,
      fullName: 'Jane',
      email: 'j@example.com',
      mobileNumber: '0917123',
    );
    const c = Customer(
      id: 1,
      fullName: 'Jane',
      email: 'j@example.com',
      mobileNumber: '0917123',
      nickname: 'J',
    );

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));
  });

  group('nullIfBlank', () {
    test('returns null for empty or whitespace-only text', () {
      expect(''.nullIfBlank, isNull);
      expect('   '.nullIfBlank, isNull);
    });

    test('returns trimmed text otherwise', () {
      expect('  Juanito '.nullIfBlank, 'Juanito');
    });
  });

  group('CustomerValidators.nickname', () {
    test('accepts null and blank because nickname is optional', () {
      expect(CustomerValidators.nickname(null), isNull);
      expect(CustomerValidators.nickname(''), isNull);
    });

    test('rejects more than 50 characters', () {
      expect(CustomerValidators.nickname('x' * 50), isNull);
      expect(
        CustomerValidators.nickname('x' * 51),
        'Nickname must be 50 characters or fewer',
      );
    });
  });
}
