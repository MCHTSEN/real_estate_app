import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/features/auth/providers/auth_provider.dart';
import 'package:real_estate_app/features/home/domain/models/listing_model.dart';
import 'package:real_estate_app/features/home/presentation/widgets/listing_card.dart';
import 'package:real_estate_app/features/home/providers/listing_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('ProfileScreen: build called');
    final authState = ref.watch(authProvider);
    developer.log('ProfileScreen: authState = $authState');

    return authState.when(
      data: (user) {
        developer.log('ProfileScreen: authState.when data: user = $user');
        if (user == null) {
          developer.log('ProfileScreen: User is null, navigating to login');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Giriş yapmanız gerekiyor'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    developer.log('ProfileScreen: Navigating to /login');
                    context.go('/login');
                  },
                  child: const Text('Giriş Yap'),
                ),
              ],
            ),
          );
        }

        developer.log('ProfileScreen: User is logged in, displaying profile');
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.email ?? 'Kullanıcı',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Çıkış Yap'),
                        onPressed: () {
                          developer.log('ProfileScreen: Signing out user');
                          ref.read(authServiceProvider).signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                // User listings
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İlanlarım',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Display user listings
                      Consumer(
                        builder: (context, ref, child) {
                          developer.log('ProfileScreen: Consumer builder called');
                          final userListingsAsync =
                              ref.watch(userListingsProvider(user.uid));
                          developer.log(
                              'ProfileScreen: userListingsAsync = $userListingsAsync');

                          return userListingsAsync.when(
                            data: (listings) {
                              developer.log(
                                  'ProfileScreen: userListingsAsync.when data: listings = $listings');
                              if (listings.isEmpty) {
                                developer.log(
                                    'ProfileScreen: No listings found for user');
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.home_work,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Henüz ilan eklemediniz',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.add),
                                          label: const Text('İlan Ekle'),
                                          onPressed: () {
                                            developer.log(
                                                'ProfileScreen: Navigating to /add-listing');
                                            context.push('/add-listing');
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              developer.log(
                                  'ProfileScreen: Found ${listings.length} listings for user');
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: listings.length,
                                itemBuilder: (context, index) {
                                  developer.log(
                                      'ProfileScreen: Building listing card at index $index');
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child:
                                        ListingCard(listing: listings[index]),
                                  );
                                },
                              );
                            },
                            loading: () {
                              developer.log(
                                  'ProfileScreen: userListingsAsync.when loading');
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            error: (error, stack) {
                              developer.log(
                                  'ProfileScreen: userListingsAsync.when error: $error, stack: $stack');
                              return Center(
                                child: Text('Hata: $error'),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        developer.log('ProfileScreen: authState.when loading');
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stack) {
        developer.log('ProfileScreen: authState.when error: $error, stack: $stack');
        return Center(
          child: Text('Hata: $error'),
        );
      },
    );
  }
}
