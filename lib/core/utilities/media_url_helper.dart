import 'package:flutter_pos/core/constants/constants.dart';

String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final normalized = path.startsWith('/') ? path.substring(1) : path;
  final mediaPath = normalized.startsWith('media/') ? normalized : 'media/$normalized';
  return '${Constants.baseUrl}/$mediaPath';
}