import 'dart:io';

import 'package:az_url_lister/models/url.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:ionicons/ionicons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:azstore/azstore.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

const _kIconTypeDefault = 'default';
const _kIconTypeOriginal = 'original';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TrayListener, WindowListener {
  String _iconType = _kIconTypeOriginal;
  DateFormat format = DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY);
  AzureStorage storage = AzureStorage.parse(
      'DefaultEndpointsProtocol=https;AccountName=urldatavh4wkstg;AccountKey=NE1Rzu3U1VcwlGlTB3LMlos4O9piDu+TnGSqMBbwK6wXHARuvMhJzsHYV7y3Hpnp2sPzaoWo379L+AStWltLxQ==');
  bool _windowShowing = false;
  List<dynamic> _links = [];

  Future<void> _launchUrl(String url) async {
    if (url.isNotEmpty && url != 'null') {
      var uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw 'Could not launch $url';
      }
    }
  }

  Future<void> getLinks() async {
    List<dynamic> links = await storage.filterTableRows(
        tableName: 'UrlsDetails',
        filter: 'IsArchived%20eq%20false',
        top: 1000000000);

    // List<AzUrl> result = links.map((e) => AzUrl.fromJson(e)).toList();
    setState(() {
      _links = links;
    });
  }

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    _handleSetIcon(_kIconTypeOriginal);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
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
    return GroupedListView<dynamic, String>(
        elements: _links,
        groupBy: (element) =>
            format.format(DateTime.parse(element['Timestamp'])),
        useStickyGroupSeparators: true,
        groupSeparatorBuilder: (String value) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
        itemBuilder: (c, element) {
          return Card(
            elevation: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: SizedBox(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                leading: Text(element['Clicks'].toString()),
                title: Text(element['Title']),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  _launchUrl(element['Url'].toString());
                },
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Container(
            // color: Colors.red,
            margin: const EdgeInsets.only(top: 10),
            child: Row(children: const [
              SizedBox(
                width: 10,
              ),
              Text(
                "Links",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 33),
              ),
              SizedBox(
                width: 5,
              ),
            ])),
        backgroundColor: Colors.white,
        actions: [
          // IconButton(
          //     onPressed: () {},
          //     icon: const Icon(
          //       Ionicons.notifications_outline,
          //       size: 30,
          //       color: Colors.black87,
          //     )),
          const SizedBox(
            width: 2,
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Ionicons.settings_outline,
                size: 24,
                color: Colors.black87,
              )),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  @override
  void onTrayIconMouseDown() {
    toggleWindow();
    // trayManager.popUpContextMenu();
  }

  void toggleWindow() async {
    if (!_windowShowing) {
      WindowOptions windowOptions = WindowOptions(
        size: Size(350, 650),
        // center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: true,
        titleBarStyle: TitleBarStyle.hidden,
      );
      await windowManager.show();
      var cursorPos = await screenRetriever.getCursorScreenPoint();
      print(cursorPos);
      await windowManager.setPosition(
          Offset(cursorPos.dx - 100, cursorPos.dy - 660),
          animate: true);
      setState(() {
        _windowShowing = true;
      });
    } else {
      await windowManager.hide();
      setState(() {
        _windowShowing = false;
      });
    }
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

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() {
    // do something
  }

  @override
  void onWindowFocus() {
    getLinks();
  }

  @override
  void onWindowBlur() {
    if (_windowShowing) {
      windowManager.hide();
      setState(() {
        _windowShowing = false;
      });
    }
  }

  @override
  void onWindowMaximize() {
    // do something
  }

  @override
  void onWindowUnmaximize() {
    // do something
  }

  @override
  void onWindowMinimize() {
    // do something
  }

  @override
  void onWindowRestore() {
    // do something
  }

  @override
  void onWindowResize() {
    // do something
  }

  @override
  void onWindowMove() {
    // do something
  }

  @override
  void onWindowEnterFullScreen() {
    // do something
  }

  @override
  void onWindowLeaveFullScreen() {
    // do something
  }
}
