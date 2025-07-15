class DropdownOption {
  final String id;
  final String name;

  DropdownOption({required this.id, required this.name});

  factory DropdownOption.fromJson(Map<String, dynamic> json) {
    return DropdownOption(
      id: json['id'],
      name: json['name_en'] ?? json['nep_label'] ?? json['name_np'] ?? '',
    );
  }
}
