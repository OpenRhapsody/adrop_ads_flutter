/// An enumeration representing the theme options for Adrop.
enum AdropTheme {
  /// Light theme
  light("light"),

  /// Dark theme
  dark("dark"),

  /// Follows the system theme
  auto("auto");

  final String value;

  const AdropTheme(this.value);
}
