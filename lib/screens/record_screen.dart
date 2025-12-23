import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // For unique IDs
import 'package:intl/intl.dart'; // For date formatting

import '../providers/speech_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../models/note_model.dart';
import '../widgets/language_dropdown.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 1. Screen khulte hi purana data saaf karein
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    speechProvider.clear();

    // 2. Phir speech engine initialize karein
    speechProvider.initSpeech();
  }

  @override
  void dispose() {
    // 3. Agar user record karte hue back chala jaye, toh recording stop karein
    Provider.of<SpeechProvider>(context, listen: false).stopListening();

    _titleController.dispose();
    super.dispose();
  }
  // --- Helper to Map Language Code to Speech Locale ---
  String _getLocaleId(String simpleCode) {
    switch (simpleCode) {
      case 'ur': return 'ur_PK'; // Urdu (Pakistan)
      case 'es': return 'es_ES'; // Spanish
      case 'fr': return 'fr_FR'; // French
      case 'de': return 'de_DE'; // German
      case 'hi': return 'hi_IN'; // Hindi
      case 'ar': return 'ar_SA'; // Arabic
      case 'zh': return 'zh_CN'; // Chinese
      case 'tr': return 'tr_TR'; // turkish
      default: return 'en_US';   // English (Default)
    }
  }

  // --- Helper to get Simple Code from Locale ID ---
  String _getSimpleCode(String localeId) {
    // e.g. 'ur_PK' -> 'ur', 'en_US' -> 'en'
    return localeId.split('_').first;
  }

  void _saveNote(BuildContext context) {
    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    if (speechProvider.recognizedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot save empty note!")),
      );
      return;
    }

    // Create Note Object
    final newNote = NoteModel(
      id: const Uuid().v4(), // Generate unique ID
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : "Voice Note ${DateFormat('MM/dd').format(DateTime.now())}",
      originalText: speechProvider.recognizedText,
      translatedText: speechProvider.translatedText,
      languageCode: speechProvider.sourceLanguageId,
      createdAt: DateTime.now(),
    );

    // Save to Hive
    notesProvider.addNote(newNote);

    // Clear and Go Back
    speechProvider.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final speechProvider = Provider.of<SpeechProvider>(context);

    // Determine current simple code for dropdown (e.g. 'en', 'ur')
    String currentSpeakingCode = _getSimpleCode(speechProvider.sourceLanguageId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Recording"),
        actions: [
          // Save Button
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            onPressed: () => _saveNote(context),
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Language Selection Area ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: Theme.of(context).cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Speaking Language (NOW SUPPORTS ALL LANGUAGES)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("I'm Speaking:", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    LanguageDropdown(
                      value: currentSpeakingCode, // Shows 'en', 'ur', 'es' etc.
                      onChanged: (val) {
                        if (val != null) {
                          // Convert 'es' -> 'es_ES' and set it
                          String localeId = _getLocaleId(val);
                          speechProvider.setSourceLanguage(localeId);
                        }
                      },
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                // Translate To
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Translate To:", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    LanguageDropdown(
                      value: speechProvider.targetLanguageCode,
                      onChanged: (val) {
                        if (val != null) speechProvider.setTargetLanguage(val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- Input Fields ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: "Title (Optional)",
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Recognized Text
                  Text(
                    "Original Text:",
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    speechProvider.recognizedText.isEmpty
                        ? "Press the mic to start speaking..."
                        : speechProvider.recognizedText,
                    style: TextStyle(
                      fontSize: 18,
                      color: speechProvider.recognizedText.isEmpty ? Colors.grey : null,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Translated Text
                  if (speechProvider.translatedText.isNotEmpty) ...[
                    Text(
                      "Translation:",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      speechProvider.translatedText,
                      style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // --- Bottom Controls ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Visualizer (UPDATED FOR REAL ANIMATION)
                SizedBox(
                  height: 40,
                  child: speechProvider.isListening
                      ? const VoiceVisualizer() // Uses soundLevel now
                      : Text(
                    "Tap mic to record",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 20),

                // Mic Button
                Hero(
                  tag: 'mic_fab',
                  child: GestureDetector(
                    onTap: () {
                      if (speechProvider.isListening) {
                        speechProvider.stopListening();
                      } else {
                        speechProvider.startListening();
                      }
                    },
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: speechProvider.isListening ? Colors.redAccent : Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (speechProvider.isListening ? Colors.redAccent : Theme.of(context).primaryColor).withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(
                        speechProvider.isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- UPDATED Voice Pulse Animation (Real-Time) ---
class VoiceVisualizer extends StatelessWidget {
  const VoiceVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechProvider>(
      builder: (context, provider, child) {
        // Normalize sound level (usually -2 to 10) to 0-15
        final double level = provider.soundLevel.clamp(0.0, 15.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {

            // Create a "Wave" effect: Center bars are taller
            // Multiplier logic to make it look like a wave
            double multiplier = 1.0;
            if (index == 0 || index == 4) multiplier = 0.4;
            if (index == 1 || index == 3) multiplier = 0.7;

            // Calculate height based on volume + multiplier
            // Base height is 5.0 so bars don't disappear completely
            double height = 5.0 + (level * 5 * multiplier);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 100), // Smooth transition
              curve: Curves.easeOut,
              width: 6,
              height: provider.isListening ? height : 5.0,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
            );
          }),
        );
      },
    );
  }
}