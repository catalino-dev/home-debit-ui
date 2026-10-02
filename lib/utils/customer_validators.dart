/// Client-side customer field rules shared by the Registration and Edit
/// Profile forms. Keep them in step with the backend's Jakarta validation
/// (`CustomerRegistrationRequest` / `CustomerUpdateRequest`).
abstract final class CustomerValidators {
  static const int nicknameMaxLength = 50;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _mobilePattern = RegExp(r'^\d{7,15}$');

  static String? fullName(String? value) => _required(value, 'Full name');

  static String? email(String? value) {
    final requiredError = _required(value, 'Email');
    if (requiredError != null) return requiredError;
    // `!` is safe: _required already rejected null.
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? mobileNumber(String? value) {
    final requiredError = _required(value, 'Mobile number');
    if (requiredError != null) return requiredError;
    if (!_mobilePattern.hasMatch(value!.trim())) {
      return 'Enter a valid mobile number (digits only)';
    }
    return null;
  }

  /// Nickname is optional: null/blank is valid, only the length is checked.
  static String? nickname(String? value) {
    if ((value?.trim().length ?? 0) > nicknameMaxLength) {
      return 'Nickname must be $nicknameMaxLength characters or fewer';
    }
    return null;
  }

  static String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
