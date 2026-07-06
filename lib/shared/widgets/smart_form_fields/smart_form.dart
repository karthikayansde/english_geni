import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'field_config.dart';

abstract class SmartForm {
  Map<String, FieldConfig> get configs;
  late final FormGroup formGroup;

  void initForm({Map<String, dynamic>? initialValues}) {
    formGroup = FormGroup({
      for (var entry in configs.entries)
        entry.key: entry.value.createControl(
          initialValue: initialValues?[entry.key],
        )
    });
  }

  Widget formGroupWrap({required Widget child}) {
    return ReactiveForm(
      formGroup: formGroup,
      child: child,
    );
  }

  Widget buildWidget(String key) {
    if (!configs.containsKey(key)) {
      throw Exception('FieldConfig with key "$key" not found in form configs.');
    }
    return configs[key]!.buildWidget(formGroup);
  }

  T? value<T>(String key) {
    return formGroup.control(key).value as T?;
  }

  Widget listen<T>(String key, {required Widget Function(T? value) builder}) {
    return ReactiveValueListenableBuilder<T>(
      formControlName: key,
      builder: (context, control, _) => builder(control.value),
    );
  }

  bool get isDirty => formGroup.dirty;

  void reset() => formGroup.reset();

  void markAllTouched() => formGroup.markAllAsTouched();
}