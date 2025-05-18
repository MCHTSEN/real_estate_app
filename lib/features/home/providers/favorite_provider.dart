import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_app/features/home/domain/models/listing_model.dart';

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<ListingModel>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<ListingModel>> {
  FavoritesNotifier() : super([]);

  void toggleFavorite(ListingModel listing) {
    if (isFavorite(listing)) {
      state = state.where((item) => item.id != listing.id).toList();
    } else {
      state = [...state, listing];
    }
  }

  bool isFavorite(ListingModel listing) {
    return state.any((item) => item.id == listing.id);
  }
}
