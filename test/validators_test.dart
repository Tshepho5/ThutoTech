import 'package:flutter_test/flutter_test.dart';
import 'package:thutotech/core/validation/input_validators.dart';

void main() {
  group('InputValidators - Strict Type Validation', () {
    test('validateTextOnly rejects numeric digits', () {
      expect(InputValidators.validateTextOnly('Thabo123', fieldName: 'First Name'), contains('must only contain letters'));
      expect(InputValidators.validateTextOnly('Mak0la', fieldName: 'Surname'), contains('must only contain letters'));
      expect(InputValidators.validateTextOnly('999', fieldName: 'Name'), contains('must only contain letters'));
    });

    test('validateTextOnly accepts valid alphabetic names', () {
      expect(InputValidators.validateTextOnly('Thabo', fieldName: 'First Name'), isNull);
      expect(InputValidators.validateTextOnly('Sibusiso Makola', fieldName: 'Full Name'), isNull);
      expect(InputValidators.validateTextOnly("O'Connor", fieldName: 'Surname'), isNull);
      expect(InputValidators.validateTextOnly('Jean-Luc', fieldName: 'First Name'), isNull);
    });

    test('validateNumberOnly rejects alphabetic characters and symbols', () {
      expect(InputValidators.validateNumberOnly('1234a', fieldName: 'Score'), contains('must only contain numbers'));
      expect(InputValidators.validateNumberOnly('ten', fieldName: 'Score'), contains('must only contain numbers'));
      expect(InputValidators.validateNumberOnly('10@0', fieldName: 'Score'), contains('must be a valid number'));
    });

    test('validateNumberOnly accepts pure digits and range checks', () {
      expect(InputValidators.validateNumberOnly('85', fieldName: 'Mark', minVal: 0, maxVal: 100), isNull);
      expect(InputValidators.validateNumberOnly('105', fieldName: 'Mark', minVal: 0, maxVal: 100), contains('cannot exceed 100'));
      expect(InputValidators.validateNumberOnly('-5', fieldName: 'Mark', minVal: 0, maxVal: 100), isNotNull);
    });

    test('validateNationalID strictly checks 13 digits numeric', () {
      expect(InputValidators.validateNationalID('080512584108A'), contains('Letters are strictly prohibited'));
      expect(InputValidators.validateNationalID('12345'), contains('must be exactly 13 digits'));
      expect(InputValidators.validateNationalID('0805125841088'), isNull);
    });

    test('validatePhoneNumber checks 10 digits numeric', () {
      expect(InputValidators.validatePhoneNumber('082abc4567'), contains('must only contain numbers'));
      expect(InputValidators.validatePhoneNumber('123'), contains('must be a valid 10-digit number'));
      expect(InputValidators.validatePhoneNumber('0821234567'), isNull);
    });
  });
}
