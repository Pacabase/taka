@Tags(['unit'])
library;

import 'package:core/core.dart';
import 'package:test/test.dart';

import 'fakes/fakes.dart';

void main() {
  final prodDatabase = database.copyWith(group: 'Prod');
  final prodProxy = proxy.copyWith(group: 'Prod');

  group('pruned', () {
    test('drops the colour of a group no tunnel is in', () {
      final book = TunnelBook(
        tunnels: [prodDatabase, proxy],
        groupColours: const {
          'Prod': TunnelColour.blue,
          'Gone': TunnelColour.red,
        },
      );

      expect(book.pruned.groupColours, {'Prod': TunnelColour.blue});
      expect(book.pruned.tunnels, book.tunnels);
    });

    test('keeps a book that has no unused colours as it is', () {
      final book = TunnelBook(
        tunnels: [prodDatabase],
        groupColours: const {'Prod': TunnelColour.blue},
      );

      expect(book.pruned, book);
    });
  });

  group('saved', () {
    test('adds a new tunnel at the end', () {
      expect(const TunnelBook(tunnels: [database]).saved(proxy).tunnels, [
        database,
        proxy,
      ]);
    });

    test('replaces a saved tunnel where it is', () {
      final renamed = database.copyWith(name: 'Primary');

      expect(
        const TunnelBook(tunnels: [database, proxy]).saved(renamed).tunnels,
        [renamed, proxy],
      );
    });

    test('puts a tunnel that joins a group after its last tunnel', () {
      final book = TunnelBook(tunnels: [prodDatabase, docker, preview]);
      final joined = preview.copyWith(group: 'Prod');

      expect(book.saved(joined).tunnels, [prodDatabase, joined, docker]);
    });

    test('adds a new tunnel of a group after its last tunnel', () {
      final book = TunnelBook(tunnels: [prodDatabase, docker]);

      expect(book.saved(prodProxy).tunnels, [prodDatabase, prodProxy, docker]);
    });

    test('leaves a tunnel that stays in its group where it is', () {
      final book = TunnelBook(tunnels: [prodDatabase, docker, prodProxy]);
      final renamed = prodDatabase.copyWith(name: 'Primary');

      expect(book.saved(renamed).tunnels, [renamed, docker, prodProxy]);
    });

    test('drops the colour of the group a tunnel leaves empty', () {
      final book = TunnelBook(
        tunnels: [prodDatabase, proxy],
        groupColours: const {'Prod': TunnelColour.blue},
      );

      expect(book.saved(database).groupColours, isEmpty);
    });
  });

  group('removed', () {
    test('takes the tunnel out', () {
      expect(
        const TunnelBook(tunnels: [database, proxy]).removed('a1').tunnels,
        [proxy],
      );
    });

    test('of an unknown id changes nothing', () {
      const book = TunnelBook(tunnels: [database, proxy]);

      expect(book.removed('gone'), book);
    });

    test('drops the colour of a group left empty', () {
      final book = TunnelBook(
        tunnels: [prodDatabase, proxy],
        groupColours: const {'Prod': TunnelColour.blue},
      );

      expect(book.removed('a1').groupColours, isEmpty);
    });

    test('keeps the colour of a group with tunnels left', () {
      final book = TunnelBook(
        tunnels: [prodDatabase, prodProxy],
        groupColours: const {'Prod': TunnelColour.blue},
      );

      expect(book.removed('a1').groupColours, {'Prod': TunnelColour.blue});
    });
  });

  group('groupEdited', () {
    final book = TunnelBook(
      tunnels: [
        prodDatabase,
        proxy.copyWith(group: 'Live'),
      ],
      groupColours: const {'Live': TunnelColour.red},
    );

    test('gives a group a colour', () {
      expect(
        book
            .groupEdited('Prod', name: 'Prod', colour: TunnelColour.blue)
            .groupColours,
        {'Prod': TunnelColour.blue, 'Live': TunnelColour.red},
      );
    });

    test('takes a colour away with none', () {
      expect(
        book.groupEdited('Live', name: 'Live', colour: null).groupColours,
        isEmpty,
      );
    });

    test('renames the group and moves its colour in one edit', () {
      final edited = book.groupEdited(
        'Live',
        name: 'Staging',
        colour: TunnelColour.red,
      );

      expect(edited.tunnels.map((tunnel) => tunnel.group), ['Prod', 'Staging']);
      expect(edited.groupColours, {'Staging': TunnelColour.red});
    });

    test('renames to a trimmed name, and keeps the name for a blank one', () {
      expect(
        book
            .groupEdited('Prod', name: ' QA ', colour: null)
            .tunnels
            .first
            .group,
        'QA',
      );
      expect(
        book.groupEdited('Prod', name: '  ', colour: null).tunnels.first.group,
        'Prod',
      );
    });

    test('joins a group named like another in any case', () {
      final edited = book.groupEdited('Prod', name: 'live', colour: null);

      expect(edited.tunnels.map((tunnel) => tunnel.group), ['Live', 'Live']);
    });

    test('keeps the joined group\'s colour when none is picked', () {
      expect(
        book.groupEdited('Prod', name: 'live', colour: null).groupColours,
        {'Live': TunnelColour.red},
      );
    });

    test('gives the joined group the colour picked', () {
      expect(
        book
            .groupEdited('Prod', name: 'live', colour: TunnelColour.blue)
            .groupColours,
        {'Live': TunnelColour.blue},
      );
    });

    test('changes the spelling of the group itself', () {
      final edited = book.groupEdited(
        'Live',
        name: 'LIVE',
        colour: TunnelColour.red,
      );

      expect(edited.tunnels.last.group, 'LIVE');
      expect(edited.groupColours, {'LIVE': TunnelColour.red});
    });

    test('of a group with no tunnels changes nothing', () {
      expect(
        book.groupEdited('Gone', name: 'Gone', colour: TunnelColour.blue),
        book,
      );
    });

    test('with nothing new changes nothing', () {
      expect(
        book.groupEdited('Live', name: 'Live', colour: TunnelColour.red),
        book,
      );
    });
  });

  group('imported', () {
    test('adds the tunnels not saved yet', () {
      expect(
        const TunnelBook(tunnels: [database])
            .imported(const TunnelBook(tunnels: [database, proxy]))
            .tunnels,
        [database, proxy],
      );
    });

    test('skips a tunnel saved here under another id, group or colour', () {
      final book = TunnelBook(
        tunnels: [prodDatabase.copyWith(colour: TunnelColour.red)],
      );

      expect(
        book.imported(
          TunnelBook(
            tunnels: [database.copyWith(id: 'x9', group: 'Live')],
          ),
        ),
        book,
      );
    });

    test('gives a new tunnel with a saved id a free one', () {
      final other = proxy.copyWith(id: 'a1');

      expect(
        const TunnelBook(tunnels: [database])
            .imported(
              TunnelBook(
                tunnels: [other, other.copyWith.forward(localPort: 1081)],
              ),
            )
            .tunnels
            .map((tunnel) => tunnel.id),
        ['a1', 'a1-2', 'a1-3'],
      );
    });

    test('puts a tunnel in the group here named like its own', () {
      final book = TunnelBook(tunnels: [prodDatabase]);

      expect(
        book
            .imported(TunnelBook(tunnels: [proxy.copyWith(group: 'prod')]))
            .tunnels
            .last
            .group,
        'Prod',
      );
    });

    test('brings group colours, but keeps the ones set here', () {
      final book = TunnelBook(
        tunnels: [prodDatabase],
        groupColours: const {'Prod': TunnelColour.red},
      );

      final imported = book.imported(
        TunnelBook(
          tunnels: [
            proxy.copyWith(group: 'prod'),
            docker.copyWith(group: 'cache'),
          ],
          groupColours: const {
            ' cache ': TunnelColour.green,
            'prod': TunnelColour.blue,
            'gone': TunnelColour.purple,
            '  ': TunnelColour.yellow,
          },
        ),
      );

      expect(imported.groupColours, {
        'Prod': TunnelColour.red,
        'cache': TunnelColour.green,
      });
    });

    test('of nothing new changes nothing', () {
      final book = TunnelBook(
        tunnels: [prodDatabase],
        groupColours: const {'Prod': TunnelColour.red},
      );

      expect(
        book.imported(
          TunnelBook(
            tunnels: [database],
            groupColours: const {'Gone': TunnelColour.blue},
          ),
        ),
        book,
      );
    });
  });

  group('arranged', () {
    test('puts the tunnels in the order and groups given', () {
      final arranged = const TunnelBook(tunnels: [database, proxy])
          .arranged([(id: 'b2', group: 'Web'), (id: 'a1', group: null)]);

      expect(arranged.tunnels, [proxy.copyWith(group: 'Web'), database]);
    });

    test('drops the colour of a group it empties', () {
      final book = TunnelBook(
        tunnels: [prodDatabase, proxy],
        groupColours: const {'Prod': TunnelColour.blue},
      );

      expect(
        book.arranged([
          (id: 'a1', group: 'Live'),
          (id: 'b2', group: null),
        ]).groupColours,
        isEmpty,
      );
    });

    test('in the same order changes nothing', () {
      const book = TunnelBook(tunnels: [database, proxy]);

      expect(
        book.arranged([(id: 'a1', group: null), (id: 'b2', group: null)]),
        book,
      );
    });
  });
}
