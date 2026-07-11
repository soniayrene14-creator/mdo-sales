import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/proformas/proformas_notifier.dart';

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
            ? const Center(child: CircularProgressIndicator())
            : proformasState.proformas == null || proformasState.proformas!.isEmpty
            ? const Center(child: Text('Aucune proforma trouvée'))
            : ListView.builder(
                padding: const EdgeInsets.all(AppSizes.padding),
                itemCount: proformasState.proformas!.length,
                itemBuilder: (context, index) {
                  final proforma = proformasState.proformas![index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.padding),
                    child: ListTile(
                      title: Text(proforma.proformaNumber),
                      subtitle: Text('Client : ${proforma.customerName ?? '-'}'),
                      trailing: Text('${proforma.totalAmount}'),
                      onTap: () => context.push('/account/proformas/proforma-detail/${proforma.id}'),
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
}
