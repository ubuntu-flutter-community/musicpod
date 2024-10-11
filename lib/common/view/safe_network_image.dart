import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file/file.dart' hide FileSystem;
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:xdg_directories/xdg_directories.dart';

import '../../extensions/build_context_x.dart';
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
            Iconz.musicNote,
            size: height != null ? height! * 0.7 : null,
          ),
    );

    if (url == null) return fallBack;

    final errorWidget = Center(
      child: errorIcon ??
          Icon(
            Iconz.imageMissing,
            size: height != null ? height! * 0.7 : null,
            color: context.theme.hintColor,
          ),
    );

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
        errorWidget: (context, url, _) => errorWidget,
      );
    } on Exception {
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
