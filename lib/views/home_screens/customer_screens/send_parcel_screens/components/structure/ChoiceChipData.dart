import 'package:flutter/material.dart';

class ChoiceChipData {
  final String label;
  final bool isSelected;

  ChoiceChipData({
    required this.label,
    required this.isSelected,
  });

  ChoiceChipData copy({
    String? label,
    bool? isSelected,
    Color? textColor,
    Color? selectedColor,
  }) =>
      ChoiceChipData(
        label: label ?? this.label,
        isSelected: isSelected ?? this.isSelected,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChoiceChipData &&
              runtimeType == other.runtimeType &&
              label == other.label &&
              isSelected == other.isSelected;

  @override
  int get hashCode =>
      label.hashCode ^
      isSelected.hashCode;
}