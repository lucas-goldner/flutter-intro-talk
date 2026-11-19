/// Asset keys of every fragment program in the deck — kept in sync with the
/// `shaders:` list in pubspec.yaml.
abstract final class ShaderAssets {
  static const titleAurora = 'shaders/title_aurora.frag';
  static const galaxyButton = 'shaders/galaxy_button.frag';
  static const chaosButton = 'shaders/chaos_button.frag';
  static const musicBackground = 'shaders/music_background.frag';

  static const all = [
    titleAurora,
    galaxyButton,
    chaosButton,
    musicBackground,
  ];
}
