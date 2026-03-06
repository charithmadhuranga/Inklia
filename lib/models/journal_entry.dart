import 'dart:convert';

enum Mood { happy, excited, calm, neutral, sad, anxious, angry }

extension MoodExtension on Mood {
  String get emoji {
    switch (this) {
      case Mood.happy:
        return '😊';
      case Mood.excited:
        return '🤩';
      case Mood.calm:
        return '😌';
      case Mood.neutral:
        return '😐';
      case Mood.sad:
        return '😢';
      case Mood.anxious:
        return '😰';
      case Mood.angry:
        return '😠';
    }
  }

  String get label {
    switch (this) {
      case Mood.happy:
        return 'Happy';
      case Mood.excited:
        return 'Excited';
      case Mood.calm:
        return 'Calm';
      case Mood.neutral:
        return 'Neutral';
      case Mood.sad:
        return 'Sad';
      case Mood.anxious:
        return 'Anxious';
      case Mood.angry:
        return 'Angry';
    }
  }
}

class JournalEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final List<String> imagePaths;
  final List<String> voiceMemoPaths;
  final Mood? mood;
  final List<String> tags;
  final bool isFavorite;
  final String? templateType;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    List<String>? imagePaths,
    List<String>? voiceMemoPaths,
    this.mood,
    List<String>? tags,
    this.isFavorite = false,
    this.templateType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : imagePaths = imagePaths ?? [],
       voiceMemoPaths = voiceMemoPaths ?? [],
       tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'imagePaths': jsonEncode(imagePaths),
      'voiceMemoPaths': jsonEncode(voiceMemoPaths),
      'mood': mood?.index,
      'tags': jsonEncode(tags),
      'isFavorite': isFavorite ? 1 : 0,
      'templateType': templateType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      content: map['content'] as String,
      imagePaths: List<String>.from(jsonDecode(map['imagePaths'] as String)),
      voiceMemoPaths: List<String>.from(
        jsonDecode(map['voiceMemoPaths'] as String),
      ),
      mood: map['mood'] != null ? Mood.values[map['mood'] as int] : null,
      tags: List<String>.from(jsonDecode(map['tags'] as String)),
      isFavorite: (map['isFavorite'] as int) == 1,
      templateType: map['templateType'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  JournalEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    List<String>? imagePaths,
    List<String>? voiceMemoPaths,
    Mood? mood,
    bool clearMood = false,
    List<String>? tags,
    bool? isFavorite,
    String? templateType,
    bool clearTemplateType = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      voiceMemoPaths: voiceMemoPaths ?? this.voiceMemoPaths,
      mood: clearMood ? null : (mood ?? this.mood),
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      templateType:
          clearTemplateType ? null : (templateType ?? this.templateType),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
