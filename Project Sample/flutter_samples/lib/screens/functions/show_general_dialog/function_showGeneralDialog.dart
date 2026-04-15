import 'package:flutter/material.dart';
import 'show_elastic_dialog.dart';
import 'send_type_dialog.dart';

class FunctionShowGeneralDialog extends StatelessWidget {
  const FunctionShowGeneralDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Show General Dialog')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showElasticDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return SendTypeDialog(
                  titleDialog: 'General dialog title',
                  listValues: ['Item 1', 'Item 2', 'Item 3'],
                  onPressed: (i, value) {
                    // setState(() {
                    //   _sendType = i;
                    // });
                  },
                );
              },
            );
          },
          child: Text('Press to show'),
        ),
      ),
    );
  }
}
