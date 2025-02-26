import 'package:equatable/equatable.dart';

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
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      favoriteItems: json['favoriteItems'] != null 
          ? List<String>.from(json['favoriteItems'] as List)
          : [],
      historyItems: json['historyItems'] != null 
          ? (json['historyItems'] as List)
              .map((e) => UserHistory.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      preferences: json['preferences'] != null 
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : const UserPreferences(),
    );
  }
  
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
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}

class UserPreferences extends Equatable {
  final bool darkMode;
  final String? dietaryRestriction;
  final List<String> allergies;
  final bool notificationsEnabled;
  
  const UserPreferences({
    this.darkMode = false,
    this.dietaryRestriction,
    this.allergies = const [],
    this.notificationsEnabled = true,
  });
  
  @override
  List<Object?> get props => [darkMode, dietaryRestriction, allergies, notificationsEnabled];
  
  UserPreferences copyWith({
    bool? darkMode,
    String? dietaryRestriction,
    List<String>? allergies,
    bool? notificationsEnabled,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      dietaryRestriction: dietaryRestriction ?? this.dietaryRestriction,
      allergies: allergies ?? this.allergies,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] as bool? ?? false,
      dietaryRestriction: json['dietaryRestriction'] as String?,
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies'] as List)
          : [],
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'dietaryRestriction': dietaryRestriction,
      'allergies': allergies,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}