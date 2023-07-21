import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../media_picker_widget.dart';

class MediaTile extends StatefulWidget {
  const MediaTile({
    Key? key,
    required this.media,
    required this.onSelected,
    this.isSelected = false,
    this.counterItemWidget,
    this.decoration,
    this.maxSelect,
    this.totalSelect,
    this.onExceededLimit,
    this.onExceededExtensionLimit,
    this.allowedExtensions,
  }) : super(key: key);

  final AssetEntity media;
  final Function(bool, AssetEntity) onSelected;

  ///Total selected media limit
  final Function(AssetEntity)? onExceededLimit;
  final Function(AssetEntity)? onExceededExtensionLimit;
  final bool isSelected;
  final PickerDecoration? decoration;
  final int? maxSelect;
  final int? totalSelect;
  final List<String>? allowedExtensions;
  final Widget? Function(AssetEntity)? counterItemWidget;

  @override
  State<MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool? selected;
  String? path;
  Uint8List? file;
  final Duration _duration = const Duration(milliseconds: 100);
  bool isLoadingOnSelect = false;
  @override
  void initState() {
    selected = widget.isSelected;
    _initFile();
    super.initState();
  }

  Future<void> _initFile() async {
    try {
      if (widget.media.type == AssetType.video) {
        final res = await widget.media.thumbnailDataWithSize(const ThumbnailSize(300, 300));
        if (mounted) {
          setState(() {
            file = res;
          });
        }
        return;
      }
      final res = await widget.media.file;
      if (mounted) {
        setState(() {
          path = res!.path;
        });
        print('====path $path');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: path == null && file == null
          ? Container(
              width: 150,
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFFF9FAFC),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                    child: InkWell(
                  onTap: () async {
                    setState(() {
                      isLoadingOnSelect = true;
                    });
                    //File counter limit
                    if ((widget.totalSelect ?? 0) >= (widget.maxSelect ?? 1000000) && !selected!) {
                      return widget.onExceededLimit?.call(widget.media);
                    }

                    ///File extension limit
                    if (widget.allowedExtensions != null &&
                        !widget.allowedExtensions!.contains(path!.split('.').last.toLowerCase())) {
                      return widget.onExceededExtensionLimit?.call(widget.media);
                    }
                    setState(() => selected = !selected!);
                    widget.onSelected(selected!, widget.media);
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: widget.media.type == AssetType.video
                              ? Image.memory(
                                  file!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,
                                  frameBuilder:
                                      (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded) return child;
                                    if (frame != null) return child;
                                    return const CupertinoActivityIndicator();
                                  },
                                )
                              : Image.file(
                                  File(path!),
                                  fit: BoxFit.cover,
                                  cacheWidth: 300,
                                  frameBuilder:
                                      (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded) return child;
                                    if (frame != null) return child;
                                    return const CupertinoActivityIndicator();
                                  },
                                )),
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: selected! ? 1 : 0,
                          curve: Curves.easeOut,
                          duration: _duration,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: widget.decoration!.blurStrength, sigmaY: widget.decoration!.blurStrength),
                              child: Container(
                                color: Colors.black26,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.media.type == AssetType.video)
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 5, bottom: 5),
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
                if (widget.counterItemWidget != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedOpacity(
                        curve: Curves.easeOut,
                        duration: _duration,
                        opacity: selected! ? 1 : 0,
                        child: widget.counterItemWidget?.call(widget.media),
                      ),
                    ),
                  ),
              ],
            ),
    );
    // else {
    //   convertToMedia(media: widget.media)
    //       .then((_media) => setState(() => media = _media));
    //   return LoadingWidget(
    //     decoration: widget.decoration!,
    //   );
    // }
  }

  double getMBSize(int? sizeInByte) {
    if (sizeInByte == null) return 0;
    if (Platform.isAndroid) {
      return (sizeInByte / 1024) / 1024;
    } else if (Platform.isIOS) {
      return (sizeInByte / 1000) / 1000;
    } else {
      return (sizeInByte / 1000) / 1000;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
//
// Future<Media> convertToMedia({required AssetEntity media}) async {
//   Media convertedMedia = Media();
//   convertedMedia.mediaByte = (await media.thumbDataWithSize(1024, 1024));
//   convertedMedia.id = media.id;
//   convertedMedia.size = media.size;
//   convertedMedia.title = media.title;
//   convertedMedia.creationTime = media.createDateTime;
//   MediaType mediaType = MediaType.all;
//   if (media.type == AssetType.video) mediaType = MediaType.video;
//   if (media.type == AssetType.image) mediaType = MediaType.image;
//   convertedMedia.mediaType = mediaType;
//
//   return convertedMedia;
// }
