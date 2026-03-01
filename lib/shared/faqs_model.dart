import 'package:flutter/material.dart';

/// FAQ item model matching the Kotlin [FAQsModel] data class.
///
/// Used in the Support/FAQ screen.
class FAQsModel {
  // PUBLIC_INTERFACE
  /// Creates a FAQ model with an icon and title.
  const FAQsModel({
    required this.icon,
    required this.title,
  });

  /// The icon to display.
  final IconData icon;

  /// The FAQ category title.
  final String title;
}
