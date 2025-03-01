import 'package:cloud_firestore/cloud_firestore.dart';
import '../mock_services.dart';
import '../database/database_service.dart';

/// Firebase implementation of DatabaseService
class FirebaseDatabaseService implements DatabaseService {
  final FirebaseFirestore _firestore;

  FirebaseDatabaseService(this._firestore);

  /// Convert Firestore DocumentSnapshot to Map
  Map<String, dynamic> _convertDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    data['id'] = doc.id; // Add document ID to the data
    return data;
  }

  /// Convert Firestore QueryDocumentSnapshot to Map
  Map<String, dynamic> _convertQueryDocSnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Add document ID to the data
    return data;
  }

  /// Apply query filters
  Query _applyFilters(Query query, List<QueryFilter> filters) {
    Query filteredQuery = query;

    for (final filter in filters) {
      switch (filter.operator) {
        case FilterOperator.isEqualTo:
          filteredQuery =
              filteredQuery.where(filter.field, isEqualTo: filter.value);
          break;
        case FilterOperator.isNotEqualTo:
          filteredQuery =
              filteredQuery.where(filter.field, isNotEqualTo: filter.value);
          break;
        case FilterOperator.isLessThan:
          filteredQuery =
              filteredQuery.where(filter.field, isLessThan: filter.value);
          break;
        case FilterOperator.isLessThanOrEqualTo:
          filteredQuery = filteredQuery.where(filter.field,
              isLessThanOrEqualTo: filter.value);
          break;
        case FilterOperator.isGreaterThan:
          filteredQuery =
              filteredQuery.where(filter.field, isGreaterThan: filter.value);
          break;
        case FilterOperator.isGreaterThanOrEqualTo:
          filteredQuery = filteredQuery.where(filter.field,
              isGreaterThanOrEqualTo: filter.value);
          break;
        case FilterOperator.arrayContains:
          filteredQuery =
              filteredQuery.where(filter.field, arrayContains: filter.value);
          break;
        case FilterOperator.arrayContainsAny:
          filteredQuery =
              filteredQuery.where(filter.field, arrayContainsAny: filter.value);
          break;
        case FilterOperator.whereIn:
          filteredQuery =
              filteredQuery.where(filter.field, whereIn: filter.value);
          break;
        case FilterOperator.whereNotIn:
          filteredQuery =
              filteredQuery.where(filter.field, whereNotIn: filter.value);
          break;
      }
    }

    return filteredQuery;
  }

  @override
  Future<String> saveData(String collection, Map<String, dynamic> data,
      {String? documentId}) async {
    try {
      final collectionRef = _firestore.collection(collection);

      if (documentId != null) {
        // Update existing document
        await collectionRef.doc(documentId).set(data, SetOptions(merge: true));
        return documentId;
      } else {
        // Create new document
        final docRef = await collectionRef.add(data);
        return docRef.id;
      }
    } catch (e) {
      throw Exception('Failed to save data: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getDocument(
      String collection, String documentId) async {
    try {
      final docSnapshot =
          await _firestore.collection(collection).doc(documentId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return _convertDocSnapshot(docSnapshot);
    } catch (e) {
      throw Exception('Failed to get document: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      final querySnapshot = await _firestore.collection(collection).get();

      return querySnapshot.docs
          .map((doc) => _convertQueryDocSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get collection: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> queryCollection(
    String collection, {
    required List<QueryFilter> filters,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters
      query = _applyFilters(query, filters);

      // Apply ordering if specified
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit if specified
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => _convertQueryDocSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to query collection: ${e.toString()}');
    }
  }

  @override
  Stream<Map<String, dynamic>?> streamDocument(
      String collection, String documentId) {
    try {
      return _firestore.collection(collection).doc(documentId).snapshots().map(
          (snapshot) => snapshot.exists ? _convertDocSnapshot(snapshot) : null);
    } catch (e) {
      throw Exception('Failed to stream document: ${e.toString()}');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    List<QueryFilter>? filters,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    try {
      Query query = _firestore.collection(collection);

      // Apply filters if specified
      if (filters != null && filters.isNotEmpty) {
        query = _applyFilters(query, filters);
      }

      // Apply ordering if specified
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit if specified
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => _convertQueryDocSnapshot(doc)).toList());
    } catch (e) {
      throw Exception('Failed to stream collection: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: ${e.toString()}');
    }
  }
}
