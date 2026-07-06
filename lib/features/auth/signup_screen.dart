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
import 'login_screen.dart';

class SignUpForm extends SmartForm {
  @override
  Map<String, FieldConfig> get configs => {
        'name': FieldConfig.text(
          key: 'name',
          label: AppStrings.fieldName,
          required: true,
          validationMessages: {
            ValidationMessage.required: (_) => AppStrings.valRequiredName,
          },
        ),
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
        'password': FieldConfig.text(
          key: 'password',
          label: AppStrings.fieldPassword,
          isPasswordField: true,
          required: true,
          maxLines: 1,
          validators: [Validators.minLength(6)],
          validationMessages: {
            ValidationMessage.required: (_) => AppStrings.valRequiredPassword,
            ValidationMessage.minLength: (_) => AppStrings.valMinLengthPassword,
          },
        ),
        'confirmPassword': FieldConfig.text(
          key: 'confirmPassword',
          label: AppStrings.fieldConfirmPassword,
          isPasswordField: true,
          required: true,
          maxLines: 1,
          validationMessages: {
            ValidationMessage.required: (_) => AppStrings.valRequiredConfirmPassword,
            'mustMatch': (_) => AppStrings.valPasswordMismatch,
          },
        ),
      };

  @override
  void initForm({Map<String, dynamic>? initialValues}) {
    formGroup = FormGroup(
      {
        'name': FormControl<String>(
          value: initialValues?['name'] as String?,
          validators: [Validators.required],
        ),
        'email': FormControl<String>(
          value: initialValues?['email'] as String?,
          validators: [Validators.required, Validators.email],
        ),
        'password': FormControl<String>(
          value: initialValues?['password'] as String?,
          validators: [Validators.required, Validators.minLength(6)],
        ),
        'confirmPassword': FormControl<String>(
          value: initialValues?['confirmPassword'] as String?,
          validators: [Validators.required],
        ),
      },
      validators: [
        Validators.mustMatch('password', 'confirmPassword'),
      ],
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpForm _signUpForm = SignUpForm();

  @override
  void initState() {
    super.initState();
    _signUpForm.initForm();
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
              child: SingleChildScrollView(
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
                          AppStrings.signupTitle,
                          style: styles.screenTitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          AppStrings.signupSubtitle,
                          style: styles.screenSubtitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.huge),
                        _signUpForm.formGroupWrap(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _signUpForm.buildWidget('name'),
                              const SizedBox(height: AppDimensions.xl),
                              _signUpForm.buildWidget('email'),
                              const SizedBox(height: AppDimensions.xl),
                              _signUpForm.buildWidget('password'),
                              const SizedBox(height: AppDimensions.xl),
                              _signUpForm.buildWidget('confirmPassword'),
                              const SizedBox(height: AppDimensions.xxxl),
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
                                        ? () {
                                            // Perform registration / OTP trigger from supabase auth
                                          }
                                        : () {
                                            _signUpForm.markAllTouched();
                                          },
                                    child: Text(
                                      AppStrings.signupBtn,
                                      style: styles.buttonLabelOnPrimary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.huge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.loginLinkText,
                              style: styles.actionTextSecondary,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppStrings.loginLinkAction,
                                style: styles.actionLinkLabel,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
