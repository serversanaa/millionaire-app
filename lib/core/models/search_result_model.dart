import 'package:flutter/material.dart';

/// ✅ Search Result Model (محسّن)
class SearchResult<T> {
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final Color color;
  final T data;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    required this.color,
    required this.data,
  });
}
