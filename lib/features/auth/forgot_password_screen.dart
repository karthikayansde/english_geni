import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import '../../shared/widgets/smart_pop_scope.dart';
import '../../shared/widgets/smart_form_fields/smart_form.dart';
import '../../shared/widgets/smart_form_fields/field_config.dart';
import '../../shared/widgets/top_head_image.dart';
import 'otp_dialog.dart';

class ForgotPasswordForm extends SmartForm {
  @override
  Map<String, FieldConfig> get configs => {
        'email': FieldConfig.text(
          key: 'email',
          label: AppStrings.fieldGmail,
          keyboardType: TextInputType.emailAddress,
          required: true,
          validators: [Validators.email],
          validationMessages: {
            ValidationMessage.required: (_) => AppStrings.valRequiredGmail,
            ValidationMessage.email: (_) => AppStrings.valInvalidGmail,
          },
        ),
      };
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordForm _forgotPasswordForm = ForgotPasswordForm();

  @override
  void initState() {
    super.initState();
    _forgotPasswordForm.initForm();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (context, theme, textStyle, colors) {
        final styles = AppTextStyles(textStyle, colors);

        return SmartPopScope(
          onPopInvoked: () => Navigator.of(context).pop(),
          exitMessage: AppStrings.backPressGoBack,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              bottom: true,
              top: false,
              right: true,
              left: true,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.scaffoldPaddingHorizontal,
                      right: AppDimensions.scaffoldPaddingHorizontal,
                      bottom: AppDimensions.scaffoldPaddingVertical,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: AppDimensions.formMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const TopHeadImage(),
                            const SizedBox(height: AppDimensions.xl),
                            Text(
                              AppStrings.forgotPasswordTitle,
                              style: styles.screenTitle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            Text(
                              AppStrings.forgotPasswordSubtitle,
                              style: styles.screenSubtitle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.huge),
                            _forgotPasswordForm.formGroupWrap(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _forgotPasswordForm.buildWidget('email'),
                                  const SizedBox(height: AppDimensions.huge),
                                  ReactiveFormConsumer(
                                    builder: (context, form, child) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colors.primary,
                                          foregroundColor: colors.onPrimary,
                                          minimumSize: const Size.fromHeight(AppDimensions.buttonHeightLarge),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: form.valid
                                            ? () async {
                                                await OtpDialog.show(context);
                                              }
                                            : () {
                                                _forgotPasswordForm.markAllTouched();
                                              },
                                        child: Text(
                                          AppStrings.forgotPasswordBtn,
                                          style: styles.buttonLabelOnPrimary,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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
