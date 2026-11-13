import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/widgets/brand_watermark_background.dart';
import 'package:flutter/material.dart';

/// Scrollable form body over the brand watermark, with a primary action
/// pinned to the bottom. Use as a Scaffold `body`.
/// The action rides above the keyboard; dragging the list dismisses it.
class AppFormLayout extends StatelessWidget {
  const AppFormLayout({
    super.key,
    required this.children,
    required this.action,
    this.formKey,
  });

  final List<Widget> children;
  final Widget action;
  final GlobalKey<FormState>? formKey;

  @override
  Widget build(BuildContext context) {
    final gutter = context.contentGutter;
    final body = Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                gutter,
                context.rs(8),
                gutter,
                context.rs(24),
              ),
              children: children,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            context.rs(8),
            gutter,
            context.rs(12),
          ),
          child: SizedBox(width: double.infinity, child: action),
        ),
      ],
    );

    return BrandWatermarkBackground(
      child: SafeArea(
        child: formKey == null ? body : Form(key: formKey, child: body),
      ),
    );
  }
}
