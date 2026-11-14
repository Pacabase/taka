enum TunnelColour {
  red('🟥'),
  orange('🟧'),
  yellow('🟨'),
  green('🟩'),
  blue('🟦'),
  purple('🟪');

  const TunnelColour(this.square);

  /// The emoji square menus show it as, since they can't draw a colour.
  final String square;

  static TunnelColour? fromName(Object? name) => _byName[name];

  static final _byName = values.asNameMap();
}

Map<String, String> groupColoursToJson(Map<String, TunnelColour> colours) =>
    colours.map((group, colour) => MapEntry(group, colour.name));

/// What [groupColoursToJson] wrote; anything else, or an unknown colour, is
/// left out.
Map<String, TunnelColour> groupColoursFromJson(Object? json) => switch (json) {
  final Map<String, Object?> colours => {
    for (final MapEntry(key: group, value: name) in colours.entries)
      group: ?TunnelColour.fromName(name),
  },
  _ => {},
};
