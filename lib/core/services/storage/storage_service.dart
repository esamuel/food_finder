import 'dart:io';
import 'dart:typed_data';

/// Storage service interface for storing and retrieving files
abstract class StorageService {
  /// Upload a file from the local filesystem
  /// Returns the download URL for the uploaded file
  Future<String> uploadFile(File file, String path);

  /// Upload data as a file (useful for web platforms)
  /// Returns the download URL for the uploaded file
  Future<String> uploadData(Uint8List data, String path, {String? mimeType});

  /// Download a file to the local filesystem
  Future<File> downloadFile(String remoteUrl, String localPath);

  /// Download file data
  Future<Uint8List> downloadData(String remoteUrl);

  /// Get the download URL for a file
  Future<String> getDownloadURL(String path);

  /// Delete a file
  Future<void> deleteFile(String path);
}