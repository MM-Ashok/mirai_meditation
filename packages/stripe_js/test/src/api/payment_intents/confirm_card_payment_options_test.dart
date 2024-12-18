import 'package:stripe_js/stripe_api.dart';
import 'package:test/test.dart';

void main() {
  group('ConfirmCardPaymentOptions', () {
    test('handleActions is true by default', () {
      expect(
        const ConfirmCardPaymentOptions().toJson(),
        {
          "handleActions": true,
        },
      );
    });

    test('handleActions can be set to false', () {
      expect(
        const ConfirmCardPaymentOptions(
          handleActions: false,
        ).toJson(),
        {
          "handleActions": false,
        },
      );
    });
  });
}
