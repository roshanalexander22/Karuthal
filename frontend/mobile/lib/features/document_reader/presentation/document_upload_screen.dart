import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('രേഖ അപ്‌ലോഡ് (Upload)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.teal),
                  SizedBox(height: 12),
                  Text('ക്യാമറ അല്ലെങ്കിൽ ഫയൽ തിരഞ്ഞെടുക്കുക', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SahaayiButton(
              label: 'ക്യാമറ തുറക്കുക (Camera)',
              icon: Icons.camera_alt,
              onPressed: () {},
            ),
            const SizedBox(height: 16),
            SahaayiButton(
              label: 'ഫയൽ തിരഞ്ഞെടുക്കുക (Select PDF/Image)',
              icon: Icons.folder,
              backgroundColor: Colors.teal,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
