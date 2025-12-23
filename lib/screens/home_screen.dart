import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // For Haptic feedback

import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/note_card.dart';
import 'record_screen.dart';
import 'note_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller to handle search text clearing
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access Providers
    final notesProvider = Provider.of<NotesProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Custom Header & Search Bar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  // Top Row: Title + Theme Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Voxa",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          themeProvider.toggleTheme(!themeProvider.isDarkMode);
                        },
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),


                  // Search TextField
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      notesProvider.searchNotes(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search notes...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notesProvider.searchNotes(''); // Reset list
                          FocusScope.of(context).unfocus(); // Hide keyboard
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),

            // --- Notes List ---
            Expanded(
              child: Consumer<NotesProvider>(
                builder: (context, provider, child) {
                  // Empty State
                  if (provider.notes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic_none_outlined,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            "No notes yet.\nTap the mic to start recording!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    );
                  }

                  // List of Notes
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                    itemCount: provider.notes.length,
                    itemBuilder: (context, index) {
                      final note = provider.notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () {
                          // Navigate to View/Edit Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteViewScreen(note: note),
                            ),
                          );
                        },
                        onDelete: () {
                          // Show confirmation dialog before deleting
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Note?"),
                              content: const Text("This cannot be undone."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    provider.deleteNote(note);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // --- Floating Action Button (Record) ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Hero(
        tag: 'mic_fab',
        child: SizedBox(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecordScreen()),
              );
            },
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.mic, size: 32, color: Colors.white),
          ),
        ),
      ),
    );
  }
}