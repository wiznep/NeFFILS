import 'dart:io';

class Shareholder {
  final String? id;
  final String nameEnglish;
  final String nameNepali;
  final String citizenshipNumber;
  final String? citizenshipImagePath;
  final String? citizenshipImageUrl;

  Shareholder({
    this.id,
    required this.nameEnglish,
    required this.nameNepali,
    required this.citizenshipNumber,
    this.citizenshipImagePath,
    this.citizenshipImageUrl,
  });

  Shareholder copyWith({
    String? id,
    String? nameEnglish,
    String? nameNepali,
    String? citizenshipNumber,
    String? citizenshipImagePath,
    String? citizenshipImageUrl,
  }) {
    return Shareholder(
      id: id ?? this.id,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameNepali: nameNepali ?? this.nameNepali,
      citizenshipNumber: citizenshipNumber ?? this.citizenshipNumber,
      citizenshipImagePath: citizenshipImagePath ?? this.citizenshipImagePath,
      citizenshipImageUrl: citizenshipImageUrl ?? this.citizenshipImageUrl,
    );
  }

  factory Shareholder.fromJson(Map<String, dynamic> json) {
    return Shareholder(
      id: json['id']?.toString(),
      nameEnglish: json['name_en'] ?? '',
      nameNepali: json['name_np'] ?? '',
      citizenshipNumber: json['citizenship_number'] ?? '',
      citizenshipImageUrl: json['citizenship_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name_en': nameEnglish,
      'name_np': nameNepali,
      'citizenship_number': citizenshipNumber,
    };
  }

  bool hasValidImage({int maxSizeBytes = 5 * 1024 * 1024}) {
    if (citizenshipImagePath == null) return citizenshipImageUrl != null;
    final file = File(citizenshipImagePath!);
    if (!file.existsSync()) return false;
    return file.lengthSync() <= maxSizeBytes;
  }

  bool isValid() {
    final hasImage = (citizenshipImagePath != null) || (citizenshipImageUrl != null);
    return nameEnglish.trim().isNotEmpty &&
        nameNepali.trim().isNotEmpty &&
        citizenshipNumber.trim().isNotEmpty &&
        hasImage &&
        (citizenshipImagePath == null || hasValidImage());
  }
}
