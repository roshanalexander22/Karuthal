import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/document_repository.dart';

final documentRepositoryProvider = Provider((ref) => DocumentRepository());
final documentListProvider = FutureProvider((ref) => ref.watch(documentRepositoryProvider).getDocuments());
