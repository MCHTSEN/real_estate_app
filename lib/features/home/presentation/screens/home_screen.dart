import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/features/auth/providers/auth_provider.dart';
import 'package:real_estate_app/features/home/presentation/widgets/listing_tab.dart';
import 'package:real_estate_app/features/profile/presentation/screens/profile_screen.dart';

final selectedNavIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    // List of widgets to display based on bottom nav selection
    final screens = [
      const ListingTab(listingType: null), // All listings
      const ListingTab(listingType: 'sell'), // Sell listings
      const ListingTab(listingType: 'rent'), // Rent listings
      const ProfileScreen(), // Profile tab
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emlak Uygulaması'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement filter feature
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Filtreleme özelliği yakında!')));
            },
          ),
        ],
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          ref.read(selectedNavIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tümü',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell),
            label: 'Satılık',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Kiralık',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-listing');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
