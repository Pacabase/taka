@Tags(['unit'])
library;

import 'package:agent/src/foreground.dart';
import 'package:test/test.dart';

void main() {
  const taka = 1;
  const terminal = 2;
  const browser = 3;
  late int? front;
  late List<int> activated;
  late int activations;

  Foreground foreground({Future<void> Function()? activate}) => Foreground(
    activate:
        activate ??
        () async {
          activations++;
          front = taka;
        },
    frontmostApp: () => front,
    activateApp: (pid) {
      activated.add(pid);
      front = pid;
    },
    self: taka,
  );

  setUp(() {
    front = terminal;
    activated = [];
    activations = 0;
  });

  test('comes forward, then hands focus back to the app in front', () async {
    final handBack = await foreground().comeForward();
    expect(activations, 1);
    expect(front, taka);

    await handBack();

    expect(activated, [terminal]);
  });

  test('hands back once the last tunnel is done', () async {
    final shared = foreground();
    final first = await shared.comeForward();
    final second = await shared.comeForward();

    await first();
    expect(activated, isEmpty);
    await second();

    expect(activated, [terminal]);
  });

  test('hands back to the app in front before the first came', () async {
    final shared = foreground();
    final first = await shared.comeForward();
    front = browser;
    final second = await shared.comeForward();

    await first();
    await second();

    expect(activated, [terminal]);
  });

  test('leaves focus where the user moved it', () async {
    final handBack = await foreground().comeForward();
    front = browser;

    await handBack();

    expect(activated, isEmpty);
  });

  test('keeps focus when Taka was in front already', () async {
    front = taka;
    final handBack = await foreground().comeForward();

    await handBack();

    expect(activated, isEmpty);
  });

  test('keeps focus when no app was in front', () async {
    front = null;
    final handBack = await foreground().comeForward();

    await handBack();

    expect(activated, isEmpty);
  });

  test('handing back twice counts once', () async {
    final shared = foreground();
    final first = await shared.comeForward();
    final second = await shared.comeForward();

    await first();
    await first();
    expect(activated, isEmpty);
    await second();

    expect(activated, [terminal]);
  });

  test('a failed activation throws and holds nothing', () async {
    var fails = true;
    final shared = foreground(
      activate: () async {
        if (fails) throw StateError('open');
        front = taka;
      },
    );
    await expectLater(shared.comeForward(), throwsStateError);
    fails = false;

    await (await shared.comeForward())();

    expect(activated, [terminal]);
  });

  test('comes forward afresh after handing back', () async {
    final shared = foreground();
    await (await shared.comeForward())();
    front = browser;

    await (await shared.comeForward())();

    expect(activated, [terminal, browser]);
  });
}
