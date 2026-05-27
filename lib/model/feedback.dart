import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback{
  final String? userId;
  final double rating; 
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Feedback({
    this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  Feedback copyWith({
    String? userId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feedback(
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      userId: map['userId'] as String?,
      rating: (map['rating'] as double),
      comment: map['comment'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}