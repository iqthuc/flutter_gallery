import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({Key? key}) : super(key: key);

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  CameraController? controller;

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  Future _initCamera() async {
    final cameras = await availableCameras();
    if (controller != null) {
      await controller!.dispose();
    }
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (controller == null || !controller!.value.isInitialized) {
      return const SizedBox();
    }
    return AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: CameraPreview(controller!));
  }

  @override
  bool get wantKeepAlive => true;
}
