import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../common.dart';
import '../../l10n.dart';
import '../data/mpv_meta_data.dart';

class IcyImage extends StatefulWidget {
  const IcyImage({
    super.key,
    required this.mpvMetaData,
    this.height = 40,
    this.width = 40,
    this.borderRadius,
    this.fallBackWidget,
    this.fit,
    this.errorWidget,
    this.onImageFind,
  });

  final MpvMetaData mpvMetaData;

  final double height, width;
  final BorderRadius? borderRadius;
  final Widget? fallBackWidget;
  final Widget? errorWidget;
  final BoxFit? fit;
  final Function(String url)? onImageFind;

  @override
  State<IcyImage> createState() => _IcyImageState();
}

class _IcyImageState extends State<IcyImage> {
  late Future<String?> _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = fetchAlbumArt(widget.mpvMetaData.icyTitle);
  }

  @override
  Widget build(BuildContext context) {
    final bR = widget.borderRadius ?? BorderRadius.circular(4);
    final storedUrl = UrlStore().get(widget.mpvMetaData.icyTitle);

    return Tooltip(
      message: context.l10n.metadata,
      child: ClipRRect(
        borderRadius: bR,
        child: InkWell(
          borderRadius: bR,
          onTap: () => showDialog(
            context: context,
            builder: (context) {
              final image = UrlStore().get(widget.mpvMetaData.icyTitle);
              return SimpleDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: const EdgeInsets.only(bottom: 10),
                children: [
                  if (image != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(kYaruContainerRadius),
                        topRight: Radius.circular(kYaruContainerRadius),
                      ),
                      child: SizedBox(
                        width: 250,
                        child: SafeNetworkImage(
                          errorIcon:
                              widget.errorWidget ?? Icon(Iconz().imageMissing),
                          fit: widget.fit ?? BoxFit.fitHeight,
                          url: image,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: StreamProviderRow(
                      text: widget.mpvMetaData.icyTitle,
                    ),
                  ),
                  ...widget.mpvMetaData
                      .toMap()
                      .entries
                      .map(
                        (e) => ListTile(
                          onTap: e.key == 'icy-url'
                              ? () => launchUrl(Uri.parse(e.value))
                              : null,
                          dense: true,
                          title: Text(e.key),
                          subtitle: Text(e.value),
                        ),
                      )
                      .toList()
                      .reversed,
                ],
              );
            },
          ),
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: storedUrl != null
                ? _buildImage(storedUrl)
                : FutureBuilder(
                    future: _imageUrl,
                    builder: (context, snapshot) {
                      return _buildImage(
                        UrlStore().put(
                          icyTitle: widget.mpvMetaData.icyTitle,
                          imageUrl: snapshot.data,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? url) => SafeNetworkImage(
        errorIcon: widget.errorWidget ?? Icon(Iconz().imageMissing),
        url: url,
        fallBackIcon: widget.fallBackWidget ?? Icon(Iconz().info),
        filterQuality: FilterQuality.medium,
        fit: widget.fit ?? BoxFit.fitHeight,
      );

  Future<String?> fetchAlbumArt(String icyTitle) async {
    return UrlStore().get(icyTitle) ?? await _fetchAlbumArt(icyTitle);
  }

  Future<String?> _fetchAlbumArt(String icyTitle) async {
    String? songName;
    String? artist;
    var split = icyTitle.split(' - ');

    songName = split.lastOrNull;
    artist = split.elementAtOrNull(split.indexOf(split.last) - 1);

    if (artist == null || songName == null) return null;

    final searchUrl = Uri.parse(
      'https://musicbrainz.org/ws/2/recording/?query=recording:"$songName"%20AND%20artist:"$artist"',
    );

    try {
      final searchResponse = await http.get(
        searchUrl,
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'MusicPod (https://github.com/ubuntu-flutter-community/musicpod)',
        },
      );

      if (searchResponse.statusCode == 200) {
        final searchData = jsonDecode(searchResponse.body);
        final recordings = searchData['recordings'] as List;

        final firstRecording = recordings.first;

        final releaseId = firstRecording['releases'][0]['id'];

        if (releaseId == null) return null;

        final albumArtUrl = await _fetchAlbumArtUrlFromReleaseId(releaseId);
        if (albumArtUrl != null) widget.onImageFind?.call(albumArtUrl);
        return albumArtUrl;
      }
    } on Exception catch (_) {
      return null;
    }

    return null;
  }

  Future<String?> _fetchAlbumArtUrlFromReleaseId(String releaseId) async {
    final url = Uri.parse(
      'https://coverartarchive.org/release/$releaseId',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'MusicPod (https://github.com/ubuntu-flutter-community/musicpod)',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final images = data['images'] as List;

        if (images.isNotEmpty) {
          final artwork = images[0];

          return (artwork['image']) as String?;
        }
      }
    } on Exception catch (_) {
      return null;
    }

    return null;
  }
}
