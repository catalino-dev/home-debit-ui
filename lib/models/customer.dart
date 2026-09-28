class Customer {
  final int? id;
  final String fullName;
  final String email;
  final String mobileNumber;

  const Customer({
    this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobileNumber'] as String,
    );
  }

  Map<String, String> toRegistrationJson() => {
    'fullName': fullName,
    'email': email,
    'mobileNumber': mobileNumber,
  };

  @override
  String toString() =>
      'Customer(id: $id, fullName: $fullName, email: $email, mobileNumber: $mobileNumber)';
}
