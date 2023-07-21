import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class HeaderController {
  HeaderController();

  ValueChanged<List<AssetEntity>>? updateSelection;
  VoidCallback? closeAlbumDrawer;
}
