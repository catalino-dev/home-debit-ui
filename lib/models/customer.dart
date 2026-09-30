/// A customer as known to the app.
///
/// Required fields are non-nullable `String`s: the type system guarantees
/// they always hold a value. [id] and [nickname] are nullable (`?`):
/// [id] is absent until the backend assigns it, and [nickname] is optional
/// (US-03), so `null` means "not provided".
class Customer {
  final int? id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String? nickname;

  const Customer({
    this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    this.nickname,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobileNumber'] as String,
      // Missing key and explicit null both become null.
      nickname: json['nickname'] as String?,
    );
  }

  /// Body for `POST /api/customers` and `PUT /api/customers/{id}`.
  Map<String, String?> toRequestJson() => {
    'fullName': fullName,
    'email': email,
    'mobileNumber': mobileNumber,
    'nickname': nickname,
  };

  @override
  bool operator ==(Object other) =>
      other is Customer &&
      other.id == id &&
      other.fullName == fullName &&
      other.email == email &&
      other.mobileNumber == mobileNumber &&
      other.nickname == nickname;

  @override
  int get hashCode => Object.hash(id, fullName, email, mobileNumber, nickname);

  @override
  String toString() =>
      'Customer(id: $id, fullName: $fullName, email: $email, '
      'mobileNumber: $mobileNumber, nickname: $nickname)';
}
