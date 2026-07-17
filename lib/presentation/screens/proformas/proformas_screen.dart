import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/proforma_entity.dart';
import '../../providers/proformas/proformas_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';

enum _ProformaAction { edit, delete }

class ProformasScreen extends ConsumerStatefulWidget {
  const ProformasScreen({super.key});

  @override
  ConsumerState<ProformasScreen> createState() => _ProformasScreenState();
}

class _ProformasScreenState extends ConsumerState<ProformasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(proformasNotifierProvider.notifier).loadProformas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proformasState = ref.watch(proformasNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Proformas')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(proformasNotifierProvider.notifier).loadProformas(),
        child: proformasState.isLoading && proformasState.proformas == null
            ? const Center(child: AppProgressIndicator())
            : proformasState.proformas == null && proformasState.error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppErrorWidget(message: proformasState.error),
                    const SizedBox(height: AppSizes.padding),
                    AppButton(
                      text: 'Réessayer',
                      width: 160,
                      onTap: () => ref.read(proformasNotifierProvider.notifier).loadProformas(),
                    ),
                  ],
                ),
              )
            : proformasState.proformas == null || proformasState.proformas!.isEmpty
            ? const AppEmptyState(subtitle: 'Aucune proforma trouvée')
            : ListView.builder(
                padding: const EdgeInsets.all(AppSizes.padding),
                itemCount: proformasState.proformas!.length,
                itemBuilder: (context, index) {
                  final proforma = proformasState.proformas![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.padding),
                    child: ListTile(
                      title: Text(proforma.proformaNumber),
                      subtitle: Text(
                        'Client : ${proforma.customerName ?? '-'} • ${CurrencyFormatter.format(proforma.totalAmount)}',
                      ),
                      onTap: () => context.push('/account/proformas/proforma-detail/${proforma.id}'),
                      trailing: PopupMenuButton<_ProformaAction>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (action) {
                          switch (action) {
                            case _ProformaAction.edit:
                              context.push('/account/proformas/proforma-edit/${proforma.id}');
                            case _ProformaAction.delete:
                              _confirmDelete(proforma);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: _ProformaAction.edit, child: Text('Modifier')),
                          PopupMenuItem(value: _ProformaAction.delete, child: Text('Supprimer')),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/account/proformas/proforma-create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(ProformaEntity proforma) {
    AppDialog.show(
      title: 'Confirmer',
      text: 'Voulez-vous vraiment supprimer le proforma ${proforma.proformaNumber} ?',
      leftButtonText: 'Annuler',
      rightButtonText: 'Supprimer',
      rightButtonColor: Theme.of(context).colorScheme.errorContainer,
      rightButtonTextColor: Theme.of(context).colorScheme.error,
      onTapRightButton: (context) async {
        context.pop();

        final res = await AppDialog.showProgress(() {
          return ref.read(proformasNotifierProvider.notifier).deleteProforma(proforma.id);
        });

        if (res.isFailure) {
          AppSnackBar.showError(res.error.toString());
        }
      },
    );
  }
}
