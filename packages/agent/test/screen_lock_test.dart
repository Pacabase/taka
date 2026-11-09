@Tags(['unit'])
library;

import 'package:agent/src/screen_lock.dart';
import 'package:test/test.dart';

void main() {
  test('says the screen is unlocked while tests run', () async {
    expect(await isScreenLocked(), isFalse);
  });
}
