class Proprietor {
  final String? id;
  final String? nameEn;
  final String? nameNp;
  final String phoneNumber;
  final String email;
  final int wardNumberPer;
  final String? toleNamePer;
  final String houseNumberPer;
  final String nearestLandmarkPer;
  final String gPlusCodePer;
  final int wardNumberTem;
  final String? toleNameTem;
  final String houseNumberTem;
  final String nearestLandmarkTem;
  final String gPlusCodeTem;
  final String grandfatherNameEn;
  final String grandfatherNameNp;
  final String fatherNameEn;
  final String fatherNameNp;
  final String motherNameEn;
  final String motherNameNp;
  final String? proprietorSignature;
  final String industry;
  final String shareholder;
  final String countryPer;
  final String provincePer;
  final String districtPer;
  final String localLevelPer;
  final String countryTem;
  final String provinceTem;
  final String districtTem;
  final String localLevelTem;

  Proprietor({
    this.id,
    this.nameEn,
    this.nameNp,
    required this.phoneNumber,
    required this.email,
    required this.wardNumberPer,
    this.toleNamePer,
    required this.houseNumberPer,
    required this.nearestLandmarkPer,
    required this.gPlusCodePer,
    required this.wardNumberTem,
    this.toleNameTem,
    required this.houseNumberTem,
    required this.nearestLandmarkTem,
    required this.gPlusCodeTem,
    required this.grandfatherNameEn,
    required this.grandfatherNameNp,
    required this.fatherNameEn,
    required this.fatherNameNp,
    required this.motherNameEn,
    required this.motherNameNp,
    this.proprietorSignature,
    required this.industry,
    required this.shareholder,
    required this.countryPer,
    required this.provincePer,
    required this.districtPer,
    required this.localLevelPer,
    required this.countryTem,
    required this.provinceTem,
    required this.districtTem,
    required this.localLevelTem,
  });

  factory Proprietor.fromJson(Map<String, dynamic> json) {
    return Proprietor(
      id: json['id'],
      nameEn: json['name_en'],
      nameNp: json['name_np'],
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      wardNumberPer: json['ward_number_per'] ?? 0,
      toleNamePer: json['tole_name_per'],
      houseNumberPer: json['house_number_per'] ?? '',
      nearestLandmarkPer: json['nearest_landmark_per'] ?? '',
      gPlusCodePer: json['g_plus_code_per'] ?? '',
      wardNumberTem: json['ward_number_tem'] ?? 0,
      toleNameTem: json['tole_name_tem'],
      houseNumberTem: json['house_number_tem'] ?? '',
      nearestLandmarkTem: json['nearest_landmark_tem'] ?? '',
      gPlusCodeTem: json['g_plus_code_tem'] ?? '',
      grandfatherNameEn: json['grandfather_name_en'] ?? '',
      grandfatherNameNp: json['grandfather_name_np'] ?? '',
      fatherNameEn: json['father_name_en'] ?? '',
      fatherNameNp: json['father_name_np'] ?? '',
      motherNameEn: json['mother_name_en'] ?? '',
      motherNameNp: json['mother_name_np'] ?? '',
      proprietorSignature: json['proprietor_signature'],
      industry: json['industry'] ?? '',
      shareholder: json['shareholder'] ?? '',
      countryPer: json['country_per'] ?? '',
      provincePer: json['province_per'] ?? '',
      districtPer: json['district_per'] ?? '',
      localLevelPer: json['local_level_per'] ?? '',
      countryTem: json['country_tem'] ?? '',
      provinceTem: json['province_tem'] ?? '',
      districtTem: json['district_tem'] ?? '',
      localLevelTem: json['local_level_tem'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (nameEn != null) 'name_en': nameEn,
      if (nameNp != null) 'name_np': nameNp,
      'phone_number': phoneNumber,
      'email': email,
      'ward_number_per': wardNumberPer,
      if (toleNamePer != null) 'tole_name_per': toleNamePer,
      'house_number_per': houseNumberPer,
      'nearest_landmark_per': nearestLandmarkPer,
      'g_plus_code_per': gPlusCodePer,
      'ward_number_tem': wardNumberTem,
      if (toleNameTem != null) 'tole_name_tem': toleNameTem,
      'house_number_tem': houseNumberTem,
      'nearest_landmark_tem': nearestLandmarkTem,
      'g_plus_code_tem': gPlusCodeTem,
      'grandfather_name_en': grandfatherNameEn,
      'grandfather_name_np': grandfatherNameNp,
      'father_name_en': fatherNameEn,
      'father_name_np': fatherNameNp,
      'mother_name_en': motherNameEn,
      'mother_name_np': motherNameNp,
      if (proprietorSignature != null) 'proprietor_signature': proprietorSignature,
      'industry': industry,
      'shareholder': shareholder,
      'country_per': countryPer,
      'province_per': provincePer,
      'district_per': districtPer,
      'local_level_per': localLevelPer,
      'country_tem': countryTem,
      'province_tem': provinceTem,
      'district_tem': districtTem,
      'local_level_tem': localLevelTem,
    };
  }
}