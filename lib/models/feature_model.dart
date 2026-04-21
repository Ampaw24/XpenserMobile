import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FeatureModel extends Equatable {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const FeatureModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [title, subtitle, icon, color];
}
