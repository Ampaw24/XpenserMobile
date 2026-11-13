import 'package:expenser/core/utils/responsive/responsive.dart';
import 'package:expenser/core/utils/theme/app_palette.dart';
import 'package:expenser/core/utils/theme/input_decorations.dart';
import 'package:expenser/core/utils/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

/// Large, borderless hero amount entry tinted with [color].
class AppAmountInput extends StatelessWidget {
  const AppAmountInput({
    super.key,
    required this.controller,
    required this.currencyCode,
    required this.color,
    this.onChanged,
    this.errorText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String currencyCode;
  final Color color;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final amountStyle = TextStyle(
      fontSize: context.rs(44),
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color,
    );

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rs(12),
            vertical: context.rs(4),
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(context.rs(100)),
          ),
          child: Text(
            currencyCode,
            style: TextStyle(
              fontSize: context.rs(12),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
        ),
        SizedBox(height: context.rs(10)),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AppTextField.decimalFormatter],
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          cursorColor: color,
          style: amountStyle,
          decoration: bareInputDecoration(
            hintText: '0.00',
            hintStyle: amountStyle.copyWith(
              color: palette.textMuted.withValues(alpha: 0.5),
            ),
          ),
          onChanged: onChanged,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child:
              errorText == null
                  ? SizedBox(height: context.rs(6))
                  : Padding(
                    padding: EdgeInsets.only(top: context.rs(6)),
                    child: Text(
                      errorText!,
                      style: TextStyle(
                        fontSize: context.rs(12),
                        color: palette.danger,
                      ),
                    ),
                  ),
        ),
      ],
    );
  }
}
