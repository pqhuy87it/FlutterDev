import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    this.confirmationMessage,
    required this.title,
    required this.onCancel,
    required this.onSubmit,
  });

  final String? confirmationMessage;
  final String title;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: (confirmationMessage != null)
          ? Text(confirmationMessage!)
          : null,
      actions: <Widget>[
        TextButton(onPressed: onCancel, child: Text("Cancel")),
        TextButton(onPressed: onSubmit, child: Text("OK")),
      ],
    );
  }
}

class AlertDialogDemo1Page extends StatelessWidget {
  const AlertDialogDemo1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Confirm Dialog Demo")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmationDialog(
                  title: 'Confirm',
                  confirmationMessage: 'Are you sure you want to delete this item?',
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                  onSubmit: () {
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          },
          child: const Text('Show Confirm Dialog'),
        ),
      ),
    );
  }
}
