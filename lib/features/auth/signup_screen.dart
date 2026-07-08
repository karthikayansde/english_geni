import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import '../../shared/widgets/smart_pop_scope.dart';
import '../../shared/widgets/smart_form_fields/smart_form.dart';
import '../../shared/widgets/smart_form_fields/field_config.dart';
import '../../shared/widgets/smart_form_fields/app_fields.dart';
import '../../shared/widgets/top_head_image.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/smart_dialogs.dart';
import '../../core/services/smart_snack_bars.dart';
import '../../core/routes/route_names.dart';
import 'login_screen.dart';
import '../../shared/widgets/otp_dialog.dart';
import 'package:get/get.dart';
import 'presentation/controllers/auth_controller.dart';

class SignUpForm extends SmartForm {
  @override
  Map<String, FieldConfig> get configs => {
        'name': AppFields.name(),
        'email': AppFields.email(),
        'password': AppFields.password(),
        'confirmPassword': AppFields.confirmPassword(),
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
  final _authController = Get.put(AuthController());

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
                                        ? () async {
                                            final name = form.control('name').value as String;
                                            final email = form.control('email').value as String;
                                            final password = form.control('password').value as String;

                                            await _authController.handleSignup(
                                              context,
                                              displayName: name,
                                              email: email,
                                              password: password,
                                              onReactivated: () {
                                                if (mounted) {
                                                  context.go(RouteNames.home);
                                                }
                                              },
                                              onReactivationRequired: () async {
                                                SmartSnackBars.showOverlay(
                                                  context,
                                                  message: 'We found your previous account. Enter the OTP sent to your email to reactivate it.',
                                                  type: NotificationType.success,
                                                );

                                                // Show OTP Dialog for recovery/reactivation
                                                final verified = await OtpDialog.show(
                                                  context,
                                                  email: email,
                                                  onVerify: (otp) => AuthService.to.completeReactivation(
                                                    email: email,
                                                    token: otp,
                                                    newPassword: password,
                                                    displayName: name,
                                                  ),
                                                  onResend: () => AuthService.to.sendPasswordResetEmail(email),
                                                );

                                                if (verified == true && mounted) {
                                                  context.go(RouteNames.home);
                                                }
                                              },
                                              onVerificationRequired: () async {
                                                SmartSnackBars.showOverlay(
                                                  context,
                                                  message: 'OTP verification code sent to your email!',
                                                  type: NotificationType.success,
                                                );

                                                // Show OTP Dialog
                                                final verified = await OtpDialog.show(
                                                  context,
                                                  email: email,
                                                  onVerify: (otp) => AuthService.to.verifySignupOtp(
                                                    email: email,
                                                    token: otp,
                                                  ),
                                                  onResend: () => AuthService.to.resendSignupOtp(email),
                                                );

                                                if (verified == true && mounted) {
                                                  context.go(RouteNames.home);
                                                }
                                              },
                                            );
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
