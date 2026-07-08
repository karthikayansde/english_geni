import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/services/smart_snack_bars.dart';
import '../../shared/widgets/smart_form_fields/smart_text_field.dart';
import '../../core/services/auth_service.dart';
import 'profile_controller.dart';

class ProfileDialogs {
  const ProfileDialogs._();

  // 1. Change Name Dialog
  static void showChangeName(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final formGroup = FormGroup({
      'name': FormControl<String>(
        value: controller.displayName.value,
        validators: [Validators.required],
      ),
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        return Obx(() {
          final isLoading = controller.isLoading.value;
          return PopScope(
            canPop: !isLoading,
            child: ReactiveForm(
              formGroup: formGroup,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                backgroundColor: theme.colorScheme.surface,
                title: Text(
                  "Change Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                content: AbsorbPointer(
                  absorbing: isLoading,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SmartTextField(
                          formControlName: 'name',
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                    child: Text("Cancel", style: TextStyle(color: theme.colorScheme.secondary)),
                  ),
                  ReactiveFormConsumer(
                    builder: (ctx, form, child) {
                      return TextButton(
                        onPressed: (form.valid && !isLoading)
                            ? () async {
                                final newName = form.control('name').value as String;
                                await controller.handleUpdateUsername(newName);
                                if (!controller.isLoading.value && dialogCtx.mounted) {
                                  Navigator.pop(dialogCtx);
                                }
                              }
                            : null,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                "Save",
                                style: TextStyle(
                                  color: form.valid ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.35),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // 2. Change Password Dialog
  static void showChangePassword(BuildContext context) {
    final formGroup = FormGroup({
      'oldPassword': FormControl<String>(
        validators: [Validators.required],
      ),
      'newPassword': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
      'confirmPassword': FormControl<String>(
        validators: [Validators.required],
      ),
    }, validators: [
      Validators.mustMatch('newPassword', 'confirmPassword'),
    ]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: !isLoading,
              child: ReactiveForm(
                formGroup: formGroup,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  backgroundColor: theme.colorScheme.surface,
                  title: Text(
                    "Change Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  content: AbsorbPointer(
                    absorbing: isLoading,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SmartTextField(
                            formControlName: 'oldPassword',
                            labelText: 'Old Password',
                            isPasswordField: true,
                            prefixIcon: Icon(Icons.lock_open_rounded, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 12),
                          SmartTextField(
                            formControlName: 'newPassword',
                            labelText: 'New Password',
                            isPasswordField: true,
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.primary),
                            validationMessages: {
                              'minLength': (error) => 'Password must be at least 6 characters',
                            },
                          ),
                          const SizedBox(height: 12),
                          SmartTextField(
                            formControlName: 'confirmPassword',
                            labelText: 'Confirm Password',
                            isPasswordField: true,
                            prefixIcon: Icon(Icons.lock_rounded, color: theme.colorScheme.primary),
                            validationMessages: {
                              'mustMatch': (error) => 'Passwords do not match',
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                      child: Text("Cancel", style: TextStyle(color: theme.colorScheme.secondary)),
                    ),
                    ReactiveFormConsumer(
                      builder: (ctx, form, child) {
                        return TextButton(
                          onPressed: (form.valid && !isLoading)
                              ? () async {
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final oldPassword = form.control('oldPassword').value as String;
                                    final newPassword = form.control('newPassword').value as String;
                                    await AuthService.to.changePasswordFromProfile(
                                      currentPassword: oldPassword,
                                      newPassword: newPassword,
                                    );
                                    
                                    SmartSnackBars.showOverlay(
                                      dialogCtx,
                                      message: "Password changed successfully!",
                                      type: NotificationType.success,
                                    );
                                    if (dialogCtx.mounted) {
                                      Navigator.pop(dialogCtx);
                                    }
                                  } catch (e) {
                                    if (dialogCtx.mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                    SmartSnackBars.showOverlay(
                                      dialogCtx,
                                      message: e.toString().replaceAll('Exception: ', ''),
                                      type: NotificationType.error,
                                    );
                                  }
                                }
                              : null,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  "Change",
                                  style: TextStyle(
                                    color: form.valid ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.35),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 2b. Reset Password Dialog (without old password field)
  static void showResetPassword(BuildContext context, {required VoidCallback onSuccess}) {
    final formGroup = FormGroup({
      'newPassword': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
      'confirmPassword': FormControl<String>(
        validators: [Validators.required],
      ),
    }, validators: [
      Validators.mustMatch('newPassword', 'confirmPassword'),
    ]);

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal during submission
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: !isLoading,
              child: ReactiveForm(
                formGroup: formGroup,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  backgroundColor: theme.colorScheme.surface,
                  title: Text(
                    "Reset Password",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  content: AbsorbPointer(
                    absorbing: isLoading,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SmartTextField(
                            formControlName: 'newPassword',
                            labelText: 'New Password',
                            isPasswordField: true,
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.primary),
                            validationMessages: {
                              'minLength': (error) => 'Password must be at least 6 characters',
                            },
                          ),
                          const SizedBox(height: 12),
                          SmartTextField(
                            formControlName: 'confirmPassword',
                            labelText: 'Confirm Password',
                            isPasswordField: true,
                            prefixIcon: Icon(Icons.lock_rounded, color: theme.colorScheme.primary),
                            validationMessages: {
                              'mustMatch': (error) => 'Passwords do not match',
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                      child: Text("Cancel", style: TextStyle(color: theme.colorScheme.secondary)),
                    ),
                    ReactiveFormConsumer(
                      builder: (ctx, form, child) {
                        return TextButton(
                          onPressed: (form.valid && !isLoading)
                              ? () async {
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final newPassword = form.control('newPassword').value as String;
                                    await AuthService.to.updatePassword(newPassword);
                                    
                                    SmartSnackBars.showOverlay(
                                      dialogCtx,
                                      message: "Password reset successfully!",
                                      type: NotificationType.success,
                                    );
                                    if (dialogCtx.mounted) {
                                      Navigator.pop(dialogCtx);
                                    }
                                    onSuccess();
                                  } catch (e) {
                                    if (dialogCtx.mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                    SmartSnackBars.showOverlay(
                                      dialogCtx,
                                      message: e.toString().replaceAll('Exception: ', ''),
                                      type: NotificationType.error,
                                    );
                                  }
                                }
                              : null,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  "Reset",
                                  style: TextStyle(
                                    color: form.valid ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.35),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. Notifications & Reminders Dialog with Time Picker
  static void showNotificationsReminders(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);

        return StatefulBuilder(
          builder: (ctx, setState) {
            // Local state inside the dialog
            selectedTime ??= const TimeOfDay(hour: 9, minute: 0);
            remindersEnabled ??= true;

            final formattedTime = selectedTime!.format(ctx);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                "Notifications & Reminders",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Daily Study Reminders",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        "Get alerts to complete daily targets",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                      value: remindersEnabled!,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          remindersEnabled = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: remindersEnabled! ? 1.0 : 0.45,
                      child: IgnorePointer(
                        ignoring: !remindersEnabled!,
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: selectedTime!,
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_rounded, color: theme.colorScheme.primary),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Reminder Time",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.edit_calendar_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.65),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text("Cancel", style: TextStyle(color: theme.colorScheme.secondary)),
                ),
                TextButton(
                  onPressed: () {
                    SmartSnackBars.showOverlay(
                      dialogCtx,
                      message: remindersEnabled!
                          ? "Study reminders set for $formattedTime!"
                          : "Daily study reminders disabled.",
                      type: NotificationType.success,
                    );
                    Navigator.pop(dialogCtx);
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Static storage for notifications config state (resets with app reload, but persistent in session)
  static TimeOfDay? selectedTime;
  static bool? remindersEnabled;

  // 4. Suggestions Dialog (Issue and Improvement or Addition)
  static void showSuggestions(BuildContext context) {
    final formGroup = FormGroup({
      'type': FormControl<String>(
        value: 'issue',
        validators: [Validators.required],
      ),
      'suggestion': FormControl<String>(
        validators: [Validators.required],
      ),
    });

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        return ReactiveForm(
          formGroup: formGroup,
          child: StatefulBuilder(
            builder: (ctx, setState) {
              final typeControl = formGroup.control('type') as FormControl<String>;
              final selectedType = typeControl.value ?? 'issue';

              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                backgroundColor: theme.colorScheme.surface,
                title: Text(
                  "Suggestions & Feedback",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Feedback Category",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildRadioTile(
                            context: ctx,
                            label: "Issue",
                            selected: selectedType == 'issue',
                            onTap: () {
                              setState(() {
                                typeControl.value = 'issue';
                              });
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildRadioTile(
                            context: ctx,
                            label: "Improvement",
                            selected: selectedType == 'improvement',
                            onTap: () {
                              setState(() {
                                typeControl.value = 'improvement';
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SmartTextField(
                        formControlName: 'suggestion',
                        labelText: selectedType == 'issue'
                            ? 'What issue did you face?'
                            : 'Describe your suggestion/improvement',
                        maxLines: 4,
                        prefixIcon: Icon(
                          selectedType == 'issue'
                              ? Icons.bug_report_rounded
                              : Icons.lightbulb_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text("Cancel", style: TextStyle(color: theme.colorScheme.secondary)),
                  ),
                  ReactiveFormConsumer(
                    builder: (ctx, form, child) {
                      return TextButton(
                        onPressed: form.valid
                            ? () {
                                final typeText = selectedType == 'issue' ? 'Issue' : 'Suggestion';
                                SmartSnackBars.showOverlay(
                                  dialogCtx,
                                  message: "$typeText submitted successfully. Thank you!",
                                  type: NotificationType.success,
                                );
                                Navigator.pop(dialogCtx);
                              }
                            : null,
                        child: Text(
                          "Submit",
                          style: TextStyle(
                            color: form.valid ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.35),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Custom styled Smart Radio Button
  static Widget _buildRadioTile({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  width: selected ? 6 : 2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
