import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_app/features/home/domain/models/listing_model.dart';
import 'package:real_estate_app/features/home/providers/listing_provider.dart';
import 'package:real_estate_app/features/home/presentation/widgets/listing_card.dart';

class ListingTab extends ConsumerWidget {
  final String? listingType; // null for all, 'sell', 'rent'

  const ListingTab({
    super.key,
    required this.listingType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsyncValue = ref.watch(listingsProvider(listingType));

    return listingsAsyncValue.when(
      data: (listings) {
        if (listings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.home_work,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  listingType == null
                      ? 'Henüz hiç ilan yok'
                      : listingType == 'sell'
                          ? 'Henüz satılık ilan yok'
                          : 'Henüz kiralık ilan yok',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListingCard(listing: listing),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }
}
