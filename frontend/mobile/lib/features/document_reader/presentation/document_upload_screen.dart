import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../shared/widgets/sahaayi_button.dart';
import '../providers/document_provider.dart';
import '../repositories/document_repository.dart';
import '../../text_to_speech/services/tts_service.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  File? _selectedFile;
  String _selectedCategory = 'IDENTITY';
  bool _isUploading = false;
  DocumentItem? _uploadedDoc;
  final _tts = TTSService();

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _selectedFile = File(picked.path);
        _uploadedDoc = null;
      });
    }
  }

  Future<void> _pickFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _uploadedDoc = null;
      });
    }
  }

  Future<void> _processUpload() async {
    if (_selectedFile == null) return;
    setState(() => _isUploading = true);

    try {
      final repo = ref.read(documentRepositoryProvider);
      final doc = await repo.uploadDocument(_selectedFile!, _selectedCategory);
      setState(() {
        _uploadedDoc = doc;
        _isUploading = false;
      });
      ref.invalidate(documentListProvider);
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('അപ്‌ലോഡ് പരാജയപ്പെട്ടു: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('രേഖ അപ്‌ലോഡ് (Document Reader)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Dropdown
            const Text('രേഖയുടെ തരം (Document Category):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'IDENTITY', child: Text('തിരിച്ചറിയൽ രേഖ (Aadhaar/PAN/Voter)')),
                DropdownMenuItem(value: 'PRESCRIPTION', child: Text('മെഡിക്കൽ കുറിപ്പടി (Prescription)')),
                DropdownMenuItem(value: 'PENSION', child: Text('പെൻഷൻ രേഖകൾ (Pension Docs)')),
                DropdownMenuItem(value: 'OTHER', child: Text('മറ്റു രേഖകൾ (Other Documents)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 20),

            // File selection preview card
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.5), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _selectedFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, size: 54, color: Colors.teal),
                          const SizedBox(height: 8),
                          Text(
                            'ക്യാമറയോ ഫയലോ തിരഞ്ഞെടുക്കുക',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFile!.path.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
                            size: 54,
                            color: Colors.teal,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              _selectedFile!.path.split(Platform.pathSeparator).last,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Camera & File buttons
            Row(
              children: [
                Expanded(
                  child: SahaayiButton(
                    label: 'ക്യാമറ (Camera)',
                    icon: Icons.camera_alt,
                    onPressed: _isUploading ? null : _pickFromCamera,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SahaayiButton(
                    label: 'ഫയൽ (Storage)',
                    icon: Icons.folder_open,
                    backgroundColor: Colors.teal,
                    onPressed: _isUploading ? null : _pickFromFile,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_selectedFile != null && _uploadedDoc == null)
              SahaayiButton(
                label: _isUploading ? 'പ്രോസസ്സ് ചെയ്യുന്നു...' : 'വായിക്കുക / അപ്‌ലോഡ് ചെയ്യുക (Read & OCR)',
                icon: Icons.document_scanner,
                backgroundColor: Colors.deepOrange,
                onPressed: _isUploading ? null : _processUpload,
              ),

            // OCR Extraction Result
            if (_uploadedDoc != null) ...[
              const Divider(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('വായിച്ചെടുത്ത വിവരങ്ങൾ (OCR Result):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.teal, size: 28),
                          tooltip: 'വായിച്ചു കേൾക്കുക (Read aloud)',
                          onPressed: () {
                            if (_uploadedDoc!.extractedText != null) {
                              _tts.speak(_uploadedDoc!.extractedText!);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _uploadedDoc!.extractedText ?? 'വിവരങ്ങൾ ലഭ്യമല്ല',
                      style: const TextStyle(fontSize: 17, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SahaayiButton(
                      label: 'പൂർത്തിയായി (Done)',
                      icon: Icons.check,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
