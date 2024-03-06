import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// ignore: implementation_imports
import 'package:flutter_cache_manager/src/storage/file_system/file_system.dart';
import 'package:path/path.dart' as p;
import 'package:xdg_directories/xdg_directories.dart';

import '../../build_context_x.dart';
import 'icons.dart';

class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.filterQuality = FilterQuality.medium,
    this.fit = BoxFit.fitWidth,
    this.fallBackIcon,
    this.errorIcon,
    this.height,
    this.width,
  });

  final String? url;
  final FilterQuality filterQuality;
  final BoxFit fit;
  final Widget? fallBackIcon;
  final Widget? errorIcon;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final fallBack = Center(
      child: fallBackIcon ??
          Icon(
            Iconz().musicNote,
            size: 70,
          ),
    );

    final errorWidget = Center(
      child: errorIcon ??
          Icon(
            Iconz().imageMissing,
            size: 70,
            color: context.t.hintColor,
          ),
    );

    if (url == null) return fallBack;

    if (url?.endsWith('.svg') == true || url?.endsWith('.ico') == true) {
      return Image.network(
        url!,
        fit: fit,
        height: height,
        width: width,
        filterQuality: filterQuality,
        errorBuilder: (a, b, c) => errorWidget,
        frameBuilder: (a, child, frame, d) => frame == null ? fallBack : child,
      );
    }

    try {
      return CachedNetworkImage(
        cacheManager: Platform.isLinux ? XdgCacheManager() : null,
        imageUrl: url!,
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          filterQuality: filterQuality,
          fit: fit,
          height: height,
          width: width,
        ),
        errorWidget: (context, url, error) => errorWidget,
      );
    } on Exception catch (_) {
      return fallBack;
    }
  }
}

// Code by @d-loose
class _XdgFileSystem implements FileSystem {
  final Future<Directory> _fileDir;
  final String _cacheKey;

  _XdgFileSystem(this._cacheKey) : _fileDir = createDirectory(_cacheKey);

  static Future<Directory> createDirectory(String key) async {
    final baseDir = cacheHome;
    final path = p.join(baseDir.path, key, 'images');

    const fs = LocalFileSystem();
    final directory = fs.directory(path);
    await directory.create(recursive: true);
    return directory;
  }

  @override
  Future<File> createFile(String name) async {
    final directory = await _fileDir;
    if (!(await directory.exists())) {
      await createDirectory(_cacheKey);
    }
    return directory.childFile(name);
  }
}

class XdgCacheManager extends CacheManager with ImageCacheManager {
  static final key = p.basename(Platform.resolvedExecutable);

  static final XdgCacheManager _instance = XdgCacheManager._();

  factory XdgCacheManager() {
    return _instance;
  }

  XdgCacheManager._() : super(Config(key, fileSystem: _XdgFileSystem(key)));
}

class UrlStore {
  static final UrlStore _instance = UrlStore._internal();
  factory UrlStore() => _instance;
  UrlStore._internal();

  final _value = <String, String>{};

  String put({required String icyTitle, required String imageUrl}) {
    return _value.putIfAbsent(icyTitle, () => imageUrl);
  }

  String? get(String? icyTitle) => icyTitle == null ? null : _value[icyTitle];
}
