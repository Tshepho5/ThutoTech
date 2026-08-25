import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class InputValidators {
  /// Strictly allows only letters, spaces, hyphens, and apostrophes.
  /// Disallows any numeric digits.
  static String? validateTextOnly(String? value, {String fieldName = 'This field', bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return '$fieldName is required.';
      return null;
    }
    final trimmed = value.trim();
    if (RegExp(r'[0-9]').hasMatch(trimmed)) {
      return '$fieldName must only contain letters. Numbers are strictly not allowed.';
    }
    if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(trimmed)) {
      return '$fieldName contains invalid symbols. Only alphabetic characters are allowed.';
    }
    if (trimmed.length < 2) {
      return '$fieldName must be at least 2 characters long.';
    }
    return null;
  }

  /// Strictly allows only digits (0-9). Disallows letters and symbols.
  static String? validateNumberOnly(
    String? value, {
    String fieldName = 'This field',
    bool isRequired = true,
    int? exactLength,
    int? minLength,
    int? maxLength,
    double? minVal,
    double? maxVal,
  }) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return '$fieldName is required.';
      return null;
    }
    final trimmed = value.trim();
    if (RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return '$fieldName must only contain numbers. Letters are strictly not allowed.';
    }
    if (!RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(trimmed)) {
      return '$fieldName must be a valid number without letters or special characters.';
    }
    if (exactLength != null && trimmed.length != exactLength) {
      return '$fieldName must be exactly $exactLength digits.';
    }
    if (minLength != null && trimmed.length < minLength) {
      return '$fieldName must be at least $minLength digits.';
    }
    if (maxLength != null && trimmed.length > maxLength) {
      return '$fieldName cannot exceed $maxLength digits.';
    }
    final numVal = double.tryParse(trimmed);
    if (numVal != null) {
      if (minVal != null && numVal < minVal) {
        return '$fieldName cannot be less than $minVal.';
      }
      if (maxVal != null && numVal > maxVal) {
        return '$fieldName cannot exceed $maxVal.';
      }
    }
    return null;
  }

  /// Validates South African National ID (13 digits, numeric only).
  static String? validateNationalID(String? value, {String fieldName = 'ID Number', bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return '$fieldName is required.';
      return null;
    }
    final trimmed = value.trim();
    if (RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return '$fieldName must only contain numbers. Letters are strictly prohibited.';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      return '$fieldName must only contain digits.';
    }
    if (trimmed.length != 13) {
      return '$fieldName must be exactly 13 digits (Current: ${trimmed.length} digits).';
    }
    return null;
  }

  /// Validates Phone Number (10 digits starting with 0, digits only).
  static String? validatePhoneNumber(String? value, {String fieldName = 'Phone Number', bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return '$fieldName is required.';
      return null;
    }
    final trimmed = value.trim().replaceAll(' ', '');
    if (RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return '$fieldName must only contain numbers. Letters are strictly prohibited.';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(trimmed)) {
      return '$fieldName must be a valid 10-digit number (e.g., 0821234567).';
    }
    return null;
  }

  /// Validates standard Email Address format.
  static String? validateEmail(String? value, {String fieldName = 'Email Address', bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return '$fieldName is required.';
      return null;
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address (e.g., name@example.com).';
    }
    return null;
  }

  /// Validates Password strength
  static String? validatePassword(String? value, {String fieldName = 'Password'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }
    if (value.length < 6) {
      return '$fieldName must be at least 6 characters.';
    }
    return null;
  }
}

enum InputDataType { textOnly, numberOnly, idNumber, phoneNumber, email, password, general }

class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final InputDataType dataType;
  final bool isRequired;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;
  final double? minVal;
  final double? maxVal;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? customValidator;
  final bool isPassword;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.dataType = InputDataType.general,
    this.isRequired = true,
    required this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.minVal,
    this.maxVal,
    this.onChanged,
    this.customValidator,
    this.isPassword = false,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorText;
  bool _touched = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    widget.controller.addListener(_validateLive);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateLive);
    super.dispose();
  }

  void _validateLive() {
    if (!_touched && widget.controller.text.isEmpty) return;
    setState(() {
      _errorText = _runValidation(widget.controller.text);
    });
  }

  String? _runValidation(String? val) {
    if (widget.customValidator != null) {
      return widget.customValidator!(val);
    }
    switch (widget.dataType) {
      case InputDataType.textOnly:
        return InputValidators.validateTextOnly(val, fieldName: widget.label, isRequired: widget.isRequired);
      case InputDataType.numberOnly:
        return InputValidators.validateNumberOnly(
          val,
          fieldName: widget.label,
          isRequired: widget.isRequired,
          exactLength: widget.maxLength,
          minVal: widget.minVal,
          maxVal: widget.maxVal,
        );
      case InputDataType.idNumber:
        return InputValidators.validateNationalID(val, fieldName: widget.label, isRequired: widget.isRequired);
      case InputDataType.phoneNumber:
        return InputValidators.validatePhoneNumber(val, fieldName: widget.label, isRequired: widget.isRequired);
      case InputDataType.email:
        return InputValidators.validateEmail(val, fieldName: widget.label, isRequired: widget.isRequired);
      case InputDataType.password:
        return InputValidators.validatePassword(val, fieldName: widget.label);
      case InputDataType.general:
        if (widget.isRequired && (val == null || val.trim().isEmpty)) {
          return '${widget.label} is required.';
        }
        return null;
    }
  }

  List<TextInputFormatter> _getFormatters() {
    switch (widget.dataType) {
      case InputDataType.textOnly:
        // Filter out digits on typing
        return [
          FilteringTextInputFormatter.deny(RegExp(r'[0-9]'), replacementString: ''),
        ];
      case InputDataType.numberOnly:
      case InputDataType.idNumber:
      case InputDataType.phoneNumber:
        return [
          FilteringTextInputFormatter.digitsOnly,
          if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
        ];
      default:
        return [
          if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
        ];
    }
  }

  TextInputType _getKeyboardType() {
    switch (widget.dataType) {
      case InputDataType.numberOnly:
      case InputDataType.idNumber:
      case InputDataType.phoneNumber:
        return TextInputType.number;
      case InputDataType.email:
        return TextInputType.emailAddress;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label + (widget.isRequired ? ' *' : ' (Optional)'),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: hasError ? AppTheme.dangerRed : (isDark ? Colors.white70 : AppTheme.textDark),
              ),
            ),
            if (widget.dataType == InputDataType.textOnly)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hasError ? AppTheme.dangerRed.withOpacity(0.1) : AppTheme.primaryNavy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Letters only (no numbers)',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: hasError ? AppTheme.dangerRed : AppTheme.secondaryNavy,
                  ),
                ),
              ),
            if (widget.dataType == InputDataType.numberOnly ||
                widget.dataType == InputDataType.idNumber ||
                widget.dataType == InputDataType.phoneNumber)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hasError ? AppTheme.dangerRed.withOpacity(0.1) : AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Numbers only (no letters)',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: hasError ? AppTheme.dangerRed : AppTheme.primaryGreen,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          inputFormatters: _getFormatters(),
          keyboardType: _getKeyboardType(),
          onChanged: (val) {
            _touched = true;
            _validateLive();
            if (widget.onChanged != null) widget.onChanged!(val);
          },
          validator: (val) {
            _touched = true;
            final err = _runValidation(val);
            setState(() => _errorText = err);
            return err;
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(
              widget.prefixIcon,
              color: hasError ? AppTheme.dangerRed : (isDark ? Colors.white60 : AppTheme.secondaryNavy),
              size: 20,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : widget.suffixIcon,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 14, color: AppTheme.dangerRed),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _errorText!,
                  style: GoogleFonts.outfit(
                    color: AppTheme.dangerRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
      ],
    );
  }
}
