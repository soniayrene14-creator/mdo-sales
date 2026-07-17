import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/employees/employees_notifier.dart';
import '../../providers/main/main_notifier.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

enum _EmployeeAction { edit, toggleActive, resetPassword }

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeesNotifierProvider.notifier).getEmployees();
    });
  }

  @override
  void dispose() {
    searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(employeesNotifierProvider.select((s) => s.employees));
    final isLoading = ref.watch(employeesNotifierProvider.select((s) => s.isLoading));
    final currentUserId = ref.watch(mainNotifierProvider.select((p) => p.user?.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: AppTextField(
              controller: searchFieldController,
              hintText: 'Rechercher des employés...',
              type: AppTextFieldType.search,
              textInputAction: TextInputAction.search,
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                ref.read(employeesNotifierProvider.notifier).getEmployees(search: searchFieldController.text);
              },
              onTapClearButton: () {
                ref.read(employeesNotifierProvider.notifier).getEmployees(search: searchFieldController.text);
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(employeesNotifierProvider.notifier).getEmployees(search: searchFieldController.text),
              child: _buildBody(employees, isLoading, currentUserId),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeFormDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(List<UserEntity>? employees, bool isLoading, String? currentUserId) {
    if (isLoading && employees == null) {
      return const AppProgressIndicator();
    }

    if (employees == null || employees.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const AppEmptyState(subtitle: 'Aucun employé trouvé'),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.padding),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final isActive = employee.isActive ?? true;
        final isSelf = employee.id == currentUserId;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSizes.padding / 2),
          child: Opacity(
            opacity: isActive ? 1 : 0.5,
            child: ListTile(
              title: Text(employee.name ?? employee.username ?? employee.email ?? 'Inconnu'),
              subtitle: Text('${employee.email ?? ''} • ${employee.role ?? ''}${isActive ? '' : ' • Inactif'}'),
              trailing: PopupMenuButton<_EmployeeAction>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) {
                  switch (action) {
                    case _EmployeeAction.edit:
                      _showEmployeeFormDialog(context, employee: employee);
                    case _EmployeeAction.toggleActive:
                      _confirmToggleActive(employee, isActive);
                    case _EmployeeAction.resetPassword:
                      _confirmResetPassword(employee);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: _EmployeeAction.edit, child: Text('Modifier')),
                  // Prevent self-lockout: an admin must not be able to deactivate their own account.
                  if (!isSelf)
                    PopupMenuItem(
                      value: _EmployeeAction.toggleActive,
                      child: Text(isActive ? 'Désactiver' : 'Réactiver'),
                    ),
                  const PopupMenuItem(
                    value: _EmployeeAction.resetPassword,
                    child: Text('Réinitialiser le mot de passe'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEmployeeFormDialog(BuildContext context, {UserEntity? employee}) {
    final isEditing = employee != null;

    final usernameController = TextEditingController(text: employee?.username);
    final nameController = TextEditingController(text: employee?.name);
    final emailController = TextEditingController(text: employee?.email);
    final phoneController = TextEditingController(text: employee?.phone);
    String role = employee?.role ?? 'employe';

    AppDialog.show(
      title: isEditing ? 'Modifier l\'employé' : 'Nouvel employé',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.padding),
              child: AppTextField(
                controller: usernameController,
                labelText: 'Nom d\'utilisateur',
                hintText: 'Nom d\'utilisateur de connexion',
              ),
            ),
          AppTextField(
            controller: nameController,
            labelText: 'Nom',
            hintText: 'Nom complet',
          ),
          const SizedBox(height: AppSizes.padding),
          AppTextField(
            controller: emailController,
            labelText: 'Email',
            hintText: 'Email de l\'employé',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSizes.padding),
          AppTextField(
            controller: phoneController,
            labelText: 'Téléphone',
            hintText: 'Numéro de téléphone',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppSizes.padding),
          AppDropDown<String>(
            labelText: 'Rôle',
            selectedValue: role,
            dropdownItems: const [
              DropdownMenuItem(value: 'employe', child: Text('Employé')),
              DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
            ],
            onChanged: (value) {
              if (value != null) role = value;
            },
          ),
        ],
      ),
      rightButtonText: 'Enregistrer',
      onTapRightButton: (dialogContext) async {
        final name = nameController.text.trim();
        final email = emailController.text.trim();
        if (name.isEmpty || email.isEmpty) return;

        final notifier = ref.read(employeesNotifierProvider.notifier);

        if (isEditing) {
          final res = await notifier.updateEmployee(
            employee.copyWith(name: name, email: email, phone: phoneController.text.trim(), role: role),
          );

          if (!mounted) return;
          if (res.isSuccess) {
            Navigator.of(dialogContext).pop();
          } else {
            AppDialog.showError(error: res.error?.toString() ?? 'Échec de la mise à jour de l\'employé');
          }
        } else {
          final username = usernameController.text.trim();
          if (username.isEmpty) return;

          final res = await notifier.createEmployee(
            username: username,
            name: name,
            email: email,
            phone: phoneController.text.trim(),
            role: role,
          );

          if (!mounted) return;
          if (res.isSuccess) {
            Navigator.of(dialogContext).pop();
            _showGeneratedPassword(res.data!.generatedPassword);
          } else {
            AppDialog.showError(error: res.error?.toString() ?? 'Échec de la création de l\'employé');
          }
        }
      },
    );
  }

  void _confirmToggleActive(UserEntity employee, bool isActive) {
    AppDialog.show(
      title: 'Confirmer',
      text: isActive
          ? 'Désactiver ${employee.name ?? employee.email} ? Cette personne ne pourra plus se connecter.'
          : 'Réactiver ${employee.name ?? employee.email} ?',
      leftButtonText: 'Annuler',
      rightButtonText: isActive ? 'Désactiver' : 'Réactiver',
      onTapRightButton: (context) async {
        context.pop();

        final res = await AppDialog.showProgress(() {
          return ref.read(employeesNotifierProvider.notifier).setEmployeeActive(employee, !isActive);
        });

        if (res.isFailure) {
          AppSnackBar.showError(res.error.toString());
        }
      },
    );
  }

  void _confirmResetPassword(UserEntity employee) {
    AppDialog.show(
      title: 'Réinitialiser le mot de passe',
      text: 'Générer un nouveau mot de passe pour ${employee.name ?? employee.email} ?',
      leftButtonText: 'Annuler',
      rightButtonText: 'Réinitialiser',
      onTapRightButton: (context) async {
        context.pop();

        final res = await AppDialog.showProgress(() {
          return ref.read(employeesNotifierProvider.notifier).resetPassword(employee.id);
        });

        if (!mounted) return;

        if (res.isSuccess) {
          _showGeneratedPassword(res.data!);
        } else {
          AppSnackBar.showError(res.error.toString());
        }
      },
    );
  }

  void _showGeneratedPassword(String password) {
    AppDialog.show(
      title: 'Nouveau mot de passe généré',
      text: 'Partagez ce mot de passe avec l\'employé. Il ne sera plus affiché par la suite :\n\n$password',
      leftButtonText: 'Fermer',
      rightButtonText: 'Copier',
      onTapRightButton: (context) async {
        await Clipboard.setData(ClipboardData(text: password));
        AppSnackBar.show('Mot de passe copié');
      },
    );
  }
}
