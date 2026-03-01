/// User data model matching the Kotlin [UserModel] data class.
///
/// Used for storing user profile information.
class UserModel {
  // PUBLIC_INTERFACE
  /// Creates a [UserModel] instance.
  UserModel({
    required this.email,
    this.name,
    this.username = '',
    this.imageUrl,
    this.bio,
    this.token = '',
  });

  /// User email address.
  final String email;

  /// User display name.
  final String? name;

  /// Username (often empty in current usage).
  final String username;

  /// Profile image URL.
  final String? imageUrl;

  /// User bio text.
  final String? bio;

  /// FCM token for push notifications.
  final String token;

  // PUBLIC_INTERFACE
  /// Converts this model to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'image_url': imageUrl,
      'bio': bio,
      'token': token,
    };
  }

  // PUBLIC_INTERFACE
  /// Creates a [UserModel] from a map (e.g., from database).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      name: map['name'],
      username: map['username'] ?? '',
      imageUrl: map['image_url'],
      bio: map['bio'],
      token: map['token'] ?? '',
    );
  }
}
