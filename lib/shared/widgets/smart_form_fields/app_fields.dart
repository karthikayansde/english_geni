import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/constants/app_strings.dart';
import 'field_config.dart';

class AppFields {
  const AppFields._();

  static FieldConfig<String> email({String key = 'email'}) => FieldConfig.text(
        key: key,
        label: AppStrings.fieldGmail,
        keyboardType: TextInputType.emailAddress,
        required: true,
        validators: [Validators.email],
        validationMessages: {
          ValidationMessage.required: (_) => AppStrings.valRequiredGmail,
          ValidationMessage.email: (_) => AppStrings.valInvalidGmail,
        },
      );

  static FieldConfig<String> password({
    String key = 'password',
    String? label,
    String? requiredMessage,
    String? minLengthMessage,
  }) =>
      FieldConfig.text(
        key: key,
        label: label ?? AppStrings.fieldPassword,
        isPasswordField: true,
        required: true,
        maxLines: 1,
        validators: [Validators.minLength(6)],
        validationMessages: {
          ValidationMessage.required: (_) => requiredMessage ?? AppStrings.valRequiredPassword,
          ValidationMessage.minLength: (_) => minLengthMessage ?? AppStrings.valMinLengthPassword,
        },
      );

  static FieldConfig<String> confirmPassword({
    String key = 'confirmPassword',
    String? label,
    String? requiredMessage,
  }) =>
      FieldConfig.text(
        key: key,
        label: label ?? AppStrings.fieldConfirmPassword,
        isPasswordField: true,
        required: true,
        maxLines: 1,
        validationMessages: {
          ValidationMessage.required: (_) => requiredMessage ?? AppStrings.valRequiredConfirmPassword,
          'mustMatch': (_) => AppStrings.valPasswordMismatch,
        },
      );

  static FieldConfig<String> name({String key = 'name'}) => FieldConfig.text(
        key: key,
        label: AppStrings.fieldName,
        required: true,
        validationMessages: {
          ValidationMessage.required: (_) => AppStrings.valRequiredName,
        },
      );

  static FieldConfig<String> otp({String key = 'otp'}) => FieldConfig.text(
        key: key,
        label: AppStrings.fieldOtp,
        keyboardType: TextInputType.number,
        required: true,
        validators: [
          Validators.pattern(r'^\d{6}$'),
        ],
        validationMessages: {
          ValidationMessage.required: (_) => AppStrings.valRequiredOtp,
          ValidationMessage.pattern: (_) => AppStrings.valInvalidOtp,
        },
      );
}
