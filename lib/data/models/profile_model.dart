import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final String id;
  final String fullName;
  final String? phone;
  final String? church;
  final DateTime? birthDate;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.church,
    this.birthDate,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(json);

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
}
