class DocumentRepository {
  Future<List<Map<String, dynamic>>> getDocuments() async {
    return [
      {"id": "1", "name": "Aadhaar Card", "category": "IDENTITY", "status": "VERIFIED"},
      {"id": "2", "name": "Medical Prescription", "category": "PRESCRIPTION", "status": "PENDING"},
    ];
  }
}
