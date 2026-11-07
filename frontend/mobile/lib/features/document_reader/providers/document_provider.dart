import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../repositories/document_repository.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DocumentRepository(apiClient);
});

final documentListProvider = FutureProvider.autoDispose<List<DocumentItem>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.getDocuments();
});
