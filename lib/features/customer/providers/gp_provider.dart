// lib/features/customer/providers/gp_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/auth/providers/auth_provider.dart';

class GPProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider _authProvider;
  Set<String> _favoriteGPs = {};
  bool _isLoading = false;

  GPProvider(this._authProvider) {
    _loadFavorites();
  }

  bool get isLoading => _isLoading;
  Set<String> get favoriteGPs => _favoriteGPs;

  Future<void> _loadFavorites() async {
    if (_authProvider.user == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_authProvider.user!.uid)
          .collection('favorites')
          .doc('gps')
          .get();

      if (doc.exists) {
        final List<dynamic> favorites = doc.data()?['gpIds'] ?? [];
        _favoriteGPs = favorites.map((e) => e.toString()).toSet();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Stream<QuerySnapshot> getGPMissions({
    String? departureCity,
    String? arrivalCity,
    DateTime? departureTime,
    DateTime? arrivalTime,
    int? minCapacity,
    bool favoritesOnly = false,
  }) {
    Query query = _firestore.collection('missions');

    // Basic filters that don't require complex indexes
    query = query.where('status', isEqualTo: 'pending');

    // For favorites, we only filter by gpIds
    if (favoritesOnly) {
      if (_favoriteGPs.isEmpty) {
        query = query.where('gpId', isEqualTo: 'no_favorites'); // This ensures no results
      } else {
        query = query.where('gpId', whereIn: _favoriteGPs.toList().take(10).toList()); // Limit to 10 for performance
      }
      return query.snapshots();
    }

    // For non-favorites view, we'll use simple filters
    if (departureCity != null) {
      query = query.where('departureCity', isEqualTo: departureCity);
    }

    // Return the query with basic sorting
    return query
        .orderBy('departureTime', descending: false)
        .limit(20)
        .snapshots();
  }

  Future<Map<String, dynamic>?> getGPDetails(String gpId) async {
    try {
      final doc = await _firestore.collection('users').doc(gpId).get();
      debugPrint('Got GP details for $gpId: ${doc.data()}');
      return doc.data();
    } catch (e) {
      debugPrint('Error getting GP details: $e');
      return null;
    }
  }

  Future<void> toggleFavorite(String gpId) async {
    if (_authProvider.user == null) return;

    try {
      if (_favoriteGPs.contains(gpId)) {
        _favoriteGPs.remove(gpId);
      } else {
        _favoriteGPs.add(gpId);
      }
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(_authProvider.user!.uid)
          .collection('favorites')
          .doc('gps')
          .set({
        'gpIds': _favoriteGPs.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Revert the change if save fails
      if (_favoriteGPs.contains(gpId)) {
        _favoriteGPs.remove(gpId);
      } else {
        _favoriteGPs.add(gpId);
      }
      notifyListeners();
      debugPrint('Error toggling favorite: $e');
    }
  }
}