import 'package:flutter_test/flutter_test.dart';
import 'package:user/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email validation', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('test@example.com'), isNull);
    });

    test('password validation', () {
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('required validation', () {
      expect(Validators.requiredField('', 'Title'), 'Title is required');
      expect(Validators.requiredField('ok', 'Title'), isNull);
    });
  });
}
