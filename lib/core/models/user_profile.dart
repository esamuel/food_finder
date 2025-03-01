import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile extends Equatable {
  final String id;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final List<String> favoriteItems;
  final List<UserHistory> historyItems;
  final UserPreferences preferences;

  const UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.photoUrl,
    this.favoriteItems = const [],
    this.historyItems = const [],
    this.preferences = const UserPreferences(),
  });

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        photoUrl,
        favoriteItems,
        historyItems,
        preferences
      ];

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    List<String>? favoriteItems,
    List<UserHistory>? historyItems,
    UserPreferences? preferences,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      historyItems: historyItems ?? this.historyItems,
      preferences: preferences ?? this.preferences,
    );
  }

  // Create UserProfile from Firestore document
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      favoriteItems: List<String>.from(json['favoriteItems'] ?? []),
      historyItems: (json['historyItems'] as List<dynamic>?)
              ?.map((e) => UserHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>)
          : const UserPreferences(),
    );
  }

  // Convert UserProfile to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'favoriteItems': favoriteItems,
      'historyItems': historyItems.map((e) => e.toJson()).toList(),
      'preferences': preferences.toJson(),
    };
  }
}

class UserHistory extends Equatable {
  final String foodId;
  final DateTime timestamp;
  final String? note;

  const UserHistory({
    required this.foodId,
    required this.timestamp,
    this.note,
  });

  @override
  List<Object?> get props => [foodId, timestamp, note];

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    return UserHistory(
      foodId: json['foodId'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }
}

class UserPreferences extends Equatable {
  final bool isDarkMode;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final String? defaultLanguage;

  const UserPreferences({
    this.isDarkMode = false,
    this.dietaryRestrictions = const [],
    this.allergies = const [],
    this.defaultLanguage,
  });

  @override
  List<Object?> get props => [
        isDarkMode,
        dietaryRestrictions,
        allergies,
        defaultLanguage,
      ];

  UserPreferences copyWith({
    bool? isDarkMode,
    List<String>? dietaryRestrictions,
    List<String>? allergies,
    String? defaultLanguage,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      allergies: allergies ?? this.allergies,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      defaultLanguage: json['defaultLanguage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'dietaryRestrictions': dietaryRestrictions,
      'allergies': allergies,
      'defaultLanguage': defaultLanguage,
    };
  }
}
