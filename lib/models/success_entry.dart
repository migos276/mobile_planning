import 'package:uuid/uuid.dart';

enum SuccessCategory { professional, personal, learning, wellness, social }

class SuccessEntry {
  final String id;
  final String title;
  final String description;
  final SuccessCategory category;
  final DateTime date;
  final String? imageUrl;
  final List<String> tags;
  final int confidenceImpact; // 1-5 scale

  SuccessEntry({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    DateTime? date,
    this.imageUrl,
    this.tags = const [],
    this.confidenceImpact = 3,
  }) : id = id ?? const Uuid().v4(),
       date = date ?? DateTime.now();

  SuccessEntry copyWith({
    String? id,
    String? title,
    String? description,
    SuccessCategory? category,
    DateTime? date,
    String? imageUrl,
    List<String>? tags,
    int? confidenceImpact,
  }) {
    return SuccessEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      confidenceImpact: confidenceImpact ?? this.confidenceImpact,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'tags': tags,
      'confidenceImpact': confidenceImpact,
    };
  }

  factory SuccessEntry.fromJson(Map<String, dynamic> json) {
    return SuccessEntry(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: SuccessCategory.values[json['category']],
      date: DateTime.parse(json['date']),
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      confidenceImpact: json['confidenceImpact'] ?? 3,
    );
  }
}