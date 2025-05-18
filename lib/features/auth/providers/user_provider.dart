import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_estate_app/features/auth/domain/user_model.dart';

// Provider for the current Firebase user
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider for UserModel (data from Firestore 'users' collection)
final userProvider = StreamProvider<UserModel?>((ref) {
  final firebaseUser = ref.watch(firebaseUserProvider).asData?.value;
  if (firebaseUser == null) {
    return Stream.value(null); // No Firebase user, so no UserModel
  }

  final firestore = FirebaseFirestore.instance;
  final docRef = firestore.collection('users').doc(firebaseUser.uid);

  return docRef.snapshots().map((snapshot) {
    if (snapshot.exists) {
      return UserModel.fromFirestore(snapshot, null);
    } else {
      return null; // User document doesn't exist in Firestore
    }
  });
});

// StateNotifier for managing navigation to UserDetailsScreen
final userDetailsCompletionNotifierProvider =
    StateNotifierProvider<UserDetailsCompletionNotifier, bool>((ref) {
  return UserDetailsCompletionNotifier(ref);
});

class UserDetailsCompletionNotifier extends StateNotifier<bool> {
  final Ref _ref;
  UserDetailsCompletionNotifier(this._ref) : super(false) {
    // Listen to dependent providers and update state accordingly
    _ref.listen<AsyncValue<User?>>(
        firebaseUserProvider, (_, __) => _determineCompletionState());
    _ref.listen<AsyncValue<UserModel?>>(
        userProvider, (_, __) => _determineCompletionState());
    // Initial check in case providers are already resolved when notifier is created.
    // Wrap in Future.microtask to ensure it runs after the current build cycle if called during one.
    Future.microtask(() => _determineCompletionState());
  }

  void _determineCompletionState() {
    final firebaseUserAsync = _ref.read(firebaseUserProvider);
    final userModelAsync = _ref.read(userProvider);

    // If either provider is still loading, we can't definitively say details are missing.
    // The router's redirect logic already checks userProvider.isLoading.
    // Setting state to false here ensures needsUserDetailsCompletion is false during loading.
    if (firebaseUserAsync.isLoading || userModelAsync.isLoading) {
      if (state != false) state = false;
      return;
    }

    final firebaseUser = firebaseUserAsync.asData?.value;

    if (firebaseUser == null) {
      // Not logged in, so details are not "missing" for completion.
      if (state != false) state = false;
      return;
    }

    // User is logged in. Now check UserModel.
    final userModel = userModelAsync.asData?.value;
    final userModelHasError = userModelAsync.hasError;

    if (userModel == null && !userModelHasError) {
      // Logged in, UserModel is null, not loading, and no error fetching it.
      // This means details are missing and need to be completed.
      if (state != true) state = true;
    } else {
      // Logged in and UserModel exists, or there was an error fetching UserModel,
      // or userModel was loading (covered above), or user is not logged in.
      // In these cases, details are not considered "missing for completion".
      if (state != false) state = false;
    }
  }

  void detailsCompleted() {
    // Called when user submits the details form.
    // Optimistically set to false. The userProvider listener will also update state.
    if (state != false) state = false;
  }

  // Removed checkUserDetails method
}
