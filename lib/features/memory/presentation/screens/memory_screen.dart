import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/network/api_service.dart';

class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  bool _isLoading = true;
  List<dynamic> _memories = [];

  @override
  void initState() {
    super.initState();
    _fetchMemories();
  }

  Future<void> _fetchMemories() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(apiServiceProvider);
      // user_123 is placeholder until Auth is wired in Phase 8
      final result = await apiService.getMemories('user_123');
      setState(() {
        _memories = result['memories'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load memories: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMemory(String memoryId) async {
    HapticFeedback.mediumImpact();
    // Logic to call backend delete
    await ref.read(apiServiceProvider).deleteMemory('user_123', memoryId);
    _fetchMemories();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Memory', style: AppTypography.headline.copyWith(color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.apexPurple))
          : _memories.isEmpty
              ? _buildEmptyState()
              : _buildMemoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.p32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.p24),
            Text(
              'No memories yet',
              style: AppTypography.title2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.p8),
            const Text(
              'APEX builds a memory of your preferences as you chat. Start a conversation to begin!',
              textAlign: TextAlign.center,
              style: AppTypography.callout,
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildMemoryList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.p16),
      itemCount: _memories.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.p12),
      itemBuilder: (context, index) {
        final memory = _memories[index];
        return _MemoryTile(
          content: memory['content'],
          category: memory['category'],
          onDelete: () => _deleteMemory(memory['id']),
        );
      },
    );
  }
}

class _MemoryTile extends StatelessWidget {
  final String content;
  final String category;
  final VoidCallback onDelete;

  const _MemoryTile({
    required this.content,
    required this.category,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight2;
    
    return Dismissible(
      key: Key(content + category),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.p16),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          border: Border.all(
            color: isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight3,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryBadge(category: category),
              ],
            ),
            const SizedBox(height: AppSpacing.p12),
            Text(
              content,
              style: AppTypography.body.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.apexPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Text(
        category.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: AppColors.apexPurple,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
