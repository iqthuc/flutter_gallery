import 'package:flutter/cupertino.dart';

import '../../media_picker_widget.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key, required this.decoration}) : super(key: key);

  final PickerDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (decoration.loadingWidget != null)
          ? decoration.loadingWidget
          : const CupertinoActivityIndicator(),
    );
  }
}
