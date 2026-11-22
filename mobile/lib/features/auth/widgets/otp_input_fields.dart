import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// 6-digit OTP input widget with automatic focus advance, backspace navigation,
/// paste distribution, and error styling.
class OtpInputFields extends StatefulWidget {
  const OtpInputFields({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.hasError = false,
  });

  /// Called whenever the entered OTP string changes.
  final ValueChanged<String> onChanged;

  /// Called when all 6 digits are filled.
  final ValueChanged<String>? onCompleted;

  /// Whether an error state is active (styles borders red).
  final bool hasError;

  @override
  State<OtpInputFields> createState() => OtpInputFieldsState();
}

class OtpInputFieldsState extends State<OtpInputFields> {
  static const int _length = 6;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Returns current 6-character OTP (can have fewer if incomplete).
  String get otpValue => _controllers.map((c) => c.text).join();

  /// Clears all 6 boxes and focuses the first box.
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    widget.onChanged('');
  }

  void _onDigitChanged(int index, String value) {
    // Check if user pasted multiple digits (e.g. "123456")
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 1) {
      _distributePastedDigits(digitsOnly);
      return;
    }

    if (value.isNotEmpty) {
      // 1 digit entered
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = TextSelection.collapsed(
        offset: _controllers[index].text.length,
      );

      // Auto-advance to next box
      if (index < _length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last box filled — unfocus or keep focused
        _focusNodes[index].unfocus();
      }
    }

    final currentOtp = otpValue;
    widget.onChanged(currentOtp);
    if (currentOtp.length == _length) {
      widget.onCompleted?.call(currentOtp);
    }
    setState(() {});
  }

  void _distributePastedDigits(String pastedText) {
    final cleanDigits = pastedText.replaceAll(RegExp(r'\D'), '');
    final takeCount = cleanDigits.length.clamp(0, _length);

    for (int i = 0; i < _length; i++) {
      if (i < takeCount) {
        _controllers[i].text = cleanDigits[i];
      } else {
        _controllers[i].clear();
      }
    }

    if (takeCount < _length) {
      _focusNodes[takeCount].requestFocus();
    } else {
      _focusNodes[_length - 1].unfocus();
    }

    final currentOtp = otpValue;
    widget.onChanged(currentOtp);
    if (currentOtp.length == _length) {
      widget.onCompleted?.call(currentOtp);
    }
    setState(() {});
  }

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
        widget.onChanged(otpValue);
        setState(() {});
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive box dimensions
        final double totalWidth = constraints.maxWidth;
        // Total spacing = 5 gaps of 8-10px
        const double spacing = 8.0;
        final double boxWidth =
            ((totalWidth - (spacing * (_length - 1))) / _length).clamp(38.0, 52.0);
        final double boxHeight = (boxWidth * 1.18).clamp(46.0, 60.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_length, (index) {
            final isFocused = _focusNodes[index].hasFocus;
            final hasValue = _controllers[index].text.isNotEmpty;

            Color borderColor;
            double borderWidth;
            if (widget.hasError) {
              borderColor = AppColors.error;
              borderWidth = 1.5;
            } else if (isFocused) {
              borderColor = AppColors.primary;
              borderWidth = 2.0;
            } else if (hasValue) {
              borderColor = AppColors.primary.withValues(alpha: 0.6);
              borderWidth = 1.2;
            } else {
              borderColor = AppColors.border;
              borderWidth = 1.2;
            }

            return SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Focus(
                onKeyEvent: (_, event) => _handleKeyEvent(index, event),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: borderWidth,
                    ),
                    boxShadow: isFocused
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) => _onDigitChanged(index, val),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
