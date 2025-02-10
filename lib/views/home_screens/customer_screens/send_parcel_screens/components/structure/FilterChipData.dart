class FilterChipData {
  late String label;
  late bool isSelected;

  FilterChipData({
    required this.label,
    required this.isSelected,
  });

  FilterChipData copy({
    String? label,
    bool? isSelected,
  }) =>
      FilterChipData(
        label: label ?? this.label,
        isSelected: isSelected ?? this.isSelected,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FilterChipData &&
              runtimeType == other.runtimeType &&
              label == other.label &&
              isSelected == other.isSelected;

  @override
  int get hashCode => label.hashCode ^ isSelected.hashCode;
}