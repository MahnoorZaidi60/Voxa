import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';
import '../utils/constants.dart';

class NotesProvider extends ChangeNotifier {
  // Reference to the Hive Box
  final Box<NoteModel> _notesBox = Hive.box<NoteModel>(AppConstants.notesBox);

  // List to display in UI (Filtered or All)
  List<NoteModel> _notes = [];

  List<NoteModel> get notes => _notes;

  NotesProvider() {
    _loadNotes();
  }

  // Load all notes from database
  void _loadNotes() {
    _notes = _notesBox.values.toList();
    // Sort by Date (Newest first)
    _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  // Add a new note
  Future<void> addNote(NoteModel note) async {
    await _notesBox.add(note);
    _loadNotes(); // Refresh list
  }

  // Delete a note
  Future<void> deleteNote(NoteModel note) async {
    await note.delete(); // HiveObject method
    _loadNotes();
  }

  // Edit a note
  Future<void> updateNote(NoteModel note, String newTitle, String newText) async {
    note.title = newTitle;
    note.originalText = newText;
    await note.save();
    _loadNotes();
  }

  // Search Logic
  void searchNotes(String query) {
    if (query.isEmpty) {
      _loadNotes(); // Reset if search is empty
    } else {
      final allNotes = _notesBox.values.toList();
      _notes = allNotes.where((note) {
        final titleLower = note.title.toLowerCase();
        final textLower = note.originalText.toLowerCase();
        final searchLower = query.toLowerCase();

        return titleLower.contains(searchLower) || textLower.contains(searchLower);
      }).toList();
      notifyListeners();
    }
  }
}