class Antropometri {
  final int? id;
  final int childId;
  final DateTime date;
  final double weight;
  final double height;
  final double? headCircumference;

  Antropometri({
    this.id,
    required this.childId,
    required this.date,
    required this.weight,
    required this.height,
    this.headCircumference,
  });

  factory Antropometri.fromJson(Map<String, dynamic> json) {
    return Antropometri(
      id: json['id'],
      childId: json['child_id'],
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      headCircumference: (json['head_circumference'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'date': date.toIso8601String().split('T')[0],
      'weight': weight,
      'height': height,
      'head_circumference': headCircumference,
    };
  }
}
