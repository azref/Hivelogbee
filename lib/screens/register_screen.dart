import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../services/ad_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- باقي الكود يبقى كما هو ---
  @override
  Widget build(BuildContext context) {
    // ... لا تغيير هنا ...
    return AdAwareScaffold(
      screen: AdScreen.settings,
      showBannerAd: false,
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.darkBrown,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildRegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // ... لا تغيير هنا ...
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryYellow.withAlpha(76), // تم التعديل
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            size: 40,
            color: AppTheme.darkBrown,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBrown,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'انضم إلى مجتمع النحالين',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.darkBrown.withAlpha(178), // تم التعديل
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    // ... لا تغيير هنا ...
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          elevation: 8,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 16),
                  _buildTermsCheckbox(),
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(authProvider.errorMessage!),
                  ],
                  const SizedBox(height: 24),
                  _buildRegisterButton(authProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameField() {
    // ... لا تغيير هنا ...
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'الاسم الكامل',
        prefixIcon: Icon(
          Icons.person_outlined,
          color: AppTheme.primaryYellow,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryYellow,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال الاسم الكامل';
        }
        if (value.trim().length < 2) {
          return 'الاسم يجب أن يكون حرفين على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    // ... لا تغيير هنا ...
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: AppTheme.primaryYellow,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryYellow,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال البريد الإلكتروني';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'يرجى إدخال بريد إلكتروني صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    // ... لا تغيير هنا ...
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: AppTheme.primaryYellow,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.darkBrown.withAlpha(153), // تم التعديل
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryYellow,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
          return 'كلمة المرور يجب أن تحتوي على أحرف وأرقام';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    // ... لا تغيير هنا ...
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: AppTheme.primaryYellow,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: AppTheme.darkBrown.withAlpha(153), // تم التعديل
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryYellow,
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى تأكيد كلمة المرور';
        }
        if (value != _passwordController.text) {
          return 'كلمة المرور غير متطابقة';
        }
        return null;
      },
      onFieldSubmitted: (_) => _register(),
    );
  }

  Widget _buildTermsCheckbox() {
    // ... لا تغيير هنا ...
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppTheme.primaryYellow,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppTheme.darkBrown,
                  fontSize: 14,
                ),
                children: [
                  const TextSpan(text: 'أوافق على '),
                  TextSpan(
                    text: 'شروط الاستخدام',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' و '),
                  TextSpan(
                    text: 'سياسة الخصوصية',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    // ... لا تغيير هنا ...
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withAlpha(25), // تم التعديل
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.errorColor.withAlpha(76), // تم التعديل
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(AuthProvider authProvider) {
    // ... لا تغيير هنا ...
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: authProvider.isLoading || !_acceptTerms ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryYellow,
          foregroundColor: AppTheme.darkBrown,
          disabledBackgroundColor: AppTheme.primaryYellow.withAlpha(128), // تم التعديل
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: authProvider.isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkBrown),
          ),
        )
            : const Text(
          'إنشاء الحساب',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- تمت إضافة جملة print هنا ---
  Future<void> _register() async {
    print("--- _register function in RegisterScreen CALLED ---");

    if (!_formKey.currentState!.validate()) {
      print("--- Form is NOT valid. Aborting. ---");
      return;
    }
    if (!_acceptTerms) {
      print("--- Terms not accepted. Aborting. ---");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على شروط الاستخدام'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    print("--- Form is valid and terms are accepted. Calling AuthProvider. ---");
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.createUserWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (success && mounted) {
      print("--- Registration successful. Navigating to HomeScreen. ---");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الحساب بنجاح! مرحباً بك في HiveLog Bee'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      print("--- Registration failed. Error message should be visible. ---");
    }
  }
}
