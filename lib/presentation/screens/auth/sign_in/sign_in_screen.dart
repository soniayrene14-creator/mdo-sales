import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_text_field.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - AppSizes.padding * 2),
                child: const IntrinsicHeight(
                  child: Column(
                    children: [
                      _WelcomeMessage(),
                      _SignInForm(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeMessage extends StatelessWidget {
  const _WelcomeMessage();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        alignment: Alignment.center,
        // Scales down instead of overflowing when the available height is
        // compressed (e.g. keyboard open on a small screen).
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSizes.padding),
              Text(
                'Bienvenue !',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Bienvenue sur votre application de vente',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInForm extends ConsumerStatefulWidget {
  const _SignInForm();

  @override
  ConsumerState<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<_SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'Entrez votre email',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: _passwordController,
          labelText: 'Mot de passe',
          hintText: 'Entrez votre mot de passe',
          obscureText: true,
        ),
        const SizedBox(height: AppSizes.padding),
        AppButton(
          text: 'Se connecter',
          onTap: () async {
            // Dismiss the keyboard before navigating away: otherwise it only
            // closes as a side effect of this screen being disposed, which
            // can lag behind the dashboard's entrance transition and leave
            // blank space where the keyboard used to be.
            FocusScope.of(context).unfocus();

            try {
              final res = await AppDialog.showProgress(() async {
                return ref
                    .read(authNotifierProvider.notifier)
                    .signInWith(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
              });

              if (res.isFailure) {
                AppDialog.showError(error: res.error?.toString());
              }
            } catch (e) {
              AppDialog.showError(error: e.toString());
            }
          },
        ),
      ],
    );
  }
}
