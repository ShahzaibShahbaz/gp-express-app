// lib/features/customer/providers/request_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';
import '../../auth/providers/auth_provider.dart';

class RequestProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider _authProvider;
  bool _isLoading = false;
  String? _error;

  RequestProvider(this._authProvider);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<DocumentReference<Map<String, dynamic>>?> submitRequest({
    required String packageType,
    required double weight,
    required String departureCountry,
    required String departureCity,
    required String arrivalCountry,
    required String arrivalCity,
    required DateTime earliestDepartureTime,
    required DateTime latestArrivalTime,
    required bool isFragile,
  }) async {
    if (_authProvider.user == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create timestamp for server-side consistency
      final now = FieldValue.serverTimestamp();

      final data = {
        'customerId': _authProvider.user!.uid,
        'packageType': packageType,
        'weight': weight,
        'departureCountry': departureCountry,
        'departureCity': departureCity,
        'arrivalCountry': arrivalCountry,
        'arrivalCity': arrivalCity,
        'earliestDepartureTime': Timestamp.fromDate(earliestDepartureTime),  // Convert to Timestamp
        'latestArrivalTime': Timestamp.fromDate(latestArrivalTime),  // Convert to Timestamp
        'isFragile': isFragile,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'gpId': null,
        'updatedAt': FieldValue.serverTimestamp()
      };

      // Debug log
      print('Submitting request with data: $data');

      // Add document and get the reference
      final docRef = await _firestore.collection('requests').add(data);

      // Debug log
      print('Request submitted with ID: ${docRef.id}');

      _isLoading = false;
      notifyListeners();
      return docRef; // Return the DocumentReference instead of boolean
    } catch (e) {
      print('Error submitting request: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null; // Return null instead of false
    }
  }

  Stream<List<RequestModel>> getMyRequests() {
    if (_authProvider.user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('requests')
        .where('customerId', isEqualTo: _authProvider.user!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RequestModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}