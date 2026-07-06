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
import 'package:go_router/go_router.dart';
import '../../core/routes/route_names.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginForm extends SmartForm {
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
      };
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginForm _loginForm = LoginForm();

  @override
  void initState() {
    super.initState();
    _loginForm.initForm();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (context, theme, textStyle, colors) {
        final styles = AppTextStyles(textStyle, colors);

        return SmartPopScope(
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
                          AppStrings.loginTitle,
                          style: styles.screenTitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          AppStrings.loginSubtitle,
                          style: styles.screenSubtitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.giant),
                        _loginForm.formGroupWrap(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _loginForm.buildWidget('email'),
                              const SizedBox(height: AppDimensions.xl),
                              _loginForm.buildWidget('password'),
                              const SizedBox(height: AppDimensions.md),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppStrings.forgotPasswordLink,
                                    style: styles.actionLinkLabel,
                                  ),
                                ),
                              ),
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
                                            // Perform sign in action
                                          }
                                        : () {
                                            _loginForm.markAllTouched();
                                          },
                                    child: Text(
                                      AppStrings.loginBtn,
                                      style: styles.buttonLabelOnPrimary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.giant),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.signupLinkText,
                              style: styles.actionTextSecondary,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppStrings.signupLinkAction,
                                style: styles.actionLinkLabel,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            context.go(RouteNames.home);
                          },
                          child: Text(
                            AppStrings.loginBypassBtn,
                            style: styles.actionLinkUnderlined,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xxl),
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
