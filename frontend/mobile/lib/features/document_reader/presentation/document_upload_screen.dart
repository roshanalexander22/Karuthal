import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  String _selectedCategory = 'IDENTITY';
  bool _isUploading = false;

  final categories = [
    {'code': 'IDENTITY', 'label': 'തിരിച്ചറിയൽ കാർഡ് (ID)'},
    {'code': 'PRESCRIPTION', 'label': 'ഡോക്ടറുടെ കുറിപ്പ് (Prescription)'},
    {'code': 'MEDICAL', 'label': 'ചികിത്സാ രേഖ (Medical)'},
    {'code': 'BANK', 'label': 'ബാങ്ക് രേഖ (Bank Passbook)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('രേഖ അപ്‌ലോഡ് (Upload)'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'രേഖയുടെ വിഭാഗം തിരഞ്ഞെടുക്കുക:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: SahaayiColors.textMain),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat['code'];
                  return ChoiceChip(
                    label: Text(
                      cat['label']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : SahaayiColors.textMain,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: SahaayiColors.primary,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected
                            ? SahaayiColors.primary
                            : SahaayiColors.border,
                        width: 1.5,
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat['code']!);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Upload Dropzone
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: SahaayiColors.secondary.withAlpha(60),
                  border: Border.all(
                      color: SahaayiColors.primary.withAlpha(120), width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: SahaayiColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ക്യാമറ അല്ലെങ്കിൽ ഫയൽ തിരഞ്ഞെടുക്കുക',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: SahaayiColors.textMain),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PDF, JPEG, PNG ഫയലുകൾ പിന്തുണയ്ക്കുന്നു',
                      style: TextStyle(
                          fontSize: 13, color: SahaayiColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Camera Action Button
              SahaayiButton(
                label: 'ക്യാമറ വഴി പകർത്തുക (Take Photo)',
                icon: Icons.camera_alt_rounded,
                backgroundColor: SahaayiColors.primary,
                isLoading: _isUploading,
                onPressed: () {
                  setState(() => _isUploading = true);
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() => _isUploading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'രേഖ വിജയകരമായി സമർപ്പിച്ചു. OCR പരിശോധന പുരോഗമിക്കുന്നു.'),
                          backgroundColor: SahaayiColors.success,
                        ),
                      );
                      context.pop();
                    }
                  });
                },
              ),

              const SizedBox(height: 16),

              // File Picker Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side:
                      const BorderSide(color: SahaayiColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.folder_open_rounded,
                    size: 24, color: SahaayiColors.primaryDark),
                label: const Text(
                  'ഫയലുകൾ തിരഞ്ഞെടുക്കുക (Select PDF/Image)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.primaryDark),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('രേഖ സ്വീകരിച്ചു. വിശകലനം ആരംഭിച്ചു.'),
                      backgroundColor: SahaayiColors.primaryDark,
                    ),
                  );
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
