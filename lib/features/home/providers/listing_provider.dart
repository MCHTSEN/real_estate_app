import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_app/features/home/domain/models/listing_model.dart';

// Firestore collection reference
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  developer.log('firestoreProvider: Getting Firestore instance');
  return FirebaseFirestore.instance;
});

// Listing repository provider
class ListingRepository {
  final FirebaseFirestore _firestore;

  ListingRepository(this._firestore);

  // Get all listings
  Stream<List<ListingModel>> getListings({String? listingType}) {
    developer.log('getListings: called with listingType: $listingType');
    Query query = _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true);

    // Filter by type if specified
    if (listingType != null) {
      query = query.where('type', isEqualTo: listingType);
      developer.log('getListings: filtering by type: $listingType');
    }

    return query.snapshots().map((snapshot) {
      developer.log('getListings: mapping snapshot');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ListingModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    });
  }

  // Get listings by user ID
  Stream<List<ListingModel>> getUserListings(String userId) {
    developer.log('getUserListings: called with userId: $userId');
    return _firestore
        .collection('listings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      developer.log('getUserListings: mapping snapshot');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ListingModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    });
  }

  // Add a new listing
  Future<void> addListing(Map<String, dynamic> listingData) async {
    developer.log('addListing: called with listingData: $listingData');
    await _firestore.collection('listings').add({
      ...listingData,
      'createdAt': FieldValue.serverTimestamp(),
    });
    developer.log('addListing: listing added successfully');
  }
}

// Listing repository provider
final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  developer.log('listingRepositoryProvider: creating ListingRepository');
  final firestore = ref.watch(firestoreProvider);
  return ListingRepository(firestore);
});

// Listings stream provider
final listingsProvider =
    StreamProvider.family<List<ListingModel>, String?>((ref, listingType) {
  developer.log('listingsProvider: called with listingType: $listingType');
  final repository = ref.watch(listingRepositoryProvider);
  return repository.getListings(listingType: listingType);
});

// User listings stream provider
final userListingsProvider =
    StreamProvider.family<List<ListingModel>, String>((ref, userId) {
  developer.log('userListingsProvider: called with userId: $userId');
  final repository = ref.watch(listingRepositoryProvider);
  return repository.getUserListings(userId);
});
