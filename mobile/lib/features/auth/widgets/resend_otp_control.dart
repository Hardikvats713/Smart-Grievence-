import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Resend OTP countdown and actionable link widget.
///
/// Displays "Resend OTP in 00:XX" while cooldown is active.
/// Displays an actionable "Resend OTP" button once cooldown reaches zero.
class ResendOtpControl extends StatefulWidget {
  const ResendOtpControl({
    super.key,
    required this.initialCooldownSeconds,
    required this.onResend,
    this.isResending = false,
  });

  final int initialCooldownSeconds;
  final Future<void> Function() onResend;
  final bool isResending;

  @override
  State<ResendOtpControl> createState() => ResendOtpControlState();
}

class ResendOtpControlState extends State<ResendOtpControl> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialCooldownSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remainingSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _remainingSeconds = 0;
        });
        timer.cancel();
      }
    });
  }

  /// Restarts the countdown with given duration.
  void restartCooldown([int? seconds]) {
    setState(() {
      _remainingSeconds = seconds ?? widget.initialCooldownSeconds;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isResending) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Resending OTP...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      );
    }

    if (_remainingSeconds > 0) {
      return Text(
        'Resend OTP in ${_formatTimer(_remainingSeconds)}',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onResend,
      child: const Text(
        'Resend OTP',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primary,
        ),
      ),
    );
  }
}

