class DftqcOffice {
  final String id;
  final String nameEn;
  final String nameNp;

  DftqcOffice({
    required this.id,
    required this.nameEn,
    required this.nameNp,
  });

  factory DftqcOffice.fromJson(Map<String, dynamic> json) {
    return DftqcOffice(
      id: json['id'],
      nameEn: json['name_en'],
      nameNp: json['name_np'],
    );
  }
}
