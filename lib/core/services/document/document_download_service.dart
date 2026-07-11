import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/result.dart';
import '../api/api_client.dart';

/// Downloads a server-generated PDF (invoice, proforma) and opens it with
/// the device's default viewer. The relevant endpoints require JWT auth, so
/// the file can't just be opened via its raw URL — it has to be fetched
/// through [ApiClient] (which attaches the Bearer token) and written to a
/// temporary file first.
class DocumentDownloadService {
  final ApiClient _apiClient;

  DocumentDownloadService(this._apiClient);

  Future<Result<void>> downloadAndOpen({required String path, required String fileName}) async {
    final result = await _apiClient.getBytes(path);
    if (result.isFailure) return Result.failure(error: result.error!);

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(result.data!);

      final openResult = await OpenFile.open(file.path);
      if (openResult.type != ResultType.done) {
        return Result.failure(error: openResult.message);
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
