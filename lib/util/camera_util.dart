import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class CameraUtil {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromCamera(BuildContext ctx) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (file != null) return File(file.path);
      return null;
    }

    if (status.isPermanentlyDenied) {
      final open = await showDialog<bool>(
        context: ctx,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Izin kamera dibutuhkan'),
          content: const Text('Buka pengaturan aplikasi untuk memberikan izin kamera.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Batal')),
            ElevatedButton(onPressed: () => Navigator.pop(dialogCtx, true), child: const Text('Buka Pengaturan')),
          ],
        ),
      );
      if (open == true) await openAppSettings();
      return null;
    }

    // ditolak sementara
    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Izin kamera ditolak')));
    return null;
  }
}