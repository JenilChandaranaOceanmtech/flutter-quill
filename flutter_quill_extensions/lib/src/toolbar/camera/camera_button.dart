import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/flutter_quill_internal.dart';

import 'package:image_picker/image_picker.dart';
import 'camera_types.dart';
import 'models/camera_configurations.dart';
import 'select_camera_action.dart';

class QuillToolbarCameraButton extends StatelessWidget {
  const QuillToolbarCameraButton({
    required this.controller,
    this.options = const QuillToolbarCameraButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarCameraButtonOptions options;

  double _iconSize(BuildContext context) {
    final iconSize = options.iconSize;
    return iconSize ?? kDefaultIconSize;
  }

  double _iconButtonFactor(BuildContext context) {
    final iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? kDefaultIconButtonFactor;
  }

  VoidCallback? _afterButtonPressed(BuildContext context) {
    return options.afterButtonPressed;
  }

  QuillIconTheme? _iconTheme(BuildContext context) {
    return options.iconTheme;
  }

  IconData _iconData(BuildContext context) {
    return options.iconData ?? Icons.photo_camera;
  }

  String _tooltip(BuildContext context) {
    return options.tooltip ?? context.loc.camera;
  }

  void _sharedOnPressed(BuildContext context) {
    _onPressedHandler(
      context,
      controller,
    );
    _afterButtonPressed(context);
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = _iconTheme(context);
    final tooltip = _tooltip(context);
    final iconSize = _iconSize(context);
    final iconData = _iconData(context);
    final iconButtonFactor = _iconButtonFactor(context);

    final childBuilder = options.childBuilder;

    if (childBuilder != null) {
      childBuilder(
        QuillToolbarCameraButtonOptions(
          afterButtonPressed: _afterButtonPressed(context),
          iconData: options.iconData,
          iconSize: options.iconSize,
          iconButtonFactor: iconButtonFactor,
          iconTheme: options.iconTheme,
          tooltip: options.tooltip,
          cameraConfigurations: options.cameraConfigurations,
        ),
        QuillToolbarCameraButtonExtraOptions(
          controller: controller,
          context: context,
          onPressed: () => _sharedOnPressed(context),
        ),
      );
    }

    return QuillToolbarIconButton(
      icon: Icon(
        iconData,
        size: iconButtonFactor * iconSize,
      ),
      tooltip: tooltip,
      isSelected: false,
      // isDesktop(supportWeb: false) ? null :
      onPressed: () => _sharedOnPressed(context),
      iconTheme: iconTheme,
    );
  }

  Future<CameraAction?> _getCameraAction(BuildContext context) async {
    final customCallback =
        options.cameraConfigurations.onRequestCameraActionCallback;
    if (customCallback != null) {
      return await customCallback(context);
    }
    final cameraAction = await showSelectCameraActionDialog(
      context: context,
    );

    return cameraAction;
  }

  Future<void> _onPressedHandler(
    BuildContext context,
    QuillController controller,
  ) async {
    final cameraAction = await _getCameraAction(context);

    if (cameraAction == null) {
      return;
    }

    switch (cameraAction) {
      case CameraAction.video:
        final videoFile =
            await ImagePicker().pickVideo(source: ImageSource.camera);
        if (videoFile == null) {
          return;
        }
        await options.cameraConfigurations.onVideoInsertCallback(
          videoFile.path,
          controller,
        );
        await options.cameraConfigurations.onVideoInsertedCallback
            ?.call(videoFile.path);
      case CameraAction.image:
        final imageFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (imageFile == null) {
          return;
        }
        await options.cameraConfigurations.onImageInsertCallback(
          imageFile.path,
          controller,
        );
        await options.cameraConfigurations.onImageInsertedCallback
            ?.call(imageFile.path);
    }
  }
}
