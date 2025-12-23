import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'models/note_model.dart';
import 'providers/theme_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/speech_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive
  await Hive.initFlutter();

  // 2. Register the Adapter (Generated Code)
  Hive.registerAdapter(NoteModelAdapter());

  // 3. Open the Box (Database)
  await Hive.openBox<NoteModel>(AppConstants.notesBox);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Wrap App in MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Voice Notes App',
            // 5. Apply Theme from Provider
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}