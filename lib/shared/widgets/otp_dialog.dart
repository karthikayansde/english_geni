import 'dart:async'; // Required for Timer
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import 'scaffold_wrapper.dart';
import 'smart_form_fields/smart_form.dart';
import 'smart_form_fields/field_config.dart';
import 'smart_form_fields/app_fields.dart';
import '../../core/services/smart_snack_bars.dart';

class OtpForm extends SmartForm {
  @override
  Map<String, FieldConfig> get configs => {
        'otp': AppFields.otp(),
      };
}

class OtpDialog extends StatefulWidget {
  final String email;
  final Future<void> Function(String otp) onVerify;
  final Future<void> Function() onResend;

  const OtpDialog({
    super.key,
    required this.email,
    required this.onVerify,
    required this.onResend,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String email,
    required Future<void> Function(String otp) onVerify,
    required Future<void> Function() onResend,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      barrierDismissible: false, // Prevent dismissing by tapping outside when operations are active
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: OtpDialog(
          email: email,
          onVerify: onVerify,
          onResend: onResend,
        ),
      ),
    );
  }

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final OtpForm _otpForm = OtpForm();
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpForm.initForm();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: ScaffoldWrapper(
        builder: (context, theme, textStyle, colors) {
          final styles = AppTextStyles(textStyle, colors);

          return Dialog(
            backgroundColor: theme.dialogBackgroundColor ?? colors.surfaceContainerHigh,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppDimensions.formMaxWidth),
              child: AbsorbPointer(
                absorbing: _isLoading,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close, color: colors.onSurfaceVariant),
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(false),
                        ),
                      ),
                      Text(
                        AppStrings.otpTitle,
                        style: styles.appBarTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        AppStrings.otpSubtitle,
                        style: styles.screenSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      _otpForm.formGroupWrap(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _otpForm.buildWidget('otp'),
                            const SizedBox(height: AppDimensions.xl),
                            ReactiveFormConsumer(
                              builder: (context, form, child) {
                                return FilledButton(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(AppDimensions.buttonHeightLarge),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                    ),
                                  ),
                                  onPressed: (form.valid && !_isLoading)
                                      ? () async {
                                          try {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            final token = form.control('otp').value as String;
                                            await widget.onVerify(token);
                                            if (mounted) {
                                              Navigator.of(context).pop(true);
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                            SmartSnackBars.show(
                                              message: e.toString().replaceAll('Exception: ', ''),
                                              type: NotificationType.error,
                                            );
                                          }
                                        }
                                      : () {
                                          if (!_isLoading) {
                                            _otpForm.markAllTouched();
                                          }
                                        },
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                                          ),
                                        )
                                      : Text(
                                          AppStrings.otpBtn,
                                          style: styles.buttonLabelOnPrimary,
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_secondsRemaining > 0) ...[
                            Text(
                              "Resend OTP in ${_secondsRemaining}s",
                              style: styles.actionTextSecondary,
                            ),
                          ] else ...[
                            Text(
                              AppStrings.resendOtpText,
                              style: styles.actionTextSecondary,
                            ),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () async {
                                      try {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await widget.onResend();
                                        SmartSnackBars.show(
                                          message: 'Verification code resent!',
                                          type: NotificationType.success,
                                        );
                                        _startTimer();
                                      } catch (e) {
                                        SmartSnackBars.show(
                                          message: e.toString().replaceAll('Exception: ', ''),
                                          type: NotificationType.error,
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      }
                                    },
                              child: Text(
                                AppStrings.resendOtpAction,
                                style: styles.actionLinkLabel,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
