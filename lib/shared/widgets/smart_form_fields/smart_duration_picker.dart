import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'smart_form_field_theme.dart';

class SmartDurationPicker extends StatefulWidget {
  final String formControlName;
  final String labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isGreenWarnNeed;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final void Function(String? value)? onChanged;
  
  final Duration minDuration;
  final Duration maxDuration;

  const SmartDurationPicker({
    super.key,
    required this.formControlName,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.isGreenWarnNeed = false,
    this.validationMessages,
    this.onChanged,
    this.minDuration = const Duration(minutes: 1),
    this.maxDuration = const Duration(hours: 24),
  });

  @override
  State<SmartDurationPicker> createState() => _SmartDurationPickerState();
}

class _SmartDurationPickerState extends State<SmartDurationPicker> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      (ReactiveForm.of(context) as FormGroup?)?.control(widget.formControlName).markAsTouched();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  String _formatDuration(String? value) {
    if (value == null || value.isEmpty) return '00:00';
    return value;
  }

  Duration _parseDuration(String value) {
    try {
      final parts = value.split(':');
      return Duration(hours: int.parse(parts[0]), minutes: int.parse(parts[1]));
    } catch (e) {
      return widget.minDuration;
    }
  }

  String _formatDurationForDisplay(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  void _showPicker(
      BuildContext context, ReactiveFormFieldState<String, String> field) {
    field.control.markAsTouched();
    final currentDuration = _parseDuration(field.value ?? '00:00');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return _DurationPickerDialog(
          labelText: widget.labelText,
          initialDuration: currentDuration,
          minDuration: widget.minDuration,
          maxDuration: widget.maxDuration,
          onDurationSelected: (Duration selectedDuration) {
            final newValue = _formatDurationForDisplay(selectedDuration);
            field.didChange(newValue);
            if (widget.onChanged != null) {
              widget.onChanged!(newValue);
            }
          },
        );
      },
    );
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
            return ReactiveFormField<String, String>(
              formControlName: widget.formControlName,
              validationMessages: widget.validationMessages,
              builder: (field) {
                _textController.text = _formatDuration(field.value);

                return TextFormField(
                  controller: _textController,
                  focusNode: _focusNode,
                  readOnly: true,
                  onTap: () => _showPicker(context, field),
                  decoration: InputDecoration(
                    isDense: false,
                    labelText: widget.labelText,
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.suffixIcon != null) widget.suffixIcon! else const Icon(Icons.access_time_rounded),
                        if (widget.isGreenWarnNeed && isValid && control.value != null)
                          Icon(Icons.check_circle, color: SmartFormFieldTheme.successColor),
                      ],
                    ),
                    errorText: field.errorText,
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
                      borderRadius:
                          BorderRadius.circular(SmartFormFieldTheme.radius),
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
            );
          },
        ),
      ),
    );
  }
}

/// Stateful dialog widget that manages the picker and inline warning.
class _DurationPickerDialog extends StatefulWidget {
  final String labelText;
  final Duration initialDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final void Function(Duration selectedDuration) onDurationSelected;

  const _DurationPickerDialog({
    required this.labelText,
    required this.initialDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.onDurationSelected,
  });

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  late Duration _selectedDuration;
  String? _warningMessage;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
  }

  String _formatDurationForMessage(Duration duration) {
    final hours = duration.inHours.toString();
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  bool get _isValid {
    return _selectedDuration >= widget.minDuration &&
        _selectedDuration <= widget.maxDuration;
  }

  void _onDurationChanged(Duration newDuration) {
    setState(() {
      _selectedDuration = newDuration;
      if (newDuration < widget.minDuration) {
        _warningMessage =
            'Minimum duration is ${_formatDurationForMessage(widget.minDuration)}';
      } else if (newDuration > widget.maxDuration) {
        _warningMessage =
            'Maximum duration is ${_formatDurationForMessage(widget.maxDuration)}';
      } else {
        _warningMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.labelText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(),

            // Warning message (inline)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _warningMessage != null
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _warningMessage!,
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Cupertino Timer Picker
            SizedBox(
              height: 200,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: _selectedDuration,
                onTimerDurationChanged: _onDurationChanged,
              ),
            ),

            const SizedBox(height: 8),

            // Done button — only works when value is valid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isValid
                      ? () {
                          widget.onDurationSelected(_selectedDuration);
                          Navigator.pop(context);
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
