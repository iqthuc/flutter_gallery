import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../media_picker_widget.dart';
import 'header_controller.dart';

// phần header phía trên cùng
class Header extends StatefulWidget {
  const Header({
    Key? key,
    required this.selectedAlbum,
    required this.onBack,
    required this.onDone,
    required this.albumController,
    required this.controller,
    this.mediaCount,
    this.decoration,
    this.submitWidget,
  }) : super(key: key);

  final AssetPathEntity selectedAlbum;
  final VoidCallback onBack;
  final PanelController albumController;
  final ValueChanged<List<AssetEntity>> onDone;
  final HeaderController controller;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;
  final Widget? submitWidget;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> with TickerProviderStateMixin {
  List<AssetEntity> selectedMedia = [];

  late final Animation<double> _arrowAnimation;
  late final AnimationController? _arrowAnimationController;

  @override
  void initState() {
    super.initState();
    // animation của icon ⌃⌄
    _arrowAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _arrowAnimation = Tween<double>(begin: 0, end: 1).animate(_arrowAnimationController!);

    // update lại button tiếp tục khi click chọn/bỏ chọn ảnh
    widget.controller.updateSelection = (selectedMediaList) {
      if (widget.mediaCount == MediaCount.multiple) {
        setState(() => selectedMedia = selectedMediaList);
      } 
      // nếu chỉ cho chọn 1 và muốn chọn xong không cần bấm tiếp tục thì dùng else if này
      // else if (selectedMediaList.length == 1) {
      //   widget.onDone(selectedMediaList);
      // }
    };

    // ???
    widget.controller.closeAlbumDrawer = () {
      widget.albumController.close();
      _arrowAnimationController!.reverse();
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: IconButton(
                      icon: widget.decoration!.cancelIcon ?? const Text('Hủy'),
                      onPressed: () {
                        if (_arrowAnimation.value == 1) {
                          _arrowAnimationController!.reverse();
                        }
                        widget.onBack();
                      }),
                ),
                const Spacer(),
                if (widget.mediaCount == MediaCount.multiple)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position:
                            Tween<Offset>(begin: const Offset(1, 0.0), end: const Offset(0.0, 0.0)).animate(animation),
                        child: child,
                      );
                    },
                    child: (selectedMedia.isNotEmpty)
                        ? widget.submitWidget != null
                            ? InkWell(
                                onTap: selectedMedia.isNotEmpty
                                    ? () {
                                        widget.onDone(selectedMedia);
                                      }
                                    : null,
                                child: widget.submitWidget,
                              )
                            : TextButton(
                                key: const Key('button'),
                                onPressed: selectedMedia.isNotEmpty
                                    ? () {
                                        widget.onDone(selectedMedia);
                                      }
                                    : null,
                                style: widget.decoration!.completeButtonStyle ??
                                    ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                                    ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.decoration!.completeText,
                                      style: widget.decoration!.completeTextStyle ??
                                          const TextStyle(
                                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      ' (${selectedMedia.length})',
                                      style: TextStyle(
                                        color: widget.decoration!.completeTextStyle?.color ?? Colors.white,
                                        fontSize: widget.decoration!.completeTextStyle?.fontSize != null
                                            ? widget.decoration!.completeTextStyle!.fontSize! * 0.77
                                            : 11,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                        : const SizedBox(
                            width: 24,
                          ),
                  ),
                const SizedBox(
                  width: 16,
                ),
              ],
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Center(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0.0, -0.5), end: const Offset(0.0, 0.0))
                                  .animate(animation),
                              child: child,
                            );
                          },
                          child: Text(
                            widget.selectedAlbum.name,
                            style: widget.decoration!.albumTitleStyle,
                            key: ValueKey<String>(widget.selectedAlbum.id),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _arrowAnimation,
                          builder: (context, child) => Transform.rotate(
                            angle: _arrowAnimation.value * pi,
                            child: Icon(
                              Icons.keyboard_arrow_up_outlined,
                              size: (widget.decoration!.albumTitleStyle?.fontSize) != null
                                  ? widget.decoration!.albumTitleStyle!.fontSize! * 1.5
                                  : 20,
                              color: widget.decoration!.albumTitleStyle?.color ?? Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (widget.albumController.isPanelOpen) {
                        widget.albumController.close();
                        _arrowAnimationController!.reverse();
                      }
                      if (widget.albumController.isPanelClosed) {
                        widget.albumController.open();
                        _arrowAnimationController!.forward();
                      }
                    },
                  ),
                )),
          ],
        ),
        Container(width: double.infinity, height: 1, color: const Color(0xFFC2CEDB))
      ],
    );
  }
}
