import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker/core/constants/app_sizes.dart';
import 'package:money_tracker/core/routing/app_routes.dart';
import 'package:money_tracker/core/utils/haptic_feedback.dart';
import 'package:money_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:money_tracker/features/dashboard/domain/entities/workspace_overview.dart';
import 'package:money_tracker/features/dashboard/domain/entities/workspace_setup_input.dart';
import 'package:money_tracker/features/dashboard/presentation/providers/dashboard_providers.dart';

class WorkspaceSetupScreen extends ConsumerStatefulWidget {
  const WorkspaceSetupScreen({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  ConsumerState<WorkspaceSetupScreen> createState() =>
      _WorkspaceSetupScreenState();
}

class _WorkspaceSetupScreenState extends ConsumerState<WorkspaceSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  late final TextEditingController _budgetController;
  late final TextEditingController _currencyController;

  bool _isSubmitting = false;
  bool _prefilled = false;
  String? _workspaceId;
  bool _bootstrapping = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _goalController = TextEditingController();
    _budgetController = TextEditingController();
    _currencyController = TextEditingController(text: 'USD');
    _workspaceId = widget.workspaceId.isEmpty ? null : widget.workspaceId;
    Future.microtask(_ensureWorkspaceIfNeeded);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _budgetController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _ensureWorkspaceIfNeeded() async {
    if (_workspaceId != null && _workspaceId!.isNotEmpty) {
      return;
    }

    final user = ref.read(currentAuthUserProvider);
    if (user == null) {
      return;
    }

    setState(() => _bootstrapping = true);
    final ensureWorkspace = ref.read(ensureWorkspaceInitializedProvider);
    final result = await ensureWorkspace(user.uid);
    if (!mounted) return;
    setState(() {
      _workspaceId = result.workspaceId;
      _bootstrapping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    if (_workspaceId == null || _bootstrapping) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final workspacesAsync = ref.watch(dashboardWorkspacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.workspaceSetupAppBarTitle),
        centerTitle: true,
      ),
      body: workspacesAsync.when(
        data: (workspaces) {
          WorkspaceOverview? workspace;
          for (final item in workspaces) {
            if (item.id == _workspaceId) {
              workspace = item;
              break;
            }
          }
          workspace ??= workspaces.isNotEmpty ? workspaces.first : null;

          if (!_prefilled && workspace != null) {
            _prefilled = true;
            _nameController.text = workspace.name.isEmpty ? '' : workspace.name;
            _goalController.text = workspace.goal.isEmpty ? '' : workspace.goal;
            _currencyController.text =
                workspace.currency.isEmpty ? 'USD' : workspace.currency;
            _budgetController.text =
                workspace.budget == 0
                    ? ''
                    : workspace.budget.toStringAsFixed(
                      workspace.budget.truncateToDouble() == workspace.budget
                          ? 0
                          : 2,
                    );
          }

          return _WorkspaceSetupForm(
            formKey: _formKey,
            nameController: _nameController,
            goalController: _goalController,
            budgetController: _budgetController,
            currencyController: _currencyController,
            isSubmitting: _isSubmitting,
            onSubmit: () => _submit(t),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: AppSizes.spacing12),
                  Text(t.workspaceSetupLoadFailed),
                  const SizedBox(height: AppSizes.spacing12),
                  FilledButton(
                    onPressed:
                        () => ref.invalidate(dashboardWorkspacesProvider),
                    child: Text(t.dashboardRetry),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Future<void> _submit(AppLocalizations t) async {
    if (_workspaceId == null || _workspaceId!.isEmpty) {
      await HapticFeedbackHelper.error();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      await HapticFeedbackHelper.error();
      return;
    }

    final user = ref.read(currentAuthUserProvider);
    if (user == null) {
      await HapticFeedbackHelper.error();
      return;
    }

    setState(() => _isSubmitting = true);

    final saveWorkspace = ref.read(saveWorkspaceDetailsProvider);

    try {
      final input = WorkspaceSetupInput(
        name: _nameController.text.trim(),
        goal: _goalController.text.trim(),
        budget: double.parse(
          _budgetController.text.replaceAll(',', '.').isEmpty
              ? '0'
              : _budgetController.text.replaceAll(',', '.'),
        ),
        currency: _currencyController.text.trim().toUpperCase(),
      );

      await saveWorkspace(user.uid, _workspaceId!, input);
      ref.invalidate(dashboardWorkspacesProvider);
      await HapticFeedbackHelper.success();
      if (!mounted) return;
      GoRouter.of(context).go(AppRoutes.dashboard);
    } catch (error) {
      await HapticFeedbackHelper.error();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.workspaceSetupFailed),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _WorkspaceSetupForm extends StatelessWidget {
  const _WorkspaceSetupForm({
    required this.formKey,
    required this.nameController,
    required this.goalController,
    required this.budgetController,
    required this.currencyController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController goalController;
  final TextEditingController budgetController;
  final TextEditingController currencyController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacing24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.workspaceSetupHeadline,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSizes.spacing12),
            Text(
              t.workspaceSetupDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSizes.spacing24),
            TextFormField(
              controller: nameController,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: t.workspaceNameLabel),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing16),
            TextFormField(
              controller: goalController,
              enabled: !isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: t.workspaceGoalLabel),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing16),
            TextFormField(
              controller: budgetController,
              enabled: !isSubmitting,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: t.workspaceBudgetLabel),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.fieldRequired;
                }
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed < 0) {
                  return t.invalidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing16),
            TextFormField(
              controller: currencyController,
              enabled: !isSubmitting,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: t.workspaceCurrencyLabel),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return t.fieldRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSizes.spacing32),
            FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.spacing12,
                ),
                child:
                    isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          t.workspaceSetupAction,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
