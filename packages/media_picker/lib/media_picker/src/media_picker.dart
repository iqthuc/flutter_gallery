part of media_picker_widget;

class MediaPicker extends StatefulWidget {
  const MediaPicker({
    Key? key,
    required this.onPick,
    required this.onCancel,
    this.mediaCount = MediaCount.multiple,
    this.mediaType = MediaType.all,
    this.decoration,
    this.scrollController,
    this.maxSelect,
    this.submitWidget,
    this.counterItemWidget,
    required this.captureCamera,
    this.header,
    this.onSelectAlbum,
    this.onSelectItem,
    this.onExceededLimit,
    this.maxFileSizeInMB,
    this.onExceededExtensionLimit,
    this.allowedExtensions,
  }) : super(key: key);

  final ValueChanged<List<AssetEntity>> onPick;
  final ValueChanged<Media> captureCamera;
  final VoidCallback onCancel;
  final MediaCount mediaCount;
  final MediaType mediaType;
  final PickerDecoration? decoration;
  final ScrollController? scrollController;
  final int? maxSelect;
  final int? maxFileSizeInMB;

  final Widget? submitWidget;
  final Widget? header;
  final Widget? Function(AssetEntity)? counterItemWidget;
  final Function(AssetPathEntity?)? onSelectAlbum;
  final Function(List<AssetEntity>)? onSelectItem;

  ///Total selected media limit
  final Function(AssetEntity)? onExceededLimit;
  final Function(AssetEntity)? onExceededExtensionLimit;
  final List<String>? allowedExtensions;

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  late final PickerDecoration? decoration;

  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity>? _albums;

  final PanelController albumController = PanelController();
  final HeaderController headerController = HeaderController();
  bool _showWarning = false;

  @override
  void initState() {
    super.initState();
    decoration = widget.decoration ?? PickerDecoration();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _albums == null
          ? LoadingWidget(
              decoration: decoration!,
            )
          : _albums!.isEmpty
              ? const NoMedia()
              : Column(
                  children: [
                    if (decoration!.actionBarPosition == ActionBarPosition.top) _buildHeader(),
                    _buildWarning(),
                    Expanded(
                        child: Stack(
                      children: [
                        Positioned.fill(
                          child: MediaList(
                            allowedExtensions: widget.allowedExtensions,
                            maxSelected: widget.maxSelect,
                            album: selectedAlbum!,
                            headerController: headerController,
                            mediaCount: widget.mediaCount,
                            decoration: decoration,
                            scrollController: widget.scrollController,
                            counterItemWidget: widget.counterItemWidget,
                            onTapCamera: () {
                              _openCamera(onCapture: widget.captureCamera);
                            },
                            onSelectItem: widget.onSelectItem,
                            maxFileSizeInMB: widget.maxFileSizeInMB,
                            onExceededLimit: widget.onExceededLimit,
                            onExceededExtensionLimit: widget.onExceededExtensionLimit,
                          ),
                        ),
                        AlbumSelector(
                          panelController: albumController,
                          albums: _albums!,
                          decoration: decoration!,
                          onSelect: (album) {
                            headerController.closeAlbumDrawer!();
                            setState(() => selectedAlbum = album);
                            widget.onSelectAlbum?.call(selectedAlbum);
                            widget.onSelectAlbum?.call(selectedAlbum);
                          },
                        ),
                      ],
                    )),
                    if (decoration!.actionBarPosition == ActionBarPosition.bottom) _buildHeader(),
                  ],
                ),
    );
  }

  _openCamera({required ValueChanged<Media> onCapture}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera, maxHeight: 1024, maxWidth: 896);
    if (pickedFile != null) {
      final byte = await pickedFile.readAsBytes();
      Media converted = Media(
        id: UniqueKey().toString(),
        thumbnail: byte,
        creationTime: DateTime.now(),
        path: pickedFile.path,
        mediaType: 'image',
        mediaByte: await pickedFile.readAsBytes(),
        title: pickedFile.path,
      );
      onCapture(converted);
    }
  }

  Widget _buildWarning() {
    return Visibility(
      visible: _showWarning,
      child: Container(
          color: const Color(0xFFE5E9F2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: RichText(
            text: TextSpan(
                text: 'Bạn vừa cấp quyền cho Meey Team chọn một vài ảnh nhất định.',
                style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Color(0xFF1C2433)),
                children: [
                  TextSpan(
                    text: 'Thay đổi quyền tại đây',
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, color: Color(0xFF2174E2)),
                    recognizer: TapGestureRecognizer()..onTap = () => PhotoManager.openSetting(),
                  )
                ]),
          )),
    );
  }

  Widget _buildHeader() {
    return widget.header ??
        Header(
          onBack: handleBackPress,
          onDone: widget.onPick,
          albumController: albumController,
          selectedAlbum: selectedAlbum!,
          controller: headerController,
          mediaCount: widget.mediaCount,
          decoration: decoration,
          submitWidget: widget.submitWidget,
        );
  }

  _fetchAlbums() async {
    PhotoManager.clearFileCache();
    RequestType type = RequestType.common;
    if (widget.mediaType == MediaType.all) {
      type = RequestType.common;
    } else if (widget.mediaType == MediaType.video) {
      type = RequestType.video;
    } else if (widget.mediaType == MediaType.image) {
      type = RequestType.image;
    }
    var result = await PhotoManager.requestPermissionExtend();
    if (result == PermissionState.limited) {
      setState(() {
        _showWarning = true;
      });
    }
    if (result == PermissionState.limited || result == PermissionState.authorized) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: type);
      setState(() {
        _albums = albums;
        if (albums.isEmpty) return;
        selectedAlbum = _albums![0];
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  void handleBackPress() {
    if (albumController.isPanelOpen) {
      albumController.close();
    } else {
      widget.onCancel();
    }
  }
}
