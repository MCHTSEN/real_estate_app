import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_app/features/home/domain/models/listing_model.dart';
import 'package:real_estate_app/features/home/providers/listing_provider.dart';
import 'package:real_estate_app/features/home/presentation/widgets/listing_card.dart';

final selectedFilterProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFiltersProvider = StateProvider<Set<String>>((ref) => {});
final isFilterMenuOpenProvider = StateProvider<bool>((ref) => false);

// Provider for available filter options
final filterOptionsProvider = Provider<Map<String, Set<String>>>((ref) {
  final listingsAsyncValue = ref.watch(listingsProvider(null));

  return listingsAsyncValue.when(
    data: (listings) {
      // Extract unique locations and room counts
      final locations = listings.map((l) => l.location).toSet();
      final roomCounts = listings.map((l) => '${l.roomCount} oda').toSet();

      return {
        'Konumlar': locations,
        'Oda Sayısı': roomCounts,
      };
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

class ListingTab extends ConsumerWidget {
  final String? listingType; // null for all, 'sell', 'rent'

  const ListingTab({
    super.key,
    required this.listingType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedFilterProvider);
    final effectiveListingType = listingType ?? selectedFilter;
    final listingsAsyncValue =
        ref.watch(listingsProvider(effectiveListingType));
    final isFilterMenuOpen = ref.watch(isFilterMenuOpenProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedFilters = ref.watch(selectedFiltersProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Adres, oda sayısı veya özellik ara...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: isFilterMenuOpen
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      ref.read(isFilterMenuOpenProvider.notifier).state =
                          !isFilterMenuOpen;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.filter_list,
                        color: isFilterMenuOpen ? Colors.white : Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isFilterMenuOpen) _buildFilterOptions(context, ref),
        if (listingType == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildFilterChips(context, ref),
          ),
        Expanded(
          child: listingsAsyncValue.when(
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
                        effectiveListingType == null
                            ? 'Henüz hiç ilan yok'
                            : effectiveListingType == 'sell'
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

              // Filter listings based on search query and selected filters
              final filteredListings = listings.where((listing) {
                final matchesSearch = searchQuery.isEmpty ||
                    listing.title
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    listing.description
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    listing.location
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());

                final matchesFilters = selectedFilters.isEmpty ||
                    selectedFilters.every((filter) {
                      // Handle room count filters
                      if (filter.contains('oda')) {
                        final roomCount = int.parse(filter.split(' ')[0]);
                        return listing.roomCount == roomCount;
                      }
                      // Handle location filters
                      return listing.location
                          .toLowerCase()
                          .contains(filter.toLowerCase());
                    });

                return matchesSearch && matchesFilters;
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredListings.length,
                itemBuilder: (context, index) {
                  final listing = filteredListings[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
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
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOptions(BuildContext context, WidgetRef ref) {
    final selectedFilters = ref.watch(selectedFiltersProvider);
    final filterOptions = ref.watch(filterOptionsProvider);

    if (filterOptions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtreler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...filterOptions.entries.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.key,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.value.map((filter) {
                    final isSelected = selectedFilters.contains(filter);
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(selectedFiltersProvider.notifier).state = {
                          ...selectedFilters.where((f) => f != filter),
                          if (selected) filter,
                        };
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: Row(
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 18,
                    color: selectedFilter == null ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  const Text('Tümü'),
                ],
              ),
              selected: selectedFilter == null,
              onSelected: (bool selected) {
                ref.read(selectedFilterProvider.notifier).state = null;
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: selectedFilter == null ? Colors.white : Colors.black,
                fontWeight: selectedFilter == null
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: Row(
                children: [
                  Icon(
                    Icons.sell_outlined,
                    size: 18,
                    color:
                        selectedFilter == 'sell' ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  const Text('Satılık'),
                ],
              ),
              selected: selectedFilter == 'sell',
              onSelected: (bool selected) {
                ref.read(selectedFilterProvider.notifier).state =
                    selected ? 'sell' : null;
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: selectedFilter == 'sell' ? Colors.white : Colors.black,
                fontWeight: selectedFilter == 'sell'
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: Row(
                children: [
                  Icon(
                    Icons.house_outlined,
                    size: 18,
                    color:
                        selectedFilter == 'rent' ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  const Text('Kiralık'),
                ],
              ),
              selected: selectedFilter == 'rent',
              onSelected: (bool selected) {
                ref.read(selectedFilterProvider.notifier).state =
                    selected ? 'rent' : null;
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: selectedFilter == 'rent' ? Colors.white : Colors.black,
                fontWeight: selectedFilter == 'rent'
                    ? FontWeight.w500
                    : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
