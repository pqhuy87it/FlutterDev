import 'package:flutter/material.dart';
import 'package:project_samples/utils/color.dart';

class ChoiceChipWidget extends FormField<String> {
  ChoiceChipWidget({
    super.key,
    required String title,
    required List<String> choices,
    super.initialValue,
    Color? activeColor,
    Color? inactiveColor,
    super.onSaved,
    super.validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    ValueChanged<String>? onChanged,
  }) : super(
    builder: (FormFieldState<String> state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: choices.map((choice) {
              return ChoiceChip(
                label: Text(choice),
                selectedColor: activeColor ?? AppColor.red,
                backgroundColor: inactiveColor ?? Colors.grey[300],
                labelStyle: TextStyle(
                  color: state.value == choice
                      ? Colors.white
                      : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                selected: state.value == choice,
                onSelected: (bool selected) {
                  state.didChange(selected ? choice : null);
                  if (onChanged != null && selected) {
                    onChanged(choice);
                  }
                },
              );
            }).toList(),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                state.errorText ?? '',
                style: TextStyle(
                  color: Theme.of(state.context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    },
  );
}
