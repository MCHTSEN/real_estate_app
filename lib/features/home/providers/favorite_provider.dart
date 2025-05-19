import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_app/features/home/domain/models/listing_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _favoritesKey = 'favorites';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<ListingModel>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<ListingModel>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList(_favoritesKey);
    if (favoritesJson != null) {
      state = favoritesJson
          .map((json) => ListingModel.fromJson(jsonDecode(json)))
          .toList();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson =
        state.map((listing) => jsonEncode(listing.toJson())).toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  Future<void> toggleFavorite(ListingModel listing) async {
    if (isFavorite(listing)) {
      state = state.where((item) => item.id != listing.id).toList();
    } else {
      state = [...state, listing];
    }
    await _saveFavorites();
  }

  bool isFavorite(ListingModel listing) {
    return state.any((item) => item.id == listing.id);
  }
}
