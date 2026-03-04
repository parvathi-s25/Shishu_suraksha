class AuthData {
  static const List<String> districts = [
    'Adilabad',
    'Bhadradri Kothagudem',
    'Hyderabad',
    'Jagtial',
    'Jangaon',
    'Jayashankar Bhupalpally',
    'Jogulamba Gadwal',
    'Kamareddy',
    'Karimnagar',
    'Khammam',
    'Kumuram Bheem',
    'Mahabubabad',
    'Mahabubnagar',
    'Mancherial',
    'Medak',
    'Medchal-Malkajgiri',
    'Mulugu',
    'Nagarkurnool',
    'Nalgonda',
    'Narayanpet',
    'Nirmal',
    'Nizamabad',
    'Peddapalli',
    'Rajanna Sircilla',
    'Rangareddy',
    'Sangareddy',
    'Siddipet',
    'Suryapet',
    'Vikarabad',
    'Wanaparthy',
    'Warangal',
    'Hanamkonda',
    'Yadadri Bhuvanagiri',
  ];

  static List<String> getVillagesForDistrict(String district) {
    // Mock data for villages
    return [
      '${district} Village 1',
      '${district} Village 2',
      '${district} Village 3',
    ];
  }

  static List<String> getUserIdsForDistrict(String district) {
    // Mock user IDs
    return [
      'AWW_${district.substring(0, 3).toUpperCase()}_001',
      'AWW_${district.substring(0, 3).toUpperCase()}_002',
      'AWW_${district.substring(0, 3).toUpperCase()}_003',
    ];
  }
}
