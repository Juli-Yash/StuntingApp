// lib/models/child.dart
import 'package:smart_stunting_app/models/user.dart';
import 'package:smart_stunting_app/models/antropometry_record.dart';
import 'package:smart_stunting_app/models/prediction_record.dart';

class Child {
  final int? id;
  final int? userId;
  final String name;
  final String gender;
  final DateTime birthDate;
  final String region;
  final String? fatherEdu;
  final String? motherEdu;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final User? user;
  final List<AntropometryRecord>? antropometryRecords;
  final List<PredictionRecord>? predictionRecords;

  Child({
    this.id,
    this.userId,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.region,
    this.fatherEdu,
    this.motherEdu,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.antropometryRecords,
    this.predictionRecords,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    T? _parseValue<T>(dynamic value) {
      if (value == null) return null;
      if (T == int) {
        if (value is int) return value as T;
        if (value is String) return int.tryParse(value) as T?;
      } else if (T == double) {
        if (value is double) return value as T;
        if (value is int) return value.toDouble() as T;
        if (value is String) return double.tryParse(value) as T?;
      } else if (T == String) {
        return value.toString() as T;
      } else if (T == DateTime) {
        if (value is String) return DateTime.tryParse(value) as T?;
      }
      return value as T?;
    }

    DateTime? parsedBirthDate;
    if (json['birth_date'] != null) {
      try {
        parsedBirthDate = DateTime.parse(json['birth_date'].toString());
      } catch (e) {
        print('Error parsing birth_date: ${json['birth_date']}, error: $e');
      }
    }

    return Child(
      id: _parseValue<int>(json['id']),
      userId: _parseValue<int>(json['user_id']),
      name: _parseValue<String>(json['name']) ?? 'Unknown',
      gender: _parseValue<String>(json['gender']) ?? 'Unknown',
      birthDate: parsedBirthDate ?? DateTime(1900),
      region: _parseValue<String>(json['region']) ?? 'Unknown',
      fatherEdu: _parseValue<String>(json['father_edu']),
      motherEdu: _parseValue<String>(json['mother_edu']),
      createdAt: _parseValue<DateTime>(json['created_at']),
      updatedAt: _parseValue<DateTime>(json['updated_at']),

      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      antropometryRecords: (json['antropometry_records'] as List?)
          ?.map((e) => AntropometryRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      predictionRecords: (json['prediction_records'] as List?)
          ?.map((e) => PredictionRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'gender': gender,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'region': region,
      'father_edu': fatherEdu,
      'mother_edu': motherEdu,
    };
  }
}
