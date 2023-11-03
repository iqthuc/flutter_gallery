import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../media_picker_widget.dart';
import 'header_controller.dart';
import 'widgets/media_tile.dart';

/// danh sách ảnh/video
class MediaList extends StatefulWidget {
  const MediaList({
    Key? key,
    required this.album,
    required this.headerController,
    this.mediaCount,
    this.decoration,
    this.maxSelected,
    this.scrollController,
    this.onSelectItem,
    this.counterItemWidget,
    this.onExceededLimit,
    this.maxFileSizeInMB,
    this.onExceededExtensionLimit,
    this.allowedExtensions,
    required this.onTapCamera,
  }) : super(key: key);

  final AssetPathEntity album;
  final HeaderController headerController;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;
  final ScrollController? scrollController;
  final Function() onTapCamera;
  final Function(List<AssetEntity>)? onSelectItem;
  final Function(AssetEntity)? onExceededLimit;
  final Function(AssetEntity)? onExceededExtensionLimit;
  final int? maxSelected;
  final int? maxFileSizeInMB;
  final Widget? Function(AssetEntity)? counterItemWidget;
  final List<String>? allowedExtensions;

  @override
  State<MediaList> createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  final List<AssetEntity> _mediaList = [];
  int currentPage = 0;
  int? lastPage;
  bool empty = false;
  AssetPathEntity? album;
  final List<AssetEntity> selectedMedias = [];

  @override
  void initState() {
    super.initState();
    album = widget.album;
    _fetchNewMedia();
  }

  @override
  void didUpdateWidget(covariant MediaList oldWidget) {
    _resetAlbum();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverGrid.builder(
            addAutomaticKeepAlives: false,
            itemCount: _mediaList.length + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              crossAxisCount: widget.decoration!.columnCount,
            ),
            itemBuilder: (BuildContext context, int i) {
              if (i == 0) {
                return InkWell(
                  onTap: widget.onTapCamera,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 36,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            Text(
                              'Chụp ảnh',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }
              final index = i - 1;
              if (index == _mediaList.length - 20 && !empty) {
                _fetchNewMedia();
              }
              return MediaTile(
                allowedExtensions: widget.allowedExtensions,
                totalSelect: selectedMedias.length,
                maxSelect: widget.maxSelected,
                onExceededLimit: widget.onExceededLimit,
                onExceededExtensionLimit: widget.onExceededExtensionLimit,
                media: _mediaList[index],
                counterItemWidget: widget.counterItemWidget,
                onSelected: (isSelected, media) {
                  if (isSelected) {
                    setState(() => selectedMedias.add(media));
                  } else {
                    setState(() => selectedMedias.removeWhere((media) => media.id == media.id));
                  }
                  widget.headerController.updateSelection?.call(selectedMedias);
                  widget.onSelectItem?.call(selectedMedias);
                },
                isSelected: isPreviouslySelected(_mediaList[index]),
                decoration: widget.decoration,
              );
            },
          ),
        ],
      ),
    );
  }

  _resetAlbum() {
    if (album != null) {
      if (album!.id != widget.album.id) {
        _mediaList.clear();
        album = widget.album;
        currentPage = 0;
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    try {
      lastPage = currentPage;
      final result = await PhotoManager.requestPermissionExtend();
      if (result == PermissionState.limited || result == PermissionState.authorized) {
        List<AssetEntity> media = await album!.getAssetListPaged(page: currentPage, size: 80);

        setState(() {
          empty = media.isEmpty;
          _mediaList.addAll(media);
          currentPage++;
        });
      } else {
        PhotoManager.openSetting();
      }
    } catch (e) {
      print(e);
    }
  }

  bool isPreviouslySelected(AssetEntity media) {
    bool isSelected = false;
    for (var asset in selectedMedias) {
      if (asset.id == media.id) isSelected = true;
    }
    return isSelected;
  }
}
