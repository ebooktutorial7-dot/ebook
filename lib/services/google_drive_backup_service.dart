// google_drive_backup_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDriveBackupResult {
  final String? id;
  final String? name;
  final String? webViewLink;

  const GoogleDriveBackupResult({
    required this.id,
    required this.name,
    required this.webViewLink,
  });
}

class GoogleDriveBackupService {
  GoogleDriveBackupService();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  static const String _iosClientId =
      '633779795446-53nb51j49rh34nki42k7is07b8av5si6.apps.googleusercontent.com';

  static const List<String> _scopes = <String>[drive.DriveApi.driveFileScope];

  Future<void> _initialize() async {
    if (_initialized) return;

    await _googleSignIn.initialize(
      clientId:
          defaultTargetPlatform == TargetPlatform.iOS ? _iosClientId : null,
    );

    _initialized = true;
  }

  Future<List<GoogleDriveBackupFile>> listBackupZipFiles() async {
    final account = await _getSignedInAccount();

    var authorization = await account.authorizationClient
        .authorizationForScopes(_scopes);

    authorization ??= await account.authorizationClient.authorizeScopes(
      _scopes,
    );

    final authClient = authorization.authClient(scopes: _scopes);

    try {
      final driveApi = drive.DriveApi(authClient);

      final result = await driveApi.files.list(
        q: "mimeType = 'application/zip' and trashed = false",
        orderBy: 'modifiedTime desc',
        pageSize: 20,
        $fields: 'files(id,name,modifiedTime,size)',
      );

      final files = result.files ?? const <drive.File>[];

      return files
          .where((file) => file.id != null && file.name != null)
          .map(
            (file) => GoogleDriveBackupFile(
              id: file.id!,
              name: file.name!,
              modifiedTime: file.modifiedTime,
              sizeBytes: int.tryParse(file.size ?? ''),
            ),
          )
          .toList();
    } finally {
      authClient.close();
    }
  }

  Future<List<int>> downloadFileBytes({required String fileId}) async {
    final account = await _getSignedInAccount();

    var authorization = await account.authorizationClient
        .authorizationForScopes(_scopes);

    authorization ??= await account.authorizationClient.authorizeScopes(
      _scopes,
    );

    final authClient = authorization.authClient(scopes: _scopes);

    try {
      final driveApi = drive.DriveApi(authClient);

      final media =
          await driveApi.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final bytes = <int>[];

      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      return bytes;
    } finally {
      authClient.close();
    }
  }

  Future<GoogleSignInAccount> _getSignedInAccount() async {
    await _initialize();

    GoogleSignInAccount? account;

    final lightweightAuth = _googleSignIn.attemptLightweightAuthentication();

    if (lightweightAuth != null) {
      try {
        account = await lightweightAuth;
      } catch (_) {
        account = null;
      }
    }

    account ??= await _googleSignIn.authenticate(scopeHint: _scopes);

    return account;
  }

  Future<GoogleDriveBackupResult> uploadJson({
    required String fileName,
    required Map<String, dynamic> jsonData,
  }) async {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonData);
    final bytes = utf8.encode(prettyJson);

    return _uploadBytes(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
      contentType: 'application/json; charset=utf-8',
    );
  }

  Future<GoogleDriveBackupResult> uploadZipFile({
    required File zipFile,
    required String fileName,
  }) async {
    final account = await _getSignedInAccount();

    var authorization = await account.authorizationClient
        .authorizationForScopes(_scopes);

    authorization ??= await account.authorizationClient.authorizeScopes(
      _scopes,
    );

    final authClient = authorization.authClient(scopes: _scopes);

    try {
      final driveApi = drive.DriveApi(authClient);

      final driveFile =
          drive.File()
            ..name = fileName
            ..mimeType = 'application/zip';

      final media = drive.Media(
        zipFile.openRead(),
        await zipFile.length(),
        contentType: 'application/zip',
      );

      final created = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
        $fields: 'id,name,webViewLink',
      );

      return GoogleDriveBackupResult(
        id: created.id,
        name: created.name,
        webViewLink: created.webViewLink,
      );
    } finally {
      authClient.close();
    }
  }

  Future<GoogleDriveBackupResult> _uploadBytes({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    required String contentType,
  }) async {
    final account = await _getSignedInAccount();

    var authorization = await account.authorizationClient
        .authorizationForScopes(_scopes);

    authorization ??= await account.authorizationClient.authorizeScopes(
      _scopes,
    );

    final authClient = authorization.authClient(scopes: _scopes);

    try {
      final driveApi = drive.DriveApi(authClient);

      final driveFile =
          drive.File()
            ..name = fileName
            ..mimeType = mimeType;

      final media = drive.Media(
        Stream<List<int>>.value(bytes),
        bytes.length,
        contentType: contentType,
      );

      final created = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
        $fields: 'id,name,webViewLink',
      );

      return GoogleDriveBackupResult(
        id: created.id,
        name: created.name,
        webViewLink: created.webViewLink,
      );
    } finally {
      authClient.close();
    }
  }

  Future<void> signOut() async {
    await _initialize();
    await _googleSignIn.signOut();
  }
}

class GoogleDriveBackupFile {
  final String id;
  final String name;
  final DateTime? modifiedTime;
  final int? sizeBytes;

  const GoogleDriveBackupFile({
    required this.id,
    required this.name,
    required this.modifiedTime,
    required this.sizeBytes,
  });
}
