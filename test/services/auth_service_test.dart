import 'package:flutter_test/flutter_test.dart';
import 'package:code_bolanon/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AuthServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
