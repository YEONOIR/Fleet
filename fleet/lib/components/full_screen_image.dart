import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final String? imageAsset;

  const FullScreenImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // พื้นหลังสีดำให้รูปเด่นขึ้น
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        // 💡 InteractiveViewer ช่วยให้ผู้ใช้ใช้นิ้วซูมเข้า-ออก หรือแพนดูรูปได้
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0, // ซูมได้สูงสุด 4 เท่า
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return Image.network(imageUrl!, fit: BoxFit.contain);
    } else if (imageFile != null) {
      return Image.file(imageFile!, fit: BoxFit.contain);
    } else if (imageAsset != null) {
      return Image.asset(imageAsset!, fit: BoxFit.contain);
    }
    return const Icon(Icons.broken_image, color: Colors.white, size: 100);
  }
}