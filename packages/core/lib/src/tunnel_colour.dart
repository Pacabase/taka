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

  static TunnelColour? fromName(Object? name) => values.asNameMap()[name];
}
