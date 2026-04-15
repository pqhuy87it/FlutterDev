import 'package:flutter/material.dart';

class PersistentBottomSheetPage extends StatefulWidget {
  const PersistentBottomSheetPage({super.key});

  @override
  State<PersistentBottomSheetPage> createState() =>
      _PersistentBottomSheetPageState();
}

class _PersistentBottomSheetPageState extends State<PersistentBottomSheetPage> {
  // Cần một key để truy cập vào ScaffoldState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSheetOpen = false;

  void _togglePersistentSheet() {
    if (_isSheetOpen) {
      Navigator.of(context).pop(); // Đóng sheet nếu nó đang mở
      setState(() {
        _isSheetOpen = false;
      });
    } else {
      // Mở persistent bottom sheet
      _scaffoldKey.currentState?.showBottomSheet(
        (context) => Container(
          height: 150,
          color: Colors.blue[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Đây là Persistent Bottom Sheet'),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Đóng'),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isSheetOpen = false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
      setState(() {
        _isSheetOpen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Gán key cho Scaffold
      appBar: AppBar(title: const Text('Persistent BottomSheet')),
      body: Center(
        child: ElevatedButton(
          onPressed: _togglePersistentSheet,
          child: Text(_isSheetOpen ? 'Đóng Sheet' : 'Mở Persistent Sheet'),
        ),
      ),
    );
  }
}
