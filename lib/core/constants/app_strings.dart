class AppStrings {
  const AppStrings._();

  static const AppStrings instance = AppStrings._();

  static const String appName = "English Geni";
  // theme
  static const String themeSystem = "System";
  static const String themeLight = "Light";
  static const String themeDark = "Dark";

  // Auth Strings
  static const String loginTitle = "Welcome Back to\nEnglish Geni";
  static const String loginSubtitle = "Login to your account to continue";
  static const String loginBtn = "Login";
  static const String loginWithOtpBtn = "Login with OTP instead";
  static const String loginBypassBtn = "Bypass";
  static const String signupLinkText = "Don't have an account? ";
  static const String signupLinkAction = "Sign Up";
  static const String forgotPasswordLink = "Forgot Password?";

  static const String signupTitle = "Create Account in\nEnglish Gine";
  static const String signupSubtitle = "Sign up with name, gmail, and password";
  static const String signupBtn = "Register";
  static const String loginLinkText = "Already have an account? ";
  static const String loginLinkAction = "Login";

  static const String otpTitle = "Verify OTP";
  static const String otpSubtitle = "Enter the 6-digit OTP code sent to your Gmail";
  static const String otpBtn = "Verify Code";
  static const String resendOtpText = "Didn't receive the code? ";
  static const String resendOtpAction = "Resend";

  static const String forgotPasswordTitle = "Forgot Password";
  static const String forgotPasswordSubtitle = "Enter your Gmail address to receive a password reset link";
  static const String forgotPasswordBtn = "Send Reset Link";

  // Form Fields & Validations
  static const String fieldName = "Name";
  static const String fieldGmail = "Gmail";
  static const String fieldPassword = "Password";
  static const String fieldConfirmPassword = "Confirm Password";
  static const String fieldOtp = "Verification Code";

  static const String valRequiredName = "Name is required";
  static const String valRequiredGmail = "Gmail address is required";
  static const String valInvalidGmail = "Enter a valid Gmail address";
  static const String valRequiredPassword = "Password is required";
  static const String valMinLengthPassword = "Password must be at least 6 characters";
  static const String valRequiredConfirmPassword = "Please confirm your password";
  static const String valPasswordMismatch = "Passwords do not match";
  static const String valRequiredOtp = "OTP is required";
  static const String valInvalidOtp = "Enter a 6-digit OTP code";

  static const String backPressExit = "Press back again to exit";
  static const String backPressGoBack = "Press back again to go back";

  // Instance Getters
  String get nameApp => appName;
  String get sysTheme => themeSystem;
  String get lightTheme => themeLight;
  String get darkTheme => themeDark;

  String get titleLogin => loginTitle;
  String get subtitleLogin => loginSubtitle;
  String get btnLogin => loginBtn;
  String get btnLoginWithOtp => loginWithOtpBtn;
  String get linkSignupText => signupLinkText;
  String get linkSignupAction => signupLinkAction;
  String get linkForgotPassword => forgotPasswordLink;

  String get titleSignup => signupTitle;
  String get subtitleSignup => signupSubtitle;
  String get btnSignup => signupBtn;
  String get linkLoginText => loginLinkText;
  String get linkLoginAction => loginLinkAction;

  String get titleOtp => otpTitle;
  String get subtitleOtp => otpSubtitle;
  String get btnOtp => otpBtn;
  String get textResendOtp => resendOtpText;
  String get actionResendOtp => resendOtpAction;

  String get titleForgotPassword => forgotPasswordTitle;
  String get subtitleForgotPassword => forgotPasswordSubtitle;
  String get btnForgotPassword => forgotPasswordBtn;

  String get nameField => fieldName;
  String get gmailField => fieldGmail;
  String get passwordField => fieldPassword;
  String get confirmPasswordField => fieldConfirmPassword;
  String get otpField => fieldOtp;

  String get requiredNameVal => valRequiredName;
  String get requiredGmailVal => valRequiredGmail;
  String get invalidGmailVal => valInvalidGmail;
  String get requiredPasswordVal => valRequiredPassword;
  String get minLengthPasswordVal => valMinLengthPassword;
  String get requiredConfirmPasswordVal => valRequiredConfirmPassword;
  String get passwordMismatchVal => valPasswordMismatch;
  String get requiredOtpVal => valRequiredOtp;
  String get invalidOtpVal => valInvalidOtp;

  String get msgBackPressExit => backPressExit;
  String get msgBackPressGoBack => backPressGoBack;

  String get btnBypass => loginBypassBtn;
}