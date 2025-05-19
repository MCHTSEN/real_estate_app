import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:real_estate_app/features/auth/providers/auth_provider.dart';
import 'package:real_estate_app/features/home/presentation/widgets/listing_tab.dart';
import 'package:real_estate_app/features/home/presentation/screens/favorites_screen.dart';
import 'package:real_estate_app/features/listing/presentation/screens/add_listing_screen.dart';
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
      const FavoritesScreen(), // Favorites screen
      const AddListingScreen(), // Add listing tab
      const ProfileScreen(), // Profile tab
    ];

    return Scaffold(
      body: SafeArea(child: screens[selectedIndex]),
      bottomNavigationBar:
          _buildBottomNavigationBar(context, ref, selectedIndex),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, WidgetRef ref, int selectedIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: (index) {
                ref.read(selectedNavIndexProvider.notifier).state = index;
              },
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        selectedIndex == 0 ? Colors.black : Colors.white,
                    child: Icon(
                      Icons.home_outlined,
                      size: 26,
                      color: selectedIndex == 0 ? Colors.white : Colors.black,
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        selectedIndex == 1 ? Colors.black : Colors.white,
                    child: Icon(
                      Icons.favorite_border,
                      size: 26,
                      color: selectedIndex == 1 ? Colors.white : Colors.black,
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        selectedIndex == 2 ? Colors.black : Colors.white,
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 26,
                      color: selectedIndex == 2 ? Colors.white : Colors.black,
                    ),
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        selectedIndex == 3 ? Colors.black : Colors.white,
                    child: Icon(
                      Icons.person_outline,
                      size: 26,
                      color: selectedIndex == 3 ? Colors.white : Colors.black,
                    ),
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.push('/add-listing');
      },
      child: const Icon(Icons.add),
    );
  }
}
