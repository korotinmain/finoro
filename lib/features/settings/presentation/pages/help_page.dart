import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_colors.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/ui/widgets/glow_blob.dart';

/// Help Center page with topics, FAQs, and quick tips
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<_HelpTopic> _getFilteredTopics(AppLocalizations t) {
    final allTopics = _getAllTopics(t);
    if (_searchQuery.isEmpty) {
      return allTopics;
    }
    return allTopics.where((topic) {
      return topic.title.toLowerCase().contains(_searchQuery) ||
          topic.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<_HelpTopic> _getAllTopics(AppLocalizations t) {
    return [
      _HelpTopic(
        icon: Icons.rocket_launch_rounded,
        title: t.helpGettingStarted,
        description: t.helpGettingStartedDesc,
        color: AppColors.vibrantPurple,
      ),
      _HelpTopic(
        icon: Icons.account_balance_wallet_rounded,
        title: t.helpManagingExpenses,
        description: t.helpManagingExpensesDesc,
        color: AppColors.primaryBlue,
      ),
      _HelpTopic(
        icon: Icons.savings_rounded,
        title: t.helpBudgeting,
        description: t.helpBudgetingDesc,
        color: AppColors.cyan,
      ),
      _HelpTopic(
        icon: Icons.analytics_rounded,
        title: t.helpInsights,
        description: t.helpInsightsDesc,
        color: Colors.greenAccent,
      ),
      _HelpTopic(
        icon: Icons.security_rounded,
        title: t.helpAccountSecurity,
        description: t.helpAccountSecurityDesc,
        color: Colors.orangeAccent,
      ),
      _HelpTopic(
        icon: Icons.support_agent_rounded,
        title: t.helpContactSupport,
        description: t.helpContactSupportDesc,
        color: Colors.pinkAccent,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final filteredTopics = _getFilteredTopics(t);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
          ),
          GlowBlob.purpleBlue(size: AppSizes.blobMedium, left: -100, top: -50),
          GlowBlob.purpleCyan(
            size: AppSizes.blobLarge,
            right: -120,
            bottom: -100,
          ),
          SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.spacing16,
                    AppSizes.spacing12,
                    AppSizes.spacing16,
                    0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () {
                          HapticFeedbackHelper.lightImpact();
                          context.pop();
                        },
                      ),
                      const SizedBox(width: AppSizes.spacing8),
                      Text(
                        t.helpCenter,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spacing16),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing24,
                  ),
                  child: _SearchBar(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    hintText: t.helpSearchPlaceholder,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing24),
                // Content
                Expanded(
                  child:
                      filteredTopics.isEmpty
                          ? _EmptySearchResults(
                            message: t.helpNoResults,
                            subtitle: t.helpTryDifferentKeywords,
                          )
                          : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              AppSizes.spacing24,
                              0,
                              AppSizes.spacing24,
                              AppSizes.spacing24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Help Topics
                                ...filteredTopics.map(
                                  (topic) => _HelpTopicCard(
                                    topic: topic,
                                    onTap: () {
                                      HapticFeedbackHelper.lightImpact();
                                      _showTopicDetails(context, topic);
                                    },
                                  ),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: AppSizes.spacing32),
                                  // Quick Tips Section
                                  _SectionHeader(
                                    title: t.helpQuickTips,
                                    icon: Icons.lightbulb_rounded,
                                  ),
                                  const SizedBox(height: AppSizes.spacing16),
                                  _QuickTip(text: t.helpTip1),
                                  _QuickTip(text: t.helpTip2),
                                  _QuickTip(text: t.helpTip3),
                                ],
                              ],
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTopicDetails(BuildContext context, _HelpTopic topic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TopicDetailsSheet(topic: topic),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.white(0.1)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon:
              controller.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacing16,
            vertical: AppSizes.spacing14,
          ),
        ),
      ),
    );
  }
}

class _HelpTopic {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _HelpTopic({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _HelpTopicCard extends StatelessWidget {
  final _HelpTopic topic;
  final VoidCallback onTap;

  const _HelpTopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.spacing16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              border: Border.all(color: AppColors.white(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: topic.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: Icon(topic.icon, color: topic.color, size: 26),
                ),
                const SizedBox(width: AppSizes.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing4),
                      Text(
                        topic.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.vibrantPurple),
        const SizedBox(width: AppSizes.spacing8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QuickTip extends StatelessWidget {
  final String text;

  const _QuickTip({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing12),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacing14),
        decoration: BoxDecoration(
          color: AppColors.vibrantPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: AppColors.vibrantPurple.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ),
    );
  }
}

class _EmptySearchResults extends StatelessWidget {
  final String message;
  final String subtitle;

  const _EmptySearchResults({required this.message, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicDetailsSheet extends StatelessWidget {
  final _HelpTopic topic;

  const _TopicDetailsSheet({required this.topic});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: AppSizes.spacing12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSizes.spacing24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacing24,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: topic.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: Icon(topic.icon, color: topic.color, size: 30),
                    ),
                    const SizedBox(width: AppSizes.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacing4),
                          Text(
                            topic.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacing24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing24,
                  ),
                  children: [
                    _buildDetailedContent(context, topic, t),
                    const SizedBox(height: AppSizes.spacing32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailedContent(
    BuildContext context,
    _HelpTopic topic,
    AppLocalizations t,
  ) {
    final theme = Theme.of(context);

    // Placeholder content - you can expand this based on each topic
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coming Soon',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.spacing12),
        Text(
          'Detailed help content for "${topic.title}" will be available soon. '
          'In the meantime, feel free to explore other help topics or contact support.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
