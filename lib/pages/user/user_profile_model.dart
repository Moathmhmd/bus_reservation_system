class UserProfile {
  final String name;
  final String gender;
  final String dob;
  final String idNumber;
  final String mobile;
  final String email;

  UserProfile({
    required this.name,
    required this.gender,
    required this.dob,
    required this.idNumber,
    required this.mobile,
    required this.email,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'gender': gender,
        'dob': dob,
        'idNumber': idNumber,
        'mobile': mobile,
        'email': email,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        name: map['name'] ?? '',
        gender: map['gender'] ?? '',
        dob: map['dob'] ?? '',
        idNumber: map['idNumber'] ?? '',
        mobile: map['mobile'] ?? '',
        email: map['email'] ?? '',
      );
}

