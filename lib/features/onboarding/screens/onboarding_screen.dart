import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:signage_app/core/constants/app_colors.dart';
import 'package:signage_app/core/constants/app_strings.dart';
import 'package:signage_app/core/services/api_service.dart';
import 'package:signage_app/core/utils/validators.dart';
import 'package:signage_app/providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _accountType = 'individual'; // 'individual' | 'corporate'
  File? _document;
  String? _documentName;
  bool _isSubmitting = false;

  // Corporate fields
  final _companyCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();

  // Individual fields
  final _nameCtrl = TextEditingController();
  final _aadharCtrl = TextEditingController();

  @override
  void dispose() {
    _companyCtrl.dispose();
    _gstCtrl.dispose();
    _nameCtrl.dispose();
    _aadharCtrl.dispose();
    super.dispose();
  }

  // ── Pick Document ─────────────────────────────────────────────────────────
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _document = File(result.files.single.path!);
        _documentName = result.files.single.name;
      });
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_document == null) {
      _showError('Please upload a verification document');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final api = ApiService();
      final data = _accountType == 'corporate'
          ? {
              'company_name': _companyCtrl.text.trim(),
              'gst_number': _gstCtrl.text.trim().toUpperCase(),
            }
          : {
              'full_name': _nameCtrl.text.trim(),
              'aadhar_number': _aadharCtrl.text.trim().replaceAll(' ', ''),
            };

      await api.submitOnboarding(
        accountType: _accountType,
        data: data,
        document: _document,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      _showError('Submission failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.read<AuthProvider>().logout().then(
              (_) {
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              Text(
                AppStrings.whoAreYou,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.selectType,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // ── Account Type Selector ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.person_rounded,
                      title: AppStrings.individual,
                      subtitle: AppStrings.individualDesc,
                      selected: _accountType == 'individual',
                      onTap: () => setState(() => _accountType = 'individual'),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TypeCard(
                      icon: Icons.business_rounded,
                      title: AppStrings.corporate,
                      subtitle: AppStrings.corporateDesc,
                      selected: _accountType == 'corporate',
                      onTap: () => setState(() => _accountType = 'corporate'),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Dynamic Form Fields ───────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: child,
                ),
                child: _accountType == 'corporate'
                    ? _CorporateFields(
                        key: const ValueKey('corporate'),
                        companyCtrl: _companyCtrl,
                        gstCtrl: _gstCtrl,
                      )
                    : _IndividualFields(
                        key: const ValueKey('individual'),
                        nameCtrl: _nameCtrl,
                        aadharCtrl: _aadharCtrl,
                      ),
              ),
              const SizedBox(height: 24),

              // ── Document Upload ───────────────────────────────────────
              _DocumentUploadCard(
                documentName: _documentName,
                accountType: _accountType,
                onTap: _pickDocument,
                isDark: isDark,
              ),
              const SizedBox(height: 32),

              // ── Submit Button ─────────────────────────────────────────
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _isSubmitting ? null : AppColors.primaryGradient,
                    color: _isSubmitting
                        ? (isDark ? AppColors.darkCard : AppColors.lightDivider)
                        : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            AppStrings.submit,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Account Type Card ─────────────────────────────────────────────────────────
class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryPurple.withValues(alpha: 0.12)
                : (isDark ? AppColors.darkCard : AppColors.lightCard),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primaryPurple
                  : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primaryPurple : null,
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.primaryPurple
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Corporate Fields ──────────────────────────────────────────────────────────
class _CorporateFields extends StatelessWidget {
  final TextEditingController companyCtrl;
  final TextEditingController gstCtrl;

  const _CorporateFields({
    super.key,
    required this.companyCtrl,
    required this.gstCtrl,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextFormField(
            controller: companyCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.companyName,
              prefixIcon: Icon(Icons.business_outlined),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, 'Company name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: gstCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.gstLabel,
              prefixIcon: Icon(Icons.receipt_long_outlined),
              hintText: '22AAAAA0000A1Z5',
            ),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(15),
            ],
            validator: Validators.gst,
          ),
        ],
      );
}

// ── Individual Fields ─────────────────────────────────────────────────────────
class _IndividualFields extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController aadharCtrl;

  const _IndividualFields({
    super.key,
    required this.nameCtrl,
    required this.aadharCtrl,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextFormField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.fullName,
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (v) => Validators.required(v, 'Full name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: aadharCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.aadharNumber,
              prefixIcon: Icon(Icons.credit_card_outlined),
              hintText: 'XXXX XXXX XXXX',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            validator: Validators.aadhar,
          ),
        ],
      );
}

// ── Document Upload Card ──────────────────────────────────────────────────────
class _DocumentUploadCard extends StatelessWidget {
  final String? documentName;
  final String accountType;
  final VoidCallback onTap;
  final bool isDark;

  const _DocumentUploadCard({
    required this.documentName,
    required this.accountType,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hint = accountType == 'corporate'
        ? 'Upload GST Certificate / COI (PDF/Image)'
        : 'Upload Aadhar Card (PDF/Image)';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: documentName != null
              ? AppColors.primaryPurple.withValues(alpha: 0.08)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: documentName != null
                ? AppColors.primaryPurple
                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: documentName != null
                    ? AppColors.primaryPurple.withValues(alpha: 0.2)
                    : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                documentName != null
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                color: documentName != null
                    ? AppColors.primaryPurple
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.uploadProof,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    documentName ?? hint,
                    style: TextStyle(
                      fontSize: 12,
                      color: documentName != null
                          ? AppColors.primaryPurple
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
