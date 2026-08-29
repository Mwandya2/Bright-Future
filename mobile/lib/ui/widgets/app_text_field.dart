import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Labelled text input with the web app's hairline border treatment.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.enabled = true,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.initialValue,
    this.textCapitalizationWords = false,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? helper;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? initialValue;

  /// Capitalises the first letter of each word (names, titles).
  final bool textCapitalizationWords;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final Color fill = dark ? AppColors.darkSurfaceElevated : Colors.white;
    final Color borderColor = dark ? AppColors.darkHairline : AppColors.hairline;

    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: context.inkColor,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          obscureText: _hidden,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalizationWords
              ? TextCapitalization.words
              : TextCapitalization.none,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          maxLines: _hidden ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: TextStyle(fontSize: 15.5, color: context.inkColor),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helper,
            counterText: '',
            filled: true,
            fillColor: widget.enabled
                ? fill
                : (dark ? AppColors.darkSurface : AppColors.canvasSoft),
            hintStyle: TextStyle(color: context.mutedColor, fontSize: 15),
            helperStyle: TextStyle(color: context.mutedColor, fontSize: 12),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 19, color: context.mutedColor),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 19,
                      color: context.mutedColor,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: outline(borderColor),
            enabledBorder: outline(borderColor),
            disabledBorder: outline(borderColor),
            focusedBorder: outline(AppColors.primary, 1.6),
            errorBorder: outline(AppColors.error),
            focusedErrorBorder: outline(AppColors.error, 1.6),
          ),
        ),
      ],
    );
  }
}
