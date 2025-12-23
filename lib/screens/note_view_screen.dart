import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // For Clipboard

import '../models/note_model.dart';
import '../providers/notes_provider.dart';

class NoteViewScreen extends StatefulWidget {
  final NoteModel note;

  const NoteViewScreen({super.key, required this.note});

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _textController = TextEditingController(text: widget.note.originalText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_titleController.text.isNotEmpty) {
      Provider.of<NotesProvider>(context, listen: false).updateNote(
        widget.note,
        _titleController.text,
        _textController.text,
      );
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note updated successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Date formatting
    final dateStr = DateFormat('MMM d, y - h:mm a').format(widget.note.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Note" : "View Note"),
        actions: [
          // Edit / Save Toggle Button
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title Section ---
            if (_isEditing)
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: "Title",
                  border: UnderlineInputBorder(),
                ),
              )
            else
              Text(
                widget.note.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 8),
            Text(
              dateStr,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),

            const SizedBox(height: 24),

            // --- Original Text Section ---
            _buildSectionHeader(context, "Original Text", Icons.mic),
            const SizedBox(height: 8),

            if (_isEditing)
              TextField(
                controller: _textController,
                maxLines: null,
                style: const TextStyle(fontSize: 16, height: 1.5),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Note text...",
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: SelectableText( // Allows user to select/copy text
                  widget.note.originalText,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),

            // --- Translated Text Section (Read Only) ---
            if (widget.note.translatedText.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(context, "Translation", Icons.translate),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.note.translatedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Translation copied!")),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                ),
                child: SelectableText(
                  widget.note.translatedText,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}