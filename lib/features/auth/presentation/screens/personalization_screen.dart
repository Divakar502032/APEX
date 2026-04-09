import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/router/app_router.dart';
import '../../chat/domain/chat_provider.dart';

enum UseCase { work, study, creative, dev }
enum ResponseStyle { concise, detailed, bullet, conversational }

class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  final TextEditingController _nameController = TextEditingController();
  UseCase _selectedUseCase = UseCase.work;
  ResponseStyle _selectedStyle = ResponseStyle.conversational;
  bool _isSaving = false;

  static const _useCases = [
    (value: UseCase.work, label: '💼 Work', desc: 'Productivity, meetings, emails'),
    (value: UseCase.study, label: '📚 Study', desc: 'Research, notes, learning'),
    (value: UseCase.creative, label: '🎨 Creative', desc: 'Writing, design, ideas'),
    (value: UseCase.dev, label: '💻 Developer', desc: 'Code, debugging, architecture'),
  ];

  static const _styles = [
    (value: ResponseStyle.concise, label: 'Concise', icon: '⚡'),
    (value: ResponseStyle.detailed, label: 'Detailed', icon: '📖'),
    (value: ResponseStyle.bullet, label: 'Bullets', icon: '📋'),
    (value: ResponseStyle.conversational, label: 'Conversational', icon: '💬'),
  ];

  Future<void> _saveAndContinue() async {
    HapticFeedback.mediumImpact();
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // Save name to Hive
      final name = _nameController.text.trim();
      final hive = ref.read(hiveServiceProvider);
      await hive.saveUserName(name.isEmpty ? 'Friend' : name);
      await hive.setHasSeenOnboarding(true);

      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to the main chat screen (GoRouter will handle this with auth state)
      if (mounted) {
        // Temp placeholder — GoRouter redirect will handle this properly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome, ${_nameController.text.isEmpty ? "there" : _nameController.text}! APEX is ready. 🚀',
              style: AppTypography.callout.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.apexPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.medium)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final inputBg = isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight3;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.p40),

              Text(AppStrings.personalizationTitle,
                  style: AppTypography.title1.copyWith(color: textColor))
                  .animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.p8),

              Text(AppStrings.personalizationSubtitle,
                  style: AppTypography.callout.copyWith(color: AppColors.textSecondary, height: 1.5))
                  .animate().fadeIn(delay: 100.ms),

              const SizedBox(height: AppSpacing.p32),

              // Name input
              Text('Your name', style: AppTypography.footnote.copyWith(color: AppColors.textSecondary))
                  .animate().fadeIn(delay: 150.ms),
              const SizedBox(height: AppSpacing.p8),
              TextField(
                controller: _nameController,
                style: AppTypography.body.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: 'What should APEX call you?',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p16, vertical: AppSpacing.p16),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppSpacing.p32),

              // Use case selection
              Text('Primary use', style: AppTypography.footnote.copyWith(color: AppColors.textSecondary))
                  .animate().fadeIn(delay: 250.ms),
              const SizedBox(height: AppSpacing.p12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.p12,
                crossAxisSpacing: AppSpacing.p12,
                childAspectRatio: 2.4,
                children: _useCases.map((uc) {
                  final isSelected = _selectedUseCase == uc.value;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedUseCase = uc.value);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.apexPurple.withOpacity(0.15)
                            : inputBg,
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        border: Border.all(
                          color: isSelected ? AppColors.apexPurple : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.p12, vertical: AppSpacing.p8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(uc.label,
                                style: AppTypography.subhead.copyWith(
                                  color: isSelected ? AppColors.apexPurple : textColor,
                                  fontWeight: FontWeight.w600,
                                )),
                            Text(uc.desc,
                                style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppSpacing.p32),

              // Response style
              Text('Response style', style: AppTypography.footnote.copyWith(color: AppColors.textSecondary))
                  .animate().fadeIn(delay: 350.ms),
              const SizedBox(height: AppSpacing.p12),
              Wrap(
                spacing: AppSpacing.p8,
                runSpacing: AppSpacing.p8,
                children: _styles.map((s) {
                  final isSelected = _selectedStyle == s.value;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedStyle = s.value);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.apexPurple : inputBg,
                        borderRadius: BorderRadius.circular(AppRadii.full),
                        border: Border.all(
                          color: isSelected ? AppColors.apexPurple : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '${s.icon} ${s.label}',
                        style: AppTypography.subhead.copyWith(
                          color: isSelected ? Colors.white : textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppSpacing.p48),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.apexPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.xlarge)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text("Let's Go 🚀",
                          style: AppTypography.headline.copyWith(color: Colors.white)),
                ),
              ).animate().fadeIn(delay: 480.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: AppSpacing.p40),
            ],
          ),
        ),
      ),
    );
  }
}
