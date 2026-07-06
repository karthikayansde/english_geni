import 'dart:async'; // Required for Timer
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import '../../shared/widgets/smart_form_fields/smart_form.dart';
import '../../shared/widgets/smart_form_fields/field_config.dart';

class OtpForm extends SmartForm {
  @override
  Map<String, FieldConfig> get configs => {
        'otp': FieldConfig.text(
          key: 'otp',
          label: AppStrings.fieldOtp,
          keyboardType: TextInputType.number,
          required: true,
          validators: [
            Validators.minLength(6),
            Validators.maxLength(6),
          ],
          validationMessages: {
            ValidationMessage.required: (_) => AppStrings.valRequiredOtp,
            ValidationMessage.minLength: (_) => AppStrings.valInvalidOtp,
            ValidationMessage.maxLength: (_) => AppStrings.valInvalidOtp,
          },
        ),
      };

  @override
  void initForm({Map<String, dynamic>? initialValues}) {
    formGroup = FormGroup({
      'otp': FormControl<String>(
        value: initialValues?['otp'] as String?,
        validators: [
          Validators.required,
          Validators.pattern(r'^\d{6}$'),
        ],
      ),
    });
  }
}

class OtpDialog extends StatefulWidget {
  const OtpDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: const OtpDialog(),
      ),
    );
  }

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final OtpForm _otpForm = OtpForm();
  Timer? _timer;
  int _secondsRemaining = 30;

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
      _secondsRemaining = 30;
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
    return ScaffoldWrapper(
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
                      onPressed: () => Navigator.of(context).pop(false),
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
                              onPressed: form.valid
                                  ? () {
                                      // Verify OTP logic
                                      Navigator.of(context).pop(true);
                                    }
                                  : () {
                                      _otpForm.markAllTouched();
                                    },
                              child: Text(
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
                          onTap: () {
                            // Trigger resend OTP logic
                            _startTimer();
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
        );
      },
    );
  }
}
