import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class FullscreenDialogModel extends BaseViewModel {
  bool _isLandscape = false;

  bool get isLandscape => _isLandscape;

  void setLandscape() {
    _isLandscape = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    notifyListeners();
  }

  void setPortrait() {
    _isLandscape = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    notifyListeners();
  }

  @override
  void dispose() {
    // Reset orientation when dialog is closed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
