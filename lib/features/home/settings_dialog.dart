import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import '../../shared/widgets/smart_form_fields/smart_dropdown.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'theme': FormControl<List<String>>(
        value: [AppTheme.instance.getTheme()],
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (context, theme, textStyle, colors) {
        final styles = AppTextStyles(textStyle, colors);

        return Dialog(
          backgroundColor: theme.dialogBackgroundColor ?? colors.surfaceContainerHigh,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.formMaxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Settings",
                        style: styles.appBarTitle,
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.onSurfaceVariant),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xl),
                  ReactiveForm(
                    formGroup: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SmartDropDown(
                          formControlName: 'theme',
                          labelText: "App Theme",
                          isSingleDropDown: true,
                          items: AppTheme.instance.colorSchemes
                              .map((s) => {s.key: s.name})
                              .toList(),
                          initialSelectedItems: [AppTheme.instance.getTheme()],
                          onChanged: (selected) {
                            if (selected.isNotEmpty) {
                              AppTheme.instance.updateTheme(selected.first);
                            }
                          },
                          removeXButtonOnChip: true,
                          prefixIcon: Icon(Icons.palette_outlined, color: colors.primary),
                        ),
                      ],
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
