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
import '../../shared/widgets/otp_dialog.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/smart_snack_bars.dart';
import '../../core/routes/route_names.dart';
import '../home/profile_dialogs.dart';

class ForgotPasswordForm extends SmartForm {
  @override
  Map<String, FieldConfig> get configs => {
        'email': AppFields.email(),
      };
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordForm _forgotPasswordForm = ForgotPasswordForm();
  bool _isLoading = false;

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

        return PopScope(
          canPop: !_isLoading,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              bottom: true,
              top: false,
              right: true,
              left: true,
              child: Stack(
                children: [
                  AbsorbPointer(
                    absorbing: _isLoading,
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
                                          onPressed: (form.valid && !_isLoading)
                                              ? () async {
                                                  final email = form.control('email').value as String;
                                                  try {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    await AuthService.to.sendPasswordResetEmail(email);
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                    if (!mounted) return;
                                                    final verified = await OtpDialog.show(
                                                      context,
                                                      email: email,
                                                      onVerify: (otp) => AuthService.to.verifyRecoveryOtp(
                                                        email: email,
                                                        token: otp,
                                                      ),
                                                      onResend: () => AuthService.to.sendPasswordResetEmail(email),
                                                    );
                                                    if (verified == true && mounted) {
                                                      ProfileDialogs.showResetPassword(
                                                        context,
                                                        onSuccess: () {
                                                          if (mounted) {
                                                            context.go(RouteNames.home);
                                                          }
                                                        },
                                                      );
                                                    }
                                                  } catch (e) {
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                    SmartSnackBars.showOverlay(
                                                      context,
                                                      message: e.toString().replaceAll('Exception: ', ''),
                                                      type: NotificationType.error,
                                                    );
                                                  }
                                                }
                                              : () {
                                                  if (!_isLoading) {
                                                    _forgotPasswordForm.markAllTouched();
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
                  ),
                  SafeArea(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.onSurface),
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
