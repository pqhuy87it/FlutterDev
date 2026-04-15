import 'package:flutter/material.dart';
import 'package:project_samples/utils/gaps.dart';
import 'package:project_samples/utils/load_image.dart';
import 'base_dialog.dart';

class SendTypeDialog extends StatefulWidget {
  const SendTypeDialog({
    super.key,
    required this.onPressed,
    required this.titleDialog,
    required this.listValues,
  });

  final void Function(int, String) onPressed;
  final String titleDialog;
  final List<String> listValues;

  @override
  State<SendTypeDialog> createState() => _SendTypeDialogState();
}

class _SendTypeDialogState extends State<SendTypeDialog> {
  int _value = 0;

  Widget _buildItem(int index) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        child: SizedBox(
          height: 48.0,
          child: Row(
            children: <Widget>[
              Gaps.hGap16,
              Expanded(
                child: Text(
                  widget.listValues[index],
                  style: _value == index
                      ? TextStyle(
                          fontSize: Dimens.font_sp14,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
              ),
              Visibility(
                visible: _value == index,
                child: const LoadAssetImage(
                  'ic_check',
                  width: 16.0,
                  height: 16.0,
                ),
              ),
              Gaps.hGap16,
            ],
          ),
        ),
        onTap: () {
          if (mounted) {
            setState(() {
              _value = index;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: widget.titleDialog,
      leftBtnTitle: 'Cancel',
      rightBtnTitle: 'OK',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.listValues.length, (i) => _buildItem(i)),
      ),
      onPressed: () {
        Navigator.pop(context);
        widget.onPressed(_value, widget.listValues[_value]);
      },
    );
  }
}
