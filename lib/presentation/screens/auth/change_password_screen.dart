import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/auth/change_password_notifier.dart';
import '../../providers/auth/change_password_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_snack_bar.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordState = ref.watch(changePasswordNotifierProvider);

    ref.listen<ChangePasswordState>(changePasswordNotifierProvider, (previous, next) {
      if (next.error != null) {
        AppDialog.showError(error: next.error!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Changer le mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            AppTextField(
              controller: _oldPasswordController,
              labelText: 'Ancien mot de passe',
              hintText: 'Entrez le mot de passe actuel',
              obscureText: true,
            ),
            const SizedBox(height: AppSizes.padding),
            AppTextField(
              controller: _newPasswordController,
              labelText: 'Nouveau mot de passe',
              hintText: 'Entrez le nouveau mot de passe',
              obscureText: true,
            ),
            const SizedBox(height: AppSizes.padding * 2),
            AppButton(
              text: 'Changer le mot de passe',
              onTap: passwordState.isLoading
                  ? null
                  : () async {
                      final oldPassword = _oldPasswordController.text.trim();
                      final newPassword = _newPasswordController.text.trim();
                      if (oldPassword.isEmpty || newPassword.isEmpty) return;

                      final res = await AppDialog.showProgress(
                        () =>
                            ref.read(changePasswordNotifierProvider.notifier).changePassword(oldPassword, newPassword),
                      );

                      if (res.isSuccess) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mot de passe modifié avec succès')),
                        );
                        _oldPasswordController.clear();
                        _newPasswordController.clear();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
