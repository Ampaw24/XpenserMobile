import 'package:equatable/equatable.dart';

class OnboardingModel extends Equatable {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [title, description, imagePath];

  OnboardingModel copyWith({
    String? title,
    String? description,
    String? imagePath,
  }) {
    return OnboardingModel(
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() =>
      'OnboardingModel(title: $title, description: $description, imagePath: $imagePath)';
}
