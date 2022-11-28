import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart' hide MenuItem;
import 'package:flutter/material.dart' hide MenuItem;
import 'package:preference_list/preference_list.dart';
import 'package:tray_manager/tray_manager.dart';

const _kIconTypeDefault = 'default';
const _kIconTypeOriginal = 'original';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener {
  String _iconType = _kIconTypeOriginal;
  Menu? _menu;

  @override
  void initState() {
    trayManager.addListener(this);
    _handleSetIcon(_kIconTypeOriginal);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  void _handleSetIcon(String iconType) async {
    _iconType = iconType;
    String iconPath =
        Platform.isWindows ? 'images/tray_icon.ico' : 'images/tray_icon.png';

    if (_iconType == 'original') {
      iconPath = Platform.isWindows
          ? 'images/tray_icon_original.ico'
          : 'images/tray_icon_original.png';
    }

    await trayManager.setIcon(iconPath);
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        Text("Hello World!"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: _buildBody(context),
    );
  }

  @override
  void onTrayIconMouseDown() {
    print('onTrayIconMouseDown');
    trayManager.popUpContextMenu();
  }

  // @override
  // void onTrayIconMouseUp() {
  //   print('onTrayIconMouseUp');
  // }

  // @override
  // void onTrayIconRightMouseDown() {
  //   print('onTrayIconRightMouseDown');
  //   // trayManager.popUpContextMenu();
  // }

  // @override
  // void onTrayIconRightMouseUp() {
  //   print('onTrayIconRightMouseUp');
  // }

  // @override
  // void onTrayMenuItemClick(MenuItem menuItem) {
  //   print(menuItem.toJson());
  //   BotToast.showText(
  //     text: '${menuItem.toJson()}',
  //   );
  // }
}
