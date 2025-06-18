import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.illustration,
    required this.title,
    required this.text,
  });

  final String? illustration, title, text;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(illustration!, fit: BoxFit.contain),
          ),
        ),
         SizedBox(height: size.height * 0.08),
        Text(
          title!,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
         SizedBox(height: size.height * 0.01),
        Text(
          text!,
            style: GoogleFonts.inter(
            textStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
