extension NullableTextExtension on String {
  /// The trimmed text, or `null` when the string is empty or only whitespace.
  ///
  /// Used to turn an untouched optional form field into "not provided".
  String? get nullIfBlank {
    final trimmed = trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
