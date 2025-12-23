import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

class SpeechProvider extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  final GoogleTranslator _translator = GoogleTranslator();

  bool _isListening = false;
  String _recognizedText = "";
  String _translatedText = "";
  double _soundLevel = 0.0; // <--- New Variable for Voice Pitch

  // Default languages
  String _sourceLanguageId = 'en_US';
  String _targetLanguageCode = 'en';

  // Getters
  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  String get translatedText => _translatedText;
  double get soundLevel => _soundLevel; // <--- Getter
  String get sourceLanguageId => _sourceLanguageId;
  String get targetLanguageCode => _targetLanguageCode;

  Future<bool> initSpeech() async {
    bool available = await _speech.initialize(
      onError: (val) => print('onError: $val'),
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          _isListening = false;
          _soundLevel = 0.0; // Reset wave when done
          notifyListeners();
        }
      },
    );
    return available;
  }

  void setSourceLanguage(String langId) {
    _sourceLanguageId = langId;
    notifyListeners();
  }

  void setTargetLanguage(String langCode) {
    _targetLanguageCode = langCode;
    notifyListeners();
  }

  void startListening() async {
    _recognizedText = "";
    _translatedText = "";
    _isListening = true;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        if (result.finalResult) {
          _isListening = false;
          _soundLevel = 0.0; // Stop wave
          translateText();
        }
        notifyListeners();
      },
      // --- REAL TIME SOUND LISTENER ---
      onSoundLevelChange: (level) {
        // Level usually ranges from -2 to 10. We normalize it for UI.
        _soundLevel = level;
        notifyListeners();
      },
      localeId: _sourceLanguageId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
  }

  void stopListening() async {
    await _speech.stop();
    _isListening = false;
    _soundLevel = 0.0;
    notifyListeners();
  }

  Future<void> translateText() async {
    if (_recognizedText.isEmpty) return;

    try {
      var translation = await _translator.translate(
        _recognizedText,
        to: _targetLanguageCode,
      );
      _translatedText = translation.text;
      notifyListeners();
    } catch (e) {
      _translatedText = "Error translating text.";
      notifyListeners();
    }
  }

  void clear() {
    _recognizedText = "";
    _translatedText = "";
    _soundLevel = 0.0;
    notifyListeners();
  }
}