// This file is commented out to prevent compile errors because the pickers/smart_pickers.dart and format_controller.dart dependencies are missing.
// To use, place dependencies in the project and uncomment this code.
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/settings/presentation/controllers/format_controller.dart';
import 'smart_form_field_theme.dart';

enum SmartPickerMode { dateOnly, timeOnly, dateAndTime }

class SmartDateTimePicker extends StatefulWidget {
  final String formControlName;
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isGreenWarnNeed;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final void Function(dynamic value)? onChanged;
  
  final SmartPickerMode mode;
  final bool isMultiSelection;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final bool use24HourFormat;
  final String? dateFormat;
  final String? timeFormat;

  const SmartDateTimePicker({
    super.key,
    required this.formControlName,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.isGreenWarnNeed = false,
    this.validationMessages,
    this.onChanged,
    this.mode = SmartPickerMode.dateAndTime,
    this.isMultiSelection = false,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.initialTime,
    this.use24HourFormat = false,
    this.dateFormat,
    this.timeFormat,
  });

  @override
  State<SmartDateTimePicker> createState() => _SmartDateTimePickerState();
}

class _SmartDateTimePickerState extends State<SmartDateTimePicker> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
*/
