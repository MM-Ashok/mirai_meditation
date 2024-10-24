import 'package:stripe_js/stripe_api.dart';
import 'package:test/test.dart';

void main() {
  group('ConfirmAlipayPaymentOptions', () {
    test('handleActions is true by default', () {
      expect(
        const ConfirmAlipayPaymentOptions().toJson(),
        {
          "handleActions": true,
        },
      );
    });

    test('handleActions can be set to false', () {
      expect(
        const ConfirmAlipayPaymentOptions(
          handleActions: false,
        ).toJson(),
        {
          "handleActions": false,
        },
      );
    });
  });
}
