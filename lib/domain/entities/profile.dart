class Profile {
  final String id;
  final String fullName;
  final String? phone;
  final String? church;
  final DateTime? birthDate;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.fullName,
    this.phone,
    this.church,
    this.birthDate,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  String? get formattedBirthDate {
    if (birthDate == null) return null;
    return '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}';
  }

  String? get genderDisplay {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Profile{id: $id, fullName: $fullName}';
  }
}
