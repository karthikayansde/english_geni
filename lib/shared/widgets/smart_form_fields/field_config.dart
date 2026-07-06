import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'smart_text_field.dart';
// import 'smart_dropdown.dart';
// import 'smart_check_radio_box.dart';
// import 'smart_date_time_picker.dart';
// import 'smart_duration_picker.dart';

enum SmartFieldType {
  text,
  emoji,
  color,
  duration,
  dateTime,
  dropdown,
  checkRadio,
}

enum SmartPickerMode {
  date,
  time,
  dateAndTime,
}

class FieldConfig<T> {
  final String key;
  String label;
  final SmartFieldType type;

  // Common UI params
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isGreenWarnNeed;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final void Function(dynamic value)? onChanged;

  // Validation & Data
  final bool required;
  final T? defaultValue;
  final List<Validator<dynamic>> validators;

  // Type-specific params
  final TextInputType? keyboardType;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPasswordField;
  final String? showString;
  final String? hideString;

  List<Map<dynamic, String>>? items;
  final bool? isSingleSelect; // Used for both dropdown and checkRadio
  final bool? isWrap;
  final bool? singleSelectHasDeselect;
  final bool? isVertical;
  final bool? removeXButtonOnChip;

  final Duration? minDuration;
  final Duration? maxDuration;

  final SmartPickerMode? pickerMode;
  final bool? isMultiSelection;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final bool? use24HourFormat;
  final String? dateFormat;
  final String? timeFormat;

  final String? searchHintText;
  final String? noItemsText;
  final String? selectAllText;
  final String? deselectAllText;
  final String? saveText;
  final String? cancelText;

  final bool showRequiredStar;

  FieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.prefixIcon,
    this.suffixIcon,
    this.isGreenWarnNeed = false,
    this.validationMessages,
    this.onChanged,
    this.required = false,
    this.showRequiredStar = false,
    this.defaultValue,
    this.validators = const [],
    this.keyboardType,
    this.maxLines,
    this.inputFormatters,
    this.isPasswordField = false,
    this.showString,
    this.hideString,
    this.items,
    this.isSingleSelect,
    this.isWrap,
    this.singleSelectHasDeselect,
    this.isVertical,
    this.removeXButtonOnChip,
    this.minDuration,
    this.maxDuration,
    this.pickerMode,
    this.isMultiSelection,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.initialTime,
    this.use24HourFormat,
    this.dateFormat,
    this.timeFormat,
    this.searchHintText,
    this.noItemsText,
    this.selectAllText,
    this.deselectAllText,
    this.saveText,
    this.cancelText,
  });

  // Factory methods for cleaner implementation
  static FieldConfig<String> text({
    required String key,
    required String label,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isGreenWarnNeed = false,
    Map<String, ValidationMessageFunction>? validationMessages,
    void Function(String? value)? onChanged,
    bool required = false,
    bool showRequiredStar = false,
    String? defaultValue,
    List<Validator<dynamic>> validators = const [],
    TextInputType? keyboardType,
    int? maxLines,
    List<TextInputFormatter>? inputFormatters,
    bool isPasswordField = false,
    String? showString,
    String? hideString,
  }) =>
      FieldConfig<String>(
        key: key,
        label: label,
        type: SmartFieldType.text,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isGreenWarnNeed: isGreenWarnNeed,
        validationMessages: validationMessages,
        onChanged: (v) => onChanged?.call(v as String?),
        required: required,
        showRequiredStar: showRequiredStar,
        defaultValue: defaultValue,
        validators: validators,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        isPasswordField: isPasswordField,
        showString: showString,
        hideString: hideString,
      );

  static FieldConfig<String> emoji({
    required String key,
    required String label,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isGreenWarnNeed = false,
    Map<String, ValidationMessageFunction>? validationMessages,
    void Function(String? value)? onChanged,
    bool required = false,
    bool showRequiredStar = false,
    String? defaultValue,
    List<Validator<dynamic>> validators = const [],
  }) =>
      FieldConfig<String>(
        key: key,
        label: label,
        type: SmartFieldType.emoji,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isGreenWarnNeed: isGreenWarnNeed,
        validationMessages: validationMessages,
        onChanged: (v) => onChanged?.call(v as String?),
        required: required,
        showRequiredStar: showRequiredStar,
        defaultValue: defaultValue,
        validators: validators,
      );

  static FieldConfig<int> color({
    required String key,
    required String label,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isGreenWarnNeed = false,
    Map<String, ValidationMessageFunction>? validationMessages,
    void Function(Color? value)? onChanged,
    bool required = false,
    bool showRequiredStar = false,
    int? defaultValue,
    List<Validator<dynamic>> validators = const [],
  }) =>
      FieldConfig<int>(
        key: key,
        label: label,
        type: SmartFieldType.color,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isGreenWarnNeed: isGreenWarnNeed,
        validationMessages: validationMessages,
        onChanged: (v) => onChanged?.call(v != null ? Color(v as int) : null),
        required: required,
        showRequiredStar: showRequiredStar,
        defaultValue: defaultValue,
        validators: validators,
      );

  static FieldConfig<String> duration({
    required String key,
    required String label,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isGreenWarnNeed = false,
    Map<String, ValidationMessageFunction>? validationMessages,
    void Function(String? value)? onChanged,
    bool required = false,
    bool showRequiredStar = false,
    String? defaultValue,
    List<Validator<dynamic>> validators = const [],
    Duration minDuration = const Duration(minutes: 1),
    Duration maxDuration = const Duration(hours: 24),
  }) =>
      FieldConfig<String>(
        key: key,
        label: label,
        type: SmartFieldType.duration,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isGreenWarnNeed: isGreenWarnNeed,
        validationMessages: validationMessages,
        onChanged: (v) => onChanged?.call(v as String?),
        required: required,
        showRequiredStar: showRequiredStar,
        defaultValue: defaultValue,
        validators: validators,
        minDuration: minDuration,
        maxDuration: maxDuration,
      );

  static FieldConfig<T> dateTime<T>({
    required String key,
    required String label,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isGreenWarnNeed = false,
    Map<String, ValidationMessageFunction>? validationMessages,
    void Function(T? value)? onChanged,
    bool required = false,
    bool showRequiredStar = false,
    T? defaultValue,
    List<Validator<dynamic>> validators = const [],
    SmartPickerMode mode = SmartPickerMode.dateAndTime,
    bool isMultiSelection = false,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? initialDate,
    TimeOfDay? initialTime,
    bool use24HourFormat = false,
    String? dateFormat,
    String? timeFormat,
  }) =>
      FieldConfig<T>(
        key: key,
        label: label,
        type: SmartFieldType.dateTime,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isGreenWarnNeed: isGreenWarnNeed,
        validationMessages: validationMessages,
        onChanged: (v) => onChanged?.call(v as T?),
        required: required,
        showRequiredStar: showRequiredStar,
        defaultValue: defaultValue,
        validators: validators,
        pickerMode: mode,
        isMultiSelection: isMultiSelection,
        firstDate: firstDate,
        lastDate: lastDate,
        initialDate: initialDate,
        initialTime: initialTime,
        use24HourFormat: use24HourFormat,
        dateFormat: dateFormat,
        timeFormat: timeFormat,
      );

  static FieldConfig<List<String>> dropdown({
    required String key,
    required String label,
    required List<Map<String, String>> items,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isGreenWarnNeed = false,
    Map<String, ValidationMessageFunction>? validationMessages,
    void Function(List<String> value)? onChanged,
    bool required = false,
    bool showRequiredStar = false,
    List<String>? defaultValue,
    List<Validator<dynamic>> validators = const [],
    bool isSingleDropDown = false,
    bool singleSelectHasDeselect = false,
    bool isVertical = false,
    bool removeXButtonOnChip = false,
    String? searchHintText,
    String? noItemsText,
    String? selectAllText,
    String? deselectAllText,
    String? saveText,
    String? cancelText,
  }) =>
      FieldConfig<List<String>>(
        key: key,
        label: label,
        type: SmartFieldType.dropdown,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isGreenWarnNeed: isGreenWarnNeed,
        validationMessages: validationMessages,
        onChanged: (v) => onChanged?.call(v as List<String>),
        required: required,
        showRequiredStar: showRequiredStar,
        defaultValue: defaultValue,
        validators: validators,
        items: items,
        isSingleSelect: isSingleDropDown,
        singleSelectHasDeselect: singleSelectHasDeselect,
        isVertical: isVertical,
        removeXButtonOnChip: removeXButtonOnChip,
        searchHintText: searchHintText,
        noItemsText: noItemsText,
        selectAllText: selectAllText,
        deselectAllText: deselectAllText,
        saveText: saveText,
        cancelText: cancelText,
      );

  static FieldConfig<T> checkRadio<T>({
    required String key,
    required String label,
    required List<Map<dynamic, String>> items,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isGreenWarnNeed = false,
    Map<String, ValidationMessageFunction>? validationMessages,
    void Function(T? value)? onChanged,
    bool required = false,
    bool showRequiredStar = false,
    T? defaultValue,
    List<Validator<dynamic>> validators = const [],
    bool isSingleSelect = true,
    bool isWrap = false,
  }) =>
      FieldConfig<T>(
        key: key,
        label: label,
        type: SmartFieldType.checkRadio,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        isGreenWarnNeed: isGreenWarnNeed,
        validationMessages: validationMessages,
        onChanged: (v) => onChanged?.call(v as T?),
        required: required,
        showRequiredStar: showRequiredStar,
        defaultValue: defaultValue,
        validators: validators,
        items: items,
        isSingleSelect: isSingleSelect,
        isWrap: isWrap,
      );

  List<Validator<dynamic>> get buildValidators {
    final list = <Validator<dynamic>>[];
    if (required) list.add(Validators.required);
    list.addAll(validators);
    return list;
  }

  String get labelText => (required || showRequiredStar) ? '$label*' : label;

  FormControl<T> createControl({dynamic initialValue}) {
    return FormControl<T>(
      value: (initialValue ?? defaultValue) as T?,
      validators: buildValidators,
    );
  }

  Widget buildWidget(FormGroup formGroup) {
    switch (type) {
      case SmartFieldType.text:
        return SmartTextField(
          formControlName: key,
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          isGreenWarnNeed: isGreenWarnNeed,
          validationMessages: validationMessages,
          onChanged: onChanged != null ? (control) => onChanged!(control.value) : null,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          isPasswordField: isPasswordField,
          showString: showString,
          hideString: hideString,
        );
      case SmartFieldType.emoji:
      case SmartFieldType.color:
      case SmartFieldType.duration:
      case SmartFieldType.dateTime:
      case SmartFieldType.dropdown:
      case SmartFieldType.checkRadio:
        return const SizedBox.shrink(); // Stub out unused types to avoid compile errors
    }
  }
}