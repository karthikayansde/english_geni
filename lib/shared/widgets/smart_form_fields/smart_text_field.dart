import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'smart_form_field_theme.dart';

class SmartTextField extends StatefulWidget {
  final String formControlName;
  final String labelText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool isGreenWarnNeed;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final ReactiveFormFieldCallback<String>? onChanged;
  
  final TextInputType? keyboardType;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPasswordField;
  final String? showString;
  final String? hideString;

  const SmartTextField({
    super.key,
    required this.formControlName,
    required this.labelText,
    this.suffixIcon,
    this.prefixIcon,
    this.isGreenWarnNeed = false,
    this.validationMessages,
    this.onChanged,
    this.keyboardType,
    this.maxLines,
    this.inputFormatters,
    this.isPasswordField = false,
    this.showString,
    this.hideString,
  });

  @override
  State<SmartTextField> createState() => _SmartTextFieldState();
}

class _SmartTextFieldState extends State<SmartTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPasswordField;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: ReactiveStatusListenableBuilder(
          formControlName: widget.formControlName,
          builder: (context, control, child) {
            final isValid = control.valid;
            return ReactiveTextField<String>(
              formControlName: widget.formControlName,
              validationMessages: widget.validationMessages,
              textCapitalization: TextCapitalization.sentences,

              showErrors: (control) => control.invalid && (control.touched || control.dirty),
              keyboardType: widget.keyboardType,
              maxLines: _obscureText ? 1 : widget.maxLines,
              obscureText: _obscureText,
              onChanged: widget.onChanged,
              inputFormatters: widget.inputFormatters,
                decoration: InputDecoration(
                isDense: false,
                labelText: widget.labelText,
                suffixIcon: widget.isPasswordField
                    ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.0,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(55, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Text(
                      _obscureText ? widget.showString??'Show' : widget.hideString??'Hide',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.suffixIcon != null) widget.suffixIcon!,
                    if (widget.isGreenWarnNeed && isValid && control.value != null && (control.value as String).isNotEmpty)
                      Icon(Icons.check_circle, color: SmartFormFieldTheme.successColor),
                  ],
                ),
                prefixIcon: widget.prefixIcon,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: SmartFormFieldTheme.borderWidth,
                    ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    width: SmartFormFieldTheme.borderWidth,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                  borderSide: BorderSide(
                    width: SmartFormFieldTheme.focusedBorderWidth,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: SmartFormFieldTheme.borderWidth,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SmartFormFieldTheme.radius),
                  borderSide: BorderSide(
                    width: SmartFormFieldTheme.focusedBorderWidth,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
/// basic usage
// // inputFormatters: [
// // AppInputFormatters.limitedText(maxLength: 255),
// // AppInputFormatters.lettersNumbersSymbolsFormat
// // AppInputFormatters.lettersNumbersSpaceSymbolsFormat
// // UpperCaseTextFormatter(),
// // AppInputFormatters.capitalAndNumbersFormat,
// // inputFormatters: AppInputFormatters.email(),
// // MaxNumericValueFormatter(maxValue: 1000, decimalPlaces: 2),
// // ],
// class _TaskPageState extends State<TaskPage> {
//   // Define the form group with only one field
//   final rf.FormGroup form = rf.FormGroup({
//     'task_name': rf.FormControl<String>(
//       disabled: true,
//       value: "ass",
//       validators: [rf.Validators.required],
//     ),
//     'task_name1': rf.FormControl<String>(
//       validators: [rf.Validators.required],
//     ),
//
//     'password': rf.FormControl<String>(
//       validators: [
//         rf.Validators.required,
//         rf.Validators.minLength(8),
//         rf.Validators.maxLength(255),
//         // Custom validator for 1 uppercase, 1 number, and 1 special character
//         rf.Validators.delegate(passwordComplexityValidator),
//       ],
//     ),
//     'amount': rf.FormControl<double>(
//       validators: [
//         rf.Validators.required,
//         rf.Validators.number(allowedDecimals: 2),
//       ],
//     ),
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Task'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: rf.ReactiveForm(
//             formGroup: form,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 // Single field: Task Name
//                 rf.ReactiveTextField<String>(
//                   readOnly: true,
//                   formControlName: 'task_name',
//                   decoration: const InputDecoration(
//                     labelText: 'Task Name',
//                     border: OutlineInputBorder(),
//                     helperText: 'Enter your task name',
//                   ),
//                   validationMessages: {
//                     rf.ValidationMessage.required: (_) => 'The task name is required',
//                   },
//                 ),
//                 const SizedBox(height: 24.0),
//                 rf.ReactiveTextField<String>(
//                   formControlName: 'task_name1',
//                   decoration: const InputDecoration(
//                     labelText: 'Task Name',
//                     border: OutlineInputBorder(),
//                     helperText: 'Enter your task name',
//                   ),
//                   validationMessages: {
//                     rf.ValidationMessage.required: (_) => 'The task name is required',
//                   },
//                 ),
//                 const SizedBox(height: 24.0),
//                 rf.ReactiveTextField<String>(
//                   formControlName: 'password',
//                   decoration: const InputDecoration(
//                     labelText: 'password',
//                     border: OutlineInputBorder(),
//                     // helperText: 'Enter your password',
//                   ),
//                   obscureText: true,
//                   validationMessages: {
//                     rf.ValidationMessage.required: (_) => 'The password is required',
//                     rf.ValidationMessage.minLength: (error) => 'Password must be at least ${(error as Map)['requiredLength']} characters',
//                     'passwordComplexity': (error) => 'Missing: ${(error as List).join(", ")}',
//                   },
//                 ),
//                 const SizedBox(height: 24.0),
//                 // Numeric field for decimal values (max 2 decimals)
//                 rf.ReactiveTextField<double>(
//                   formControlName: 'amount',
//                   inputFormatters: [
//                     MaxNumericValueFormatter(decimalPlaces: 3, maxValue: 2)
//                   ],
//                 ),
//                 // OK Button
//                 ElevatedButton(
//                   onPressed: () {
//                     if (form.valid) {
//                       final taskName = form.control('task_name').value;
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Task Added: $taskName')),
//                       );
//                     } else {
//                       form.markAllAsTouched();
//                     }
//                   },
//                   child: const Text('OK'),
//                 ),
//
//                 ElevatedButton(
//                   onPressed: () {
//                     final control = form.control('task_name1');
//                     if (control.disabled) {
//                       control.markAsEnabled();
//                     } else {
//                       control.markAsDisabled();
//                     }
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MaxNumericValueFormatter extends TextInputFormatter {
//   final double maxValue;
//   final int decimalPlaces;
//   late final RegExp validCharacters;
//
//   MaxNumericValueFormatter({
//     required this.maxValue,
//     required this.decimalPlaces,
//   }) {
//     validCharacters = RegExp(r'^\d*\.?\d{0,' '$decimalPlaces' r'}$');
//   }
//
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     final newText = newValue.text;
//
//     if (newText.isEmpty) return newValue;
//     if (!validCharacters.hasMatch(newText)) return oldValue;
//
//     final parsedValue = double.tryParse(newText);
//     if (parsedValue == null) return oldValue;
//
//     // Prevent decimals if equal to maxValue
//     if (parsedValue == maxValue && newText.contains('.')) return oldValue;
//
//     // Reject values above maxValue
//     if (parsedValue > maxValue) return oldValue;
//
//     return newValue;
//   }
// }
//
// Map<String, dynamic>? passwordComplexityValidator(rf.AbstractControl<dynamic> control) {
//   if (control.value == null || control.value.toString().isEmpty) {
//     return null;
//   }
//
//   final value = control.value.toString();
//   final List<String> missing = [];
//
//   if (!RegExp(r'[A-Z]').hasMatch(value)) {
//     missing.add('an uppercase letter');
//   }
//   if (!RegExp(r'[0-9]').hasMatch(value)) {
//     missing.add('a number');
//   }
//   if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
//     missing.add('a special character');
//   }
//
//   if (missing.isNotEmpty) {
//     return {'passwordComplexity': missing};
//   }
//
//   return null;
// }