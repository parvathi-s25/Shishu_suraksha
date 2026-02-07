class AuthData {
  // All 22 districts in exact order
  static final List<String> districts = [
    'Anantapuramu',
    'Chittoor',
    'East Godavari',
    'Eluru',
    'Guntur',
    'Kakinada',
    'Konaseema',
    'Krishna',
    'Kurnool',
    'Nandyal',
    'NTR',
    'Palnadu',
    'Parvathipuram Manyam',
    'Prakasam',
    'S.P.S. Nellore',
    'Sri Sathya Sai',
    'Srikakulam',
    'Tirupati',
    'Visakhapatnam',
    'Vizianagaram',
    'West Godavari',
    'YSR Kadapa',
  ];

  // Complete district-village mapping (exact as specified)
  static final Map<String, List<String>> districtVillages = {
    'Anantapuramu': [
      'Kalyandurg',
      'Rayadurg',
      'Gooty',
      'Pamidi',
      'Singanamala',
      'Penukonda',
      'Tadipatri (rural)',
    ],
    'Chittoor': [
      'Pakala',
      'Nagari',
      'Puttur',
      'Palasamudram',
      'Somala',
      'Kuppam (rural)',
    ],
    'East Godavari': [
      'Rajanagaram',
      'Peddapuram (rural)',
      'Rangampeta',
      'Gandepalli',
      'Samalkot (rural)',
    ],
    'Eluru': [
      'Denduluru',
      'Pedavegi',
      'Bhimadole',
      'Unguturu',
      'Kaikaluru (rural)',
    ],
    'Guntur': [
      'Chebrolu',
      'Tadikonda',
      'Medikonduru',
      'Pedakakani',
      'Vatticherukuru',
    ],
    'Kakinada': [
      'Pithapuram (rural)',
      'Prathipadu',
      'Gollaprolu',
      'Kirlampudi',
      'Jaggampeta (rural)',
    ],
    'Konaseema': [
      'Amalapuram (rural)',
      'Muramalla',
      'Mummidivaram',
      'Ravulapalem',
      'Ainavilli',
    ],
    'Krishna': [
      'Pamarru',
      'Movva',
      'Bantumilli',
      'Pedana (rural)',
      'Kaikaluru (partial overlap)',
    ],
    'Kurnool': [
      'Orvakal',
      'Kodumur',
      'Veldurthi',
      'Bethamcherla',
      'Kallur (rural)',
    ],
    'Nandyal': [
      'Atmakur',
      'Mahanandi',
      'Banaganapalle',
      'Dhone (rural)',
      'Allagadda',
    ],
    'NTR': [
      'Ibrahimpatnam (rural)',
      'G Konduru',
      'A Konduru',
      'Mylavaram',
      'Tiruvuru (rural)',
    ],
    'Palnadu': [
      'Sattenapalle (rural)',
      'Dachepalle',
      'Gurajala',
      'Rentachintala',
      'Macherla (rural)',
    ],
    'Parvathipuram Manyam': [
      'Balijipeta',
      'Komarada',
      'Seethanagaram',
      'Salur (rural)',
      'Makkuva',
    ],
    'Prakasam': [
      'Addanki',
      'Martur',
      'Inkollu',
      'Podili',
      'Markapuram (rural)',
    ],
    'S.P.S. Nellore': [
      'Podalakur',
      'Rapur',
      'Muthukur',
      'Allur',
      'Ananthasagaram',
    ],
    'Sri Sathya Sai': [
      'Bukkapatnam',
      'Puttaparthi (rural)',
      'Kothacheruvu',
      'Gorantla',
      'Chilamathur',
    ],
    'Srikakulam': [
      'Amadalavalasa (rural)',
      'Laveru',
      'Ponduru',
      'G Sigadam',
      'Etcherla',
    ],
    'Tirupati': [
      'Yerpedu',
      'Srikalahasti (rural)',
      'Renigunta (rural)',
      'Chandragiri (rural)',
      'Pileru',
    ],
    'Visakhapatnam': [
      'Anandapuram',
      'Bheemunipatnam (rural)',
      'Padmanabham',
      'Sabbavaram',
      'Paravada',
    ],
    'Vizianagaram': [
      'Cheepurupalle',
      'Gajapathinagaram',
      'Garividi',
      'Nellimarla',
      'Bondapalli',
    ],
    'West Godavari': [
      'Bhimavaram (rural)',
      'Palakoderu',
      'Narsapuram (rural)',
      'Mogaltur',
      'Penumantra',
    ],
    'YSR Kadapa': [
      'Rayachoti (rural)',
      'Lakkireddipalli',
      'Vempalle',
      'Yerraguntla',
      'Badvel (rural)',
    ],
  };

  // District codes for User ID generation
  static final Map<String, String> districtCodes = {
    'Anantapuramu': 'ANT',
    'Chittoor': 'CHT',
    'East Godavari': 'EGD',
    'Eluru': 'ELR',
    'Guntur': 'GNT',
    'Kakinada': 'KKD',
    'Konaseema': 'KNS',
    'Krishna': 'KRS',
    'Kurnool': 'KRN',
    'Nandyal': 'NDL',
    'NTR': 'NTR',
    'Palnadu': 'PLN',
    'Parvathipuram Manyam': 'PVM',
    'Prakasam': 'PRK',
    'S.P.S. Nellore': 'NLR',
    'Sri Sathya Sai': 'SSS',
    'Srikakulam': 'SKL',
    'Tirupati': 'TPT',
    'Visakhapatnam': 'VSK',
    'Vizianagaram': 'VZM',
    'West Godavari': 'WGD',
    'YSR Kadapa': 'KDP',
  };

  // Roles
  static final List<String> roles = [
    'Admin',
    'Anganwadi Teacher',
  ];

  // Generate User IDs for a district
  static List<String> getUserIdsForDistrict(String district) {
    final code = districtCodes[district];
    if (code == null) return [];

    return List.generate(50, (index) {
      final number = (index + 1).toString().padLeft(3, '0');
      return '${code}AT$number';
    });
  }

  // Get villages for a district
  static List<String> getVillagesForDistrict(String district) {
    return districtVillages[district] ?? [];
  }
}
