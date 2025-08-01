// lib/models/antropometry_record.dart
import 'package:smart_stunting_app/models/prediction_record.dart';
import 'package:smart_stunting_app/models/child.dart';

class AntropometryRecord {
  final int? id;
  final int anakId;
  final double weight;
  final double height;
  final int ageInMonth;
  final double? headCircumference;
  final double? upperArmCircumference;
  final int? vitaminACount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Relasi
  final Child? anak;
  final PredictionRecord? predictionRecord;

  AntropometryRecord({
    this.id,
    required this.anakId,
    required this.weight,
    required this.height,
    required this.ageInMonth,
    this.headCircumference,
    this.upperArmCircumference,
    this.vitaminACount,
    this.createdAt,
    this.updatedAt,
    this.anak,
    this.predictionRecord,
  });

  factory AntropometryRecord.fromJson(Map<String, dynamic> json) {
    print('Decoding AntropometryRecord from JSON: $json');

    return AntropometryRecord(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      anakId: (json['anak_id'] is num)
          ? (json['anak_id'] as num).toInt()
          : (int.tryParse(json['anak_id']?.toString() ?? '0') ?? 0),
      weight: (json['weight'] is num)
          ? (json['weight'] as num).toDouble()
          : (double.tryParse(json['weight']?.toString() ?? '0.0') ?? 0.0),
      height: (json['height'] is num)
          ? (json['height'] as num).toDouble()
          : (double.tryParse(json['height']?.toString() ?? '0.0') ?? 0.0),
      ageInMonth: (json['age_in_month'] is num)
          ? (json['age_in_month'] as num).toInt()
          : (int.tryParse(json['age_in_month']?.toString() ?? '0') ?? 0),
      headCircumference: json['head_circumference'] != null
          ? (json['head_circumference'] is num)
                ? (json['head_circumference'] as num).toDouble()
                : (double.tryParse(
                        json['head_circumference']?.toString() ?? '',
                      ) ??
                      null)
          : null,
      upperArmCircumference: json['upper_arm_circumference'] != null
          ? (json['upper_arm_circumference'] is num)
                ? (json['upper_arm_circumference'] as num).toDouble()
                : (double.tryParse(
                        json['upper_arm_circumference']?.toString() ?? '',
                      ) ??
                      null)
          : null,
      vitaminACount: json['vitamin_a_count'] != null
          ? (json['vitamin_a_count'] is num)
                ? (json['vitamin_a_count'] as num).toInt()
                : (int.tryParse(json['vitamin_a_count']?.toString() ?? '') ??
                      null)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      predictionRecord:
          json['prediction_record'] != null &&
              json['prediction_record'] is Map<String, dynamic>
          ? PredictionRecord.fromJson(json['prediction_record'])
          : null,
      anak: json['anak'] != null && json['anak'] is Map<String, dynamic>
          ? Child.fromJson(json['anak'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anak_id': anakId,
      'weight': weight,
      'height': height,
      'age_in_month': ageInMonth,
      'head_circumference': headCircumference,
      'upper_arm_circumference': upperArmCircumference,
      'vitamin_a_count': vitaminACount,
    };
  }
}
