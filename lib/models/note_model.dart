

import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String originalText;

  @HiveField(3)
  String translatedText;

  @HiveField(4)
  String languageCode; // e.g., 'en' or 'ur'

  @HiveField(5)
  DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.originalText,
    required this.translatedText,
    required this.languageCode,
    required this.createdAt,
  });
}