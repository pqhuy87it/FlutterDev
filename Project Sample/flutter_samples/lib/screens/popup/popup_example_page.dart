import 'package:flutter/material.dart';
import 'package:project_samples/screens/popup/add_menu.dart';
import 'package:project_samples/utils/load_image.dart';
import 'popup_window.dart';

class PopupExamplePage extends StatefulWidget {
  static String routeName = 'basics/popup_example';

  const PopupExamplePage({super.key});

  @override
  State<PopupExamplePage> createState() => _PopupExamplePageState();
}

class _PopupExamplePageState extends State<PopupExamplePage> {
  final GlobalKey _addKey = GlobalKey();

  void _showAddMenu() {
    final RenderBox button = _addKey.currentContext!.findRenderObject()! as RenderBox;

    showPopupWindow<void>(
      context: context,
      isShowBg: true,
      offset: Offset(button.size.width - 8.0, -12.0),
      anchor: button,
      child: const AddMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popup Example'),
        actions: [
          IconButton(
            tooltip: '添加商品',
            key: _addKey,
            onPressed: _showAddMenu,
            icon: LoadAssetImage(
              'add',
              key: const Key('add'),
              width: 24.0,
              height: 24.0,
              color: Colors.black12,
            ),
          )
        ],
      ),
      body: Center(
        child: Text('Popup content'),
      ),
    );
  }
}
