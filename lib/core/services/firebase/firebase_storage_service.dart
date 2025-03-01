import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../storage/storage_service.dart';

/// Firebase implementation of StorageService
class FirebaseStorageService implements StorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService(this._storage);

  @override
  Future<String> uploadFile(File file, String storagePath) async {
    try {
      // Create storage reference
      final ref = _storage.ref().child(storagePath);

      // Upload file
      await ref.putFile(file);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadData(Uint8List data, String storagePath,
      {String? mimeType}) async {
    try {
      // Create storage reference
      final ref = _storage.ref().child(storagePath);

      // Create metadata if mimeType is provided
      SettableMetadata? metadata;
      if (mimeType != null) {
        metadata = SettableMetadata(contentType: mimeType);
      }

      // Upload data
      await ref.putData(data, metadata);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload data: ${e.toString()}');
    }
  }

  @override
  Future<File> downloadFile(String remoteUrl, String localPath) async {
    try {
      // Create local file
      final file = File(localPath);

      // Extract storage path from URL or use URL directly
      final ref = _getRefFromUrl(remoteUrl);

      // Download to file
      await ref.writeToFile(file);

      return file;
    } catch (e) {
      throw Exception('Failed to download file: ${e.toString()}');
    }
  }

  @override
  Future<Uint8List> downloadData(String remoteUrl) async {
    try {
      // Extract storage path from URL or use URL directly
      final ref = _getRefFromUrl(remoteUrl);

      // Download data
      final data = await ref.getData();

      if (data == null) {
        throw Exception('Downloaded data is null');
      }

      return data;
    } catch (e) {
      throw Exception('Failed to download data: ${e.toString()}');
    }
  }

  @override
  Future<String> getDownloadURL(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }

  /// Helper method to get a storage reference from a URL
  Reference _getRefFromUrl(String url) {
    // Check if this is already a download URL
    if (url.startsWith('http')) {
      // Try to extract the path from Firebase Storage URL
      // This is a simplistic approach and might need adjustment
      try {
        return _storage.refFromURL(url);
      } catch (e) {
        // If we can't get a reference from URL, use the URL as a path
        final fileName = path.basename(url);
        return _storage.ref().child('downloads/$fileName');
      }
    } else {
      // If it's not a URL, treat it as a storage path
      return _storage.ref().child(url);
    }
  }
}
