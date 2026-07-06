import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_color_schemes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/scaffold_wrapper.dart';
import '../../shared/widgets/smart_form_fields/smart_dropdown.dart';
import 'profile_dialogs.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
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
        final ext = theme.extension<AppColorsExtension>()!;

        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.scaffoldPaddingHorizontal,
              20,
              AppDimensions.scaffoldPaddingHorizontal,
              0,
            ),
            child: Column(
              children: [
                Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: Text("Profile", style: styles.homeHeadline),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header Row (Mascot and email details)
                        Row(
                          children: [
                            Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.outlineVariant, width: 1.5),
                                gradient: LinearGradient(
                                  colors: [
                                    ext.featurePurple,
                                    ext.featureYellow,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(36),
                                child: Transform.translate(
                                  offset: const Offset(6, 4),
                                  child: Image.asset(
                                    AppAssets.mascot1,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Sandra Glam", overflow: TextOverflow.ellipsis, style: styles.profileNameBold),
                                  const SizedBox(height: 4),
                                  Text(
                                    "karthikayansde@gmail.com",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant.withOpacity(0.65),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Section: Account Settings
                        _buildSettingsGroup(
                          title: "Account Settings",
                          colors: colors,
                          children: [
                            _buildSettingsRow(
                              title: "Change Name",
                              subtitle: "Update your profile name",
                              icon: Icons.person_rounded,
                              colors: colors,
                              styles: styles,
                              onTap: () => ProfileDialogs.showChangeName(context),
                            ),
                            _buildSettingsRow(
                              title: "Change Password",
                              subtitle: "Secure your account credentials",
                              icon: Icons.lock_rounded,
                              colors: colors,
                              styles: styles,
                              onTap: () => ProfileDialogs.showChangePassword(context),
                            ),
                            // Change Theme SmartDropDown Item
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: ReactiveForm(
                                    formGroup: _form,
                                    child: SmartDropDown(
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
                                      prefixIcon: Icon(Icons.palette_rounded, color: colors.primary),
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  indent: 56,
                                  endIndent: 16,
                                  color: colors.outlineVariant.withOpacity(0.25),
                                ),
                              ],
                            ),
                            _buildSettingsRow(
                              title: "Go Premium",
                              subtitle: "Unlock unlimited speaking & AI tools",
                              icon: Icons.workspace_premium_rounded,
                              colors: colors,
                              styles: styles,
                              trailingBadge: _buildPillBadge("PRO", Colors.amber.shade900, const Color(0xFFFFF8E1)),
                              showDivider: false,
                              onTap: () {},
                            ),
                          ],
                        ),

                        // Section: Preferences
                        _buildSettingsGroup(
                          title: "Preferences",
                          colors: colors,
                          children: [
                            _buildSettingsRow(
                              title: "Notifications & Reminders",
                              subtitle: "Daily study alerts and reminders",
                              icon: Icons.notifications_rounded,
                              colors: colors,
                              styles: styles,
                              onTap: () => ProfileDialogs.showNotificationsReminders(context),
                            ),
                            _buildSettingsRow(
                              title: "Suggestions",
                              subtitle: "Tell us how to improve your experience",
                              icon: Icons.lightbulb_rounded,
                              colors: colors,
                              styles: styles,
                              showDivider: false,
                              onTap: () => ProfileDialogs.showSuggestions(context),
                            ),
                          ],
                        ),

                        // Section: App Info & Community
                        _buildSettingsGroup(
                          title: "App Info & Community",
                          colors: colors,
                          children: [
                            _buildSettingsRow(
                              title: "Rate Us",
                              subtitle: "Love English Geni? Leave a review",
                              icon: Icons.thumb_up_rounded,
                              colors: colors,
                              styles: styles,
                              onTap: () {},
                            ),
                            _buildSettingsRow(
                              title: "Share App",
                              subtitle: "Invite your friends to learn together",
                              icon: Icons.share_rounded,
                              colors: colors,
                              styles: styles,
                              onTap: () {},
                            ),
                            _buildSettingsRow(
                              title: "Explore Our Apps",
                              subtitle: "More language apps by Geni Studio",
                              icon: Icons.apps_rounded,
                              colors: colors,
                              styles: styles,
                              showDivider: false,
                              onTap: () {},
                            ),
                          ],
                        ),

                        // Section: Client Services
                        _buildSettingsGroup(
                          title: "Client Services",
                          colors: colors,
                          children: [
                            _buildSettingsRow(
                              title: "Want App?",
                              subtitle: "Let's build a custom app for you",
                              icon: Icons.developer_mode_rounded,
                              colors: colors,
                              styles: styles,
                              trailingBadge: _buildPillBadge("NEW", const Color(0xFF00796B), const Color(0xFFE0F2F1)),
                              showDivider: false,
                              onTap: () {},
                            ),
                          ],
                        ),

                        // Section: Account Actions
                        _buildSettingsGroup(
                          title: "Account Actions",
                          colors: colors,
                          children: [
                            _buildSettingsRow(
                              title: "Logout",
                              subtitle: "Sign out of your account",
                              icon: Icons.logout_rounded,
                              colors: colors,
                              styles: styles,
                              overrideColor: colors.error,
                              onTap: () {},
                            ),
                            _buildSettingsRow(
                              title: "Delete Profile",
                              subtitle: "Permanently delete your profile data",
                              icon: Icons.delete_forever_rounded,
                              colors: colors,
                              styles: styles,
                              overrideColor: colors.error,
                              showDivider: false,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 120), // offset bottom navigation bar overlay height
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: colors.onSurfaceVariant.withOpacity(0.55),
        ),
      ),
    );
  }

  Widget _buildPillBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> children,
    required ColorScheme colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, colors),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.outlineVariant.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSettingsRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required ColorScheme colors,
    required AppTextStyles styles,
    Widget? trailingBadge,
    bool showDivider = true,
    Color? overrideColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: overrideColor ?? colors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: styles.profileOptionTitleBold?.copyWith(
                            color: overrideColor ?? colors.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: overrideColor != null
                                ? overrideColor.withOpacity(0.65)
                                : colors.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailingBadge != null)
                    trailingBadge
                  else
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: overrideColor != null
                          ? overrideColor.withOpacity(0.4)
                          : colors.onSurfaceVariant.withOpacity(0.4),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56, // Align divider to start after the icon (24px icon + 16px padding + 16px container margin)
            endIndent: 16,
            color: colors.outlineVariant.withOpacity(0.25),
          ),
      ],
    );
  }
}
