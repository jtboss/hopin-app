import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';

import '../../constants/app_constants.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/analytics_service.dart';
import '../../utils/validators.dart';
import '../../widgets/loading_button.dart';
import '../main_navigation.dart';

/// Login and Registration screen with tab switching
/// Handles student authentication with @sun.ac.za email validation
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form keys
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register controllers
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _studentNumberController = TextEditingController();

  // Focus nodes
  final _loginEmailFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  final _registerEmailFocus = FocusNode();
  final _registerPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneNumberFocus = FocusNode();
  final _studentNumberFocus = FocusNode();

  // State
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedCountryCode = '+27';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _trackScreenView();
  }

  @override
  void dispose() {
    _tabController.dispose();
    
    // Dispose controllers
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _studentNumberController.dispose();

    // Dispose focus nodes
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    _registerEmailFocus.dispose();
    _registerPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _phoneNumberFocus.dispose();
    _studentNumberFocus.dispose();

    super.dispose();
  }

  void _trackScreenView() {
    final analytics = context.read<AnalyticsService>();
    analytics.trackScreenView('login_register', 'LoginRegisterScreen');
  }

  /// Handle login form submission
  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final analytics = context.read<AnalyticsService>();

    await analytics.trackFormSubmission('login', false);

    final user = await authService.signInWithEmail(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );

    if (user != null && mounted) {
      await analytics.trackFormSubmission('login', true);
      
      // Navigate to main app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  /// Handle registration form submission
  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final analytics = context.read<AnalyticsService>();

    await analytics.trackFormSubmission('register', false);

    // Clean phone number
    final cleanPhone = Validators.cleanPhoneNumber(
      '$_selectedCountryCode${_phoneNumberController.text.trim()}',
    );

    final user = await authService.registerWithEmail(
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: cleanPhone,
      studentNumber: Validators.cleanStudentNumber(
        _studentNumberController.text.trim(),
      ),
    );

    if (user != null && mounted) {
      await analytics.trackFormSubmission('register', true);
      
      // Show success message and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.registrationSuccessMessage),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to main app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            _buildHeader(),

            // Tab bar
            _buildTabBar(),

            // Tab view
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginTab(),
                  _buildRegisterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'H',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Welcome text
          Text(
            'Welcome to ${AppConstants.appName}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppConstants.smallPadding),

          Text(
            'Join the ${AppConstants.targetUniversity} ride-sharing community',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelWeight: FontWeight.w600,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Register'),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.largePadding),

                // Email field
                TextFormField(
                  controller: _loginEmailController,
                  focusNode: _loginEmailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  onFieldSubmitted: (_) => _loginPasswordFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Student Email',
                    hintText: 'your.name@sun.ac.za',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Password field
                TextFormField(
                  controller: _loginPasswordController,
                  focusNode: _loginPasswordFocus,
                  obscureText: _obscureLoginPassword,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validatePassword,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureLoginPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureLoginPassword = !_obscureLoginPassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Login button
                LoadingButton(
                  onPressed: _handleLogin,
                  isLoading: authService.isLoading,
                  text: 'Continue',
                ),

                if (authService.errorMessage != null) ...[
                  const SizedBox(height: AppConstants.defaultPadding),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                    ),
                    child: Text(
                      authService.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterTab() {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Form(
            key: _registerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.defaultPadding),

                // First name field
                TextFormField(
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateFirstName,
                  onFieldSubmitted: (_) => _lastNameFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Last name field
                TextFormField(
                  controller: _lastNameController,
                  focusNode: _lastNameFocus,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateLastName,
                  onFieldSubmitted: (_) => _registerEmailFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Email field
                TextFormField(
                  controller: _registerEmailController,
                  focusNode: _registerEmailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  onFieldSubmitted: (_) => _studentNumberFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Student Email',
                    hintText: 'your.name@sun.ac.za',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Student number field
                TextFormField(
                  controller: _studentNumberController,
                  focusNode: _studentNumberFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateStudentNumber,
                  onFieldSubmitted: (_) => _phoneNumberFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Student Number',
                    hintText: '12345678',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Phone number field with country picker
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                      ),
                      child: CountryCodePicker(
                        onChanged: (countryCode) {
                          setState(() {
                            _selectedCountryCode = countryCode.dialCode!;
                          });
                        },
                        initialSelection: 'ZA',
                        favorite: const ['+27', 'ZA'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneNumberController,
                        focusNode: _phoneNumberFocus,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final fullPhone = '$_selectedCountryCode${value?.trim() ?? ''}';
                          return Validators.validatePhoneNumber(fullPhone);
                        },
                        onFieldSubmitted: (_) => _registerPasswordFocus.requestFocus(),
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'XX XXX XXXX',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Password field
                TextFormField(
                  controller: _registerPasswordController,
                  focusNode: _registerPasswordFocus,
                  obscureText: _obscureRegisterPassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePassword,
                  onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureRegisterPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureRegisterPassword = !_obscureRegisterPassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.validatePasswordConfirmation(
                    _registerPasswordController.text,
                    value ?? '',
                  ),
                  onFieldSubmitted: (_) => _handleRegister(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding),

                // Register button
                LoadingButton(
                  onPressed: _handleRegister,
                  isLoading: authService.isLoading,
                  text: 'Continue',
                ),

                if (authService.errorMessage != null) ...[
                  const SizedBox(height: AppConstants.defaultPadding),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                    ),
                    child: Text(
                      authService.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}