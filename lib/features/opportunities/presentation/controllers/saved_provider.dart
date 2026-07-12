import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedNotifier extends StateNotifier<Set<String>> {
  SavedNotifier() : super({});

  void toggleSave(String oppId) {
    if (state.contains(oppId)) {
      state = {...state}..remove(oppId);
    } else {
      state = {...state, oppId};
    }
  }

  bool isSaved(String oppId) => state.contains(oppId);
}

final savedProvider = StateNotifierProvider<SavedNotifier, Set<String>>((ref) {
  return SavedNotifier();
});
