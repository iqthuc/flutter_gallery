import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../media_picker_widget.dart';
import 'widgets/loading_widget.dart';

///[AlbumSelector] là list albums(Camera/Screenshorts/Download,...)

class AlbumSelector extends StatefulWidget {
  const AlbumSelector(
      {Key? key, required this.onSelect, required this.albums, required this.panelController, required this.decoration})
      : super(key: key);

  final ValueChanged<AssetPathEntity> onSelect;
  final List<AssetPathEntity> albums;
  final PanelController panelController;
  final PickerDecoration decoration;

  @override
  State<AlbumSelector> createState() => _AlbumSelectorState();
}

class _AlbumSelectorState extends State<AlbumSelector> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return SlidingUpPanel(
        controller: widget.panelController,
        minHeight: 0,
        color: Theme.of(context).canvasColor,
        boxShadow: const [],
        maxHeight: constrains.maxHeight,
        panelBuilder: (sc) {
          return ListView(
            controller: sc,
            children: List<Widget>.generate(
              widget.albums.length,
              (index) => AlbumTile(
                album: widget.albums[index],
                onSelect: () => widget.onSelect(widget.albums[index]),
                decoration: widget.decoration,
              ),
            ),
          );
        },
      );
    });
  }
}

class AlbumTile extends StatefulWidget {
  const AlbumTile({Key? key, required this.album, required this.onSelect, required this.decoration}) : super(key: key);

  final AssetPathEntity album;
  final VoidCallback onSelect;
  final PickerDecoration decoration;

  @override
  State<AlbumTile> createState() => _AlbumTileState();
}

class _AlbumTileState extends State<AlbumTile> {
  Uint8List? albumThumb;
  bool hasError = false;
  int assetCount = 0;
  @override
  void initState() {
    super.initState();
    _getAssetCount();
    _getAlbumThumb(widget.album);
  }

  _getAssetCount() async {
    assetCount = await widget.album.assetCountAsync;
  }

  _getAlbumThumb(AssetPathEntity album) async {
    List<AssetEntity> media = await album.getAssetListPaged(page: 0, size: 1);
    Uint8List? thumbByte = await media[0].thumbnailDataWithSize(const ThumbnailSize(250, 250));
    if (thumbByte != null) {
      setState(() => albumThumb = thumbByte);
    } else {
      setState(() => hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onSelect,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: 80,
                height: 80,
                child: !hasError
                    ? albumThumb != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              albumThumb!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : LoadingWidget(
                            decoration: widget.decoration,
                          )
                    : Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                      ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.album.name,
                style: widget.decoration.albumTextStyle ?? const TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                '$assetCount',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
