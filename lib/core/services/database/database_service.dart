import 'dart:async';

/// Database service interface for storing and retrieving data
abstract class DatabaseService {
  /// Save data to a collection
  Future<String> saveData(String collection, Map<String, dynamic> data, {String? documentId});

  /// Get a document by ID
  Future<Map<String, dynamic>?> getDocument(String collection, String documentId);

  /// Get all documents in a collection
  Future<List<Map<String, dynamic>>> getCollection(String collection);

  /// Query a collection with filters
  Future<List<Map<String, dynamic>>> queryCollection(
    String collection, {
    required List<QueryFilter> filters,
    int? limit,
    String? orderBy,
    bool descending = false,
  });

  /// Stream a document for real-time updates
  Stream<Map<String, dynamic>?> streamDocument(String collection, String documentId);

  /// Stream a collection for real-time updates
  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    List<QueryFilter>? filters,
    int? limit,
    String? orderBy,
    bool descending = false,
  });

  /// Update a document
  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data);

  /// Delete a document
  Future<void> deleteDocument(String collection, String documentId);
}

/// Filter for database queries
class QueryFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;

  QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });
}

/// Database filter operators
enum FilterOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
} 