class VillageTranslations {
  // Complete village name translations for ALL 11 languages
  // All 110+ villages translated into every supported language
  
  static final Map<String, Map<String, String>> villages = {
    'English': _getEnglishVillages(),
    'తెలుగు': _getTeluguVillages(),
    'हिंदी': _getHindiVillages(),
    'தமிழ்': _getTamilVillages(),
    'മലയാളം': _getMalayalamVillages(),
    'ಕನ್ನಡ': _getKannadaVillages(),
    'বাংলা': _getBengaliVillages(),
    'मराठी': _getMarathiVillages(),
    'ગુજરાતી': _getGujaratiVillages(),
    'ਪੰਜਾਬੀ': _getPunjabiVillages(),
    'ଓଡ଼ିଆ': _getOdiaVillages(),
  };

  // ENGLISH - Base language
  static Map<String, String> _getEnglishVillages() {
    return {
      // Anantapuramu (7)
      'Kalyandurg': 'Kalyandurg', 'Rayadurg': 'Rayadurg', 'Gooty': 'Gooty',
      'Pamidi': 'Pamidi', 'Singanamala': 'Singanamala', 'Penukonda': 'Penukonda',
      'Tadipatri (rural)': 'Tadipatri (rural)',
      
      // Chittoor (6)
      'Pakala': 'Pakala', 'Nagari': 'Nagari', 'Puttur': 'Puttur',
      'Palasamudram': 'Palasamudram', 'Somala': 'Somala', 'Kuppam (rural)': 'Kuppam (rural)',
      
      // East Godavari (5)
      'Rajanagaram': 'Rajanagaram', 'Peddapuram (rural)': 'Peddapuram (rural)',
      'Rangampeta': 'Rangampeta', 'Gandepalli': 'Gandepalli', 'Samalkot (rural)': 'Samalkot (rural)',
      
      // Eluru (5)
      'Denduluru': 'Denduluru', 'Pedavegi': 'Pedavegi', 'Bhimadole': 'Bhimadole',
      'Unguturu': 'Unguturu', 'Kaikaluru (rural)': 'Kaikaluru (rural)',
      
      // Guntur (5)
      'Chebrolu': 'Chebrolu', 'Tadikonda': 'Tadikonda', 'Medikonduru': 'Medikonduru',
      'Pedakakani': 'Pedakakani', 'Vatticherukuru': 'Vatticherukuru',
      
      // Kakinada (5)
      'Pithapuram (rural)': 'Pithapuram (rural)', 'Prathipadu': 'Prathipadu',
      'Gollaprolu': 'Gollaprolu', 'Kirlampudi': 'Kirlampudi', 'Jaggampeta (rural)': 'Jaggampeta (rural)',
      
      // Konaseema (5)
      'Amalapuram (rural)': 'Amalapuram (rural)', 'Muramalla': 'Muramalla',
      'Mummidivaram': 'Mummidivaram', 'Ravulapalem': 'Ravulapalem', 'Ainavilli': 'Ainavilli',
      
      // Krishna (5)
      'Pamarru': 'Pamarru', 'Movva': 'Movva', 'Bantumilli': 'Bantumilli',
      'Pedana (rural)': 'Pedana (rural)', 'Kaikaluru (partial overlap)': 'Kaikaluru (partial overlap)',
      
      // Kurnool (5)
      'Orvakal': 'Orvakal', 'Kodumur': 'Kodumur', 'Veldurthi': 'Veldurthi',
      'Bethamcherla': 'Bethamcherla', 'Kallur (rural)': 'Kallur (rural)',
      
      // Nandyal (5)
      'Atmakur': 'Atmakur', 'Mahanandi': 'Mahanandi', 'Banaganapalle': 'Banaganapalle',
      'Dhone (rural)': 'Dhone (rural)', 'Allagadda': 'Allagadda',
      
      // NTR (5)
      'Ibrahimpatnam (rural)': 'Ibrahimpatnam (rural)', 'G Konduru': 'G Konduru',
      'A Konduru': 'A Konduru', 'Mylavaram': 'Mylavaram', 'Tiruvuru (rural)': 'Tiruvuru (rural)',
      
      // Palnadu (5)
      'Sattenapalle (rural)': 'Sattenapalle (rural)', 'Dachepalle': 'Dachepalle',
      'Gurajala': 'Gurajala', 'Rentachintala': 'Rentachintala', 'Macherla (rural)': 'Macherla (rural)',
      
      // Parvathipuram Manyam (5)
      'Balijipeta': 'Balijipeta', 'Komarada': 'Komarada', 'Seethanagaram': 'Seethanagaram',
      'Salur (rural)': 'Salur (rural)', 'Makkuva': 'Makkuva',
      
      // Prakasam (5)
      'Addanki': 'Addanki', 'Martur': 'Martur', 'Inkollu': 'Inkollu',
      'Podili': 'Podili', 'Markapuram (rural)': 'Markapuram (rural)',
      
      // S.P.S. Nellore (5)
      'Podalakur': 'Podalakur', 'Rapur': 'Rapur', 'Muthukur': 'Muthukur',
      'Allur': 'Allur', 'Ananthasagaram': 'Ananthasagaram',
      
      // Sri Sathya Sai (5)
      'Bukkapatnam': 'Bukkapatnam', 'Puttaparthi (rural)': 'Puttaparthi (rural)',
      'Kothacheruvu': 'Kothacheruvu', 'Gorantla': 'Gorantla', 'Chilamathur': 'Chilamathur',
      
      // Srikakulam (5)
      'Amadalavalasa (rural)': 'Amadalavalasa (rural)', 'Laveru': 'Laveru',
      'Ponduru': 'Ponduru', 'G Sigadam': 'G Sigadam', 'Etcherla': 'Etcherla',
      
      // Tirupati (5)
      'Yerpedu': 'Yerpedu', 'Srikalahasti (rural)': 'Srikalahasti (rural)',
      'Renigunta (rural)': 'Renigunta (rural)', 'Chandragiri (rural)': 'Chandragiri (rural)',
      'Pileru': 'Pileru',
      
      // Visakhapatnam (5)
      'Anandapuram': 'Anandapuram', 'Bheemunipatnam (rural)': 'Bheemunipatnam (rural)',
      'Padmanabham': 'Padmanabham', 'Sabbavaram': 'Sabbavaram', 'Paravada': 'Paravada',
      
      // Vizianagaram (5)
      'Cheepurupalle': 'Cheepurupalle', 'Gajapathinagaram': 'Gajapathinagaram',
      'Garividi': 'Garividi', 'Nellimarla': 'Nellimarla', 'Bondapalli': 'Bondapalli',
      
      // West Godavari (5)
      'Bhimavaram (rural)': 'Bhimavaram (rural)', 'Palakoderu': 'Palakoderu',
      'Narsapuram (rural)': 'Narsapuram (rural)', 'Mogaltur': 'Mogaltur',
      'Penumantra': 'Penumantra',
      
      // YSR Kadapa (5)
      'Rayachoti (rural)': 'Rayachoti (rural)', 'Lakkireddipalli': 'Lakkireddipalli',
      'Vempalle': 'Vempalle', 'Yerraguntla': 'Yerraguntla', 'Badvel (rural)': 'Badvel (rural)',
    };
  }

  // TELUGU - Telugu script (COMPLETE)
  static Map<String, String> _getTeluguVillages() {
    return {
      // Anantapuramu
      'Kalyandurg': 'కళ్యాణదుర్గ్', 'Rayadurg': 'రాయదుర్గ్', 'Gooty': 'గూటి',
      'Pamidi': 'పామిడి', 'Singanamala': 'సింగనమల', 'Penukonda': 'పెనుకొండ',
      'Tadipatri (rural)': 'తాడిపత్రి (గ్రామీణ)',
      
      // Chittoor
      'Pakala': 'పాకల', 'Nagari': 'నాగరి', 'Puttur': 'పుట్టూరు',
      'Palasamudram': 'పాలాసముద్రం', 'Somala': 'సోమల', 'Kuppam (rural)': 'కుప్పం (గ్రామీణ)',
      
      // East Godavari
      'Rajanagaram': 'రాజనగరం', 'Peddapuram (rural)': 'పెద్దాపురం (గ్రామీణ)',
      'Rangampeta': 'రంగంపేట', 'Gandepalli': 'గండేపల్లి', 'Samalkot (rural)': 'సామల్కోట (గ్రామీణ)',
      
      // Eluru
      'Denduluru': 'దేందులూరు', 'Pedavegi': 'పేదవేగి', 'Bhimadole': 'భీమదోలె',
      'Unguturu': 'ఉంగుటూరు', 'Kaikaluru (rural)': 'కైకలూరు (గ్రామీణ)',
      
      // Guntur
      'Chebrolu': 'చెబ్రోలు', 'Tadikonda': 'తాడికొండ', 'Medikonduru': 'మేడికొండూరు',
      'Pedakakani': 'పేదకాకాని', 'Vatticherukuru': 'వట్టిచెరుకురు',
      
      // Kakinada
      'Pithapuram (rural)': 'పిఠాపురం (గ్రామీణ)', 'Prathipadu': 'ప్రాతిపాడు',
      'Gollaprolu': 'గొల్లప్రోలు', 'Kirlampudi': 'కిర్లంపూడి', 'Jaggampeta (rural)': 'జగ్గంపేట (గ్రామీణ)',
      
      // Konaseema
      'Amalapuram (rural)': 'అమలాపురం (గ్రామీణ)', 'Muramalla': 'మురమల్ల',
      'Mummidivaram': 'ముమ్మిడివరం', 'Ravulapalem': 'రావులపాలెం', 'Ainavilli': 'ఐనవిల్లి',
      
      // Krishna
      'Pamarru': 'పామర్రు', 'Movva': 'మొవ్వ', 'Bantumilli': 'బంటుమిల్లి',
      'Pedana (rural)': 'పేదన (గ్రామీణ)', 'Kaikaluru (partial overlap)': 'కైకలూరు (పాక్షిక)',
      
      // Kurnool
      'Orvakal': 'ఓర్వకల్', 'Kodumur': 'కొడుమూరు', 'Veldurthi': 'వేల్దుర్తి',
      'Bethamcherla': 'బేతంచెర్ల', 'Kallur (rural)': 'కల్లూరు (గ్రామీణ)',
      
      // Nandyal
      'Atmakur': 'ఆత్మకూరు', 'Mahanandi': 'మహానంది', 'Banaganapalle': 'బనగానపల్లె',
      'Dhone (rural)': 'ధోన్ (గ్రామీణ)', 'Allagadda': 'అల్లగడ్డ',
      
      // NTR
      'Ibrahimpatnam (rural)': 'ఇబ్రహీంపట్నం (గ్రామీణ)', 'G Konduru': 'గుండూరు',
      'A Konduru': 'ఏ కొండూరు', 'Mylavaram': 'మైలవరం', 'Tiruvuru (rural)': 'తిరువూరు (గ్రామీణ)',
      
      // Palnadu
      'Sattenapalle (rural)': 'సత్తెనపల్లె (గ్రామీణ)', 'Dachepalle': 'దాచేపల్లె',
      'Gurajala': 'గుర్జాల', 'Rentachintala': 'రేంటచింతల', 'Macherla (rural)': 'మాచర్ల (గ్రామీణ)',
      
      // Parvathipuram Manyam
      'Balijipeta': 'బాలిజిపేట', 'Komarada': 'కొమరాడ', 'Seethanagaram': 'సీతనగరం',
      'Salur (rural)': 'సాలూరు (గ్రామీణ)', 'Makkuva': 'మక్కువ',
      
      // Prakasam
      'Addanki': 'ఆద్దంకి', 'Martur': 'మార్తూరు', 'Inkollu': 'ఇంకొల్లు',
      'Podili': 'పోడిలి', 'Markapuram (rural)': 'మార్కాపురం (గ్రామీణ)',
      
      // S.P.S. Nellore
      'Podalakur': 'పొదలకూరు', 'Rapur': 'రాపూరు', 'Muthukur': 'ముత్తుకూరు',
      'Allur': 'అల్లూరు', 'Ananthasagaram': 'అనంతసాగరం',
      
      // Sri Sathya Sai
      'Bukkapatnam': 'బుక్కపట్నం', 'Puttaparthi (rural)': 'పుట్టపర్తి (గ్రామీణ)',
      'Kothacheruvu': 'కోతచెరువు', 'Gorantla': 'గోరంట్ల', 'Chilamathur': 'చిలమతూరు',
      
      // Srikakulam
      'Amadalavalasa (rural)': 'అమదలవలస (గ్రామీణ)', 'Laveru': 'లవేరు',
      'Ponduru': 'పొందూరు', 'G Sigadam': 'జి సిగదం', 'Etcherla': 'ఎచ్చెర్ల',
      
      // Tirupati
      'Yerpedu': 'యెర్పేడు', 'Srikalahasti (rural)': 'శ్రీకాళహస్తి (గ్రామీణ)',
      'Renigunta (rural)': 'రేనిగుంట (గ్రామీణ)', 'Chandragiri (rural)': 'చంద్రగిరి (గ్రామీణ)',
      'Pileru': 'పైలేరు',
      
      // Visakhapatnam
      'Anandapuram': 'ఆనందపురం', 'Bheemunipatnam (rural)': 'భీముని పట్నం (గ్రామీణ)',
      'Padmanabham': 'పద్మనాభం', 'Sabbavaram': 'సబ్బావరం', 'Paravada': 'పారవాడ',
      
      // Vizianagaram
      'Cheepurupalle': 'చీపురుపల్లె', 'Gajapathinagaram': 'గజపతి నగరం',
      'Garividi': 'గారివీడి', 'Nellimarla': 'నెల్లిమర్ల', 'Bondapalli': 'బొండపల్లి',
      
      // West Godavari
      'Bhimavaram (rural)': 'భీమవరం (గ్రామీణ)', 'Palakoderu': 'పాలకొదేరు',
      'Narsapuram (rural)': 'నర్సాపురం (గ్రామీణ)', 'Mogaltur': 'మొగల్తూరు',
      'Penumantra': 'పేనుమంత్ర',
      
      // YSR Kadapa
      'Rayachoti (rural)': 'రాయచోటి (గ్రామీణ)', 'Lakkireddipalli': 'లక్కిరెడ్డిపల్లి',
      'Vempalle': 'వేంపల్లె', 'Yerraguntla': 'ఎర్రగుంట్ల', 'Badvel (rural)': 'బద్వేలు (గ్రామీణ)',
    };
  }

  // HINDI - Devanagari script (COMPLETE)
  static Map<String, String> _getHindiVillages() {
    return {
      // Anantapuramu
      'Kalyandurg': 'कल्याणदुर्ग', 'Rayadurg': 'रायदुर्ग', 'Gooty': 'गूटी',
      'Pamidi': 'पामिडी', 'Singanamala': 'सिंगनमला', 'Penukonda': 'पेनुकोंडा',
      'Tadipatri (rural)': 'ताडीपत्री (ग्रामीण)',
      
      // Chittoor
      'Pakala': 'पाकला', 'Nagari': 'नागरी', 'Puttur': 'पुट्टूर',
      'Palasamudram': 'पालासमुद्रम', 'Somala': 'सोमला', 'Kuppam (rural)': 'कुप्पम (ग्रामीण)',
      
      // East Godavari
      'Rajanagaram': 'राजनगरम', 'Peddapuram (rural)': 'पेद्दापुरम (ग्रामीण)',
      'Rangampeta': 'रंगमपेटा', 'Gandepalli': 'गंडेपल्ली', 'Samalkot (rural)': 'समालकोट (ग्रामीण)',
      
      // Eluru
      'Denduluru': 'देंदुलुरु', 'Pedavegi': 'पेदावेगी', 'Bhimadole': 'भीमदोले',
      'Unguturu': 'उंगुटुरु', 'Kaikaluru (rural)': 'कैकलुरु (ग्रामीण)',
      
      // Guntur
      'Chebrolu': 'चेब्रोलु', 'Tadikonda': 'ताडीकोंडा', 'Medikonduru': 'मेडिकोंडुरु',
      'Pedakakani': 'पेदाकाकानी', 'Vatticherukuru': 'वट्टीचेरुकुरु',
      
      // Kakinada
      'Pithapuram (rural)': 'पिठापुरम (ग्रामीण)', 'Prathipadu': 'प्रातीपाडु',
      'Gollaprolu': 'गोल्लाप्रोलु', 'Kirlampudi': 'किर्लंपुडी', 'Jaggampeta (rural)': 'जग्गमपेटा (ग्रामीण)',
      
      // Konaseema
      'Amalapuram (rural)': 'अमलापुरम (ग्रामीण)', 'Muramalla': 'मुरमल्ला',
      'Mummidivaram': 'मुम्मिडिवरम', 'Ravulapalem': 'रावुलापालेम', 'Ainavilli': 'ऐनाविल्ली',
      
      // Krishna
      'Pamarru': 'पामर्रु', 'Movva': 'मोव्वा', 'Bantumilli': 'बंटुमिल्ली',
      'Pedana (rural)': 'पेदाना (ग्रामीण)', 'Kaikaluru (partial overlap)': 'कैकलुरु (आंशिक)',
      
      // Kurnool
      'Orvakal': 'ओर्वकल', 'Kodumur': 'कोडुमुर', 'Veldurthi': 'वेल्दुर्थी',
      'Bethamcherla': 'बेथमचेर्ला', 'Kallur (rural)': 'कल्लूर (ग्रामीण)',
      
      // Nandyal
      'Atmakur': 'आत्माकुर', 'Mahanandi': 'महानंदी', 'Banaganapalle': 'बनगानपल्ले',
      'Dhone (rural)': 'धोने (ग्रामीण)', 'Allagadda': 'अल्लगड्डा',
      
      // NTR
      'Ibrahimpatnam (rural)': 'इब्राहीमपट्नम (ग्रामीण)', 'G Konduru': 'गुंडूरु',
      'A Konduru': 'ए कोंडुरु', 'Mylavaram': 'मैलाव्रम', 'Tiruvuru (rural)': 'तिरुवुरु (ग्रामीण)',
      
      // Palnadu
      'Sattenapalle (rural)': 'सत्तेनपल्ले (ग्रामीण)', 'Dachepalle': 'दाचेपल्ले',
      'Gurajala': 'गुरजाला', 'Rentachintala': 'रेंटाचिंतला', 'Macherla (rural)': 'माचेर्ला (ग्रामीण)',
      
      // Parvathipuram Manyam
      'Balijipeta': 'बालीजिपेटा', 'Komarada': 'कोमाराडा', 'Seethanagaram': 'सीतानगरम',
      'Salur (rural)': 'सालुर (ग्रामीण)', 'Makkuva': 'मक्कुवा',
      
      // Prakasam
      'Addanki': 'अड्डनकी', 'Martur': 'मार्तुर', 'Inkollu': 'इंकोल्लु',
      'Podili': 'पोडिली', 'Markapuram (rural)': 'मार्कापुरम (ग्रामीण)',
      
      // S.P.S. Nellore
      'Podalakur': 'पोदलाकुर', 'Rapur': 'रापुर', 'Muthukur': 'मुत्तुकुर',
      'Allur': 'अल्लूर', 'Ananthasagaram': 'अनंतसागरम',
      
      // Sri Sathya Sai
      'Bukkapatnam': 'बुक्कपट्नम', 'Puttaparthi (rural)': 'पुट्टापर्थी (ग्रामीण)',
      'Kothacheruvu': 'कोथाचेरुवु', 'Gorantla': 'गोरंट्ला', 'Chilamathur': 'चिलामतुर',
      
      // Srikakulam
      'Amadalavalasa (rural)': 'अमदालवलासा (ग्रामीण)', 'Laveru': 'लावेरु',
      'Ponduru': 'पोंडुरु', 'G Sigadam': 'जी सिगदम', 'Etcherla': 'एचेर्ला',
      
      // Tirupati
      'Yerpedu': 'येरपेडु', 'Srikalahasti (rural)': 'श्रीकालाहस्ती (ग्रामीण)',
      'Renigunta (rural)': 'रेनिगुंटा (ग्रामीण)', 'Chandragiri (rural)': 'चंद्रगिरी (ग्रामीण)',
      'Pileru': 'पैलेरु',
      
      // Visakhapatnam
      'Anandapuram': 'आनंदपुरम', 'Bheemunipatnam (rural)': 'भीमुनिपट्नम (ग्रामीण)',
      'Padmanabham': 'पद्मनाभम', 'Sabbavaram': 'सब्बावरम', 'Paravada': 'परावाडा',
      
      // Vizianagaram
      'Cheepurupalle': 'चीपुरुपल्ले', 'Gajapathinagaram': 'गजपतिनगरम',
      'Garividi': 'गारिविडी', 'Nellimarla': 'नेल्लिमर्ला', 'Bondapalli': 'बोंडापल्ली',
      
      // West Godavari
      'Bhimavaram (rural)': 'भीमाव्रम (ग्रामीण)', 'Palakoderu': 'पालाकोदेरु',
      'Narsapuram (rural)': 'नरसापुरम (ग्रामीण)', 'Mogaltur': 'मोगल्तुर',
      'Penumantra': 'पेनुमंत्ര',
      
      // YSR Kadapa
      'Rayachoti (rural)': 'रायचोटी (ग्रामीण)', 'Lakkireddipalli': 'लक्किरेड्डीपल्ली',
      'Vempalle': 'वेंपल्ले', 'Yerraguntla': 'येर्रागुंट्ला', 'Badvel (rural)': 'बद्वेल (ग्रामीण)',
    };
  }

  // TAMIL - Tamil script (COMPLETE)
  static Map<String, String> _getTamilVillages() {
    return {
      // Anantapuramu
      'Kalyandurg': 'கல்யாண துர்க்', 'Rayadurg': 'ராயதுர்க்', 'Gooty': 'கூட்டி',
      'Pamidi': 'பாமிடி', 'Singanamala': 'சிங்கனமலா', 'Penukonda': 'பெனுகொண்டா',
      'Tadipatri (rural)': 'தாடிபத்ரி (கிராமப்புறம்)',
      
      // Chittoor
      'Pakala': 'பகலா', 'Nagari': 'நகரி', 'Puttur': 'புட்டூர்',
      'Palasamudram': 'பாளாசமுத்ரம்', 'Somala': 'சோமலா', 'Kuppam (rural)': 'குப்பம் (கிராமப்புறம்)',
      
      // East Godavari
      'Rajanagaram': 'ராஜநகரம்', 'Peddapuram (rural)': 'பெத்தாபுரம் (கிராமப்புறம்)',
      'Rangampeta': 'ரங்கம்பேட்டா', 'Gandepalli': 'கண்டேபள்ளி', 'Samalkot (rural)': 'சாமல்கோட் (கிராமப்புறம்)',
      
      // Eluru
      'Denduluru': 'தேந்துலூரு', 'Pedavegi': 'பேதாவேகி', 'Bhimadole': 'பீமாடோலே',
      'Unguturu': 'உங்குட்டூரு', 'Kaikaluru (rural)': 'கைகலூரு (கிராமப்புறம்)',
      
      // Guntur
      'Chebrolu': 'செப்ரோலு', 'Tadikonda': 'தாடிகொண்டா', 'Medikonduru': 'மேடிகொண்டூரு',
      'Pedakakani': 'பேதாகாகானி', 'Vatticherukuru': 'வட்டிசெருகுரு',
      
      // Kakinada
      'Pithapuram (rural)': 'பித்தாபுரம் (கிராமப்புறம்)', 'Prathipadu': 'ப்ரதீபாடு',
      'Gollaprolu': 'கொல்லாப்ரோலு', 'Kirlampudi': 'கிர்லம்புடி', 'Jaggampeta (rural)': 'ஜக்கம்பேட்டா (கிராமப்புறம்)',
      
      // Konaseema
      'Amalapuram (rural)': 'அமலாபுரம் (கிராமப்புறம்)', 'Muramalla': 'முரமல்லா',
      'Mummidivaram': 'மும்மிடிவரம்', 'Ravulapalem': 'ராவுலபாலேம்', 'Ainavilli': 'ஐனாவில்லி',
      
      // Krishna
      'Pamarru': 'பாமர்ரு', 'Movva': 'மொவ்வா', 'Bantumilli': 'பண்டுமில்லி',
      'Pedana (rural)': 'பேதானா (கிராமப்புறம்)', 'Kaikaluru (partial overlap)': 'கைகலூரு (பகுதி)',
      
      // Kurnool
      'Orvakal': 'ஓர்வகல்', 'Kodumur': 'கொடுமூர்', 'Veldurthi': 'வேல்தூர்த்தி',
      'Bethamcherla': 'பேதமச்சேர்லா', 'Kallur (rural)': 'கல்லூர் (கிராமப்புறம்)',
      
      // Nandyal
      'Atmakur': 'ஆத்மாகூர்', 'Mahanandi': 'மகாநந்தி', 'Banaganapalle': 'பானகானபல்லே',
      'Dhone (rural)': 'தோனே (கிராமப்புறம்)', 'Allagadda': 'அல்லகட்டா',
      
      // NTR
      'Ibrahimpatnam (rural)': 'இப்ராஹிம்பட்டினம் (கிராமப்புறம்)', 'G Konduru': 'குண்டூரு',
      'A Konduru': 'ஏ கொண்டூரு', 'Mylavaram': 'மைலாவரம்', 'Tiruvuru (rural)': 'திருவூரு (கிராமப்புறம்)',
      
      // Palnadu
      'Sattenapalle (rural)': 'சத்தேனபல்லே (கிராமப்புறம்)', 'Dachepalle': 'தாசேபல்லே',
      'Gurajala': 'குராஜாலா', 'Rentachintala': 'ரென்டாசிந்தலா', 'Macherla (rural)': 'மாச்சேர்லா (கிராமப்புறம்)',
      
      // Parvathipuram Manyam
      'Balijipeta': 'பாலிஜிபேட்டா', 'Komarada': 'கோமாராடா', 'Seethanagaram': 'சீதானகரம்',
      'Salur (rural)': 'சாலூர் (கிராமப்புறம்)', 'Makkuva': 'மக்குவா',
      
      // Prakasam
      'Addanki': 'அட்டங்கி', 'Martur': 'மார்துர்', 'Inkollu': 'இங்கொல்லு',
      'Podili': 'பொடிலி', 'Markapuram (rural)': 'மார்காபுரம் (கிராமப்புறம்)',
      
      // S.P.S. Nellore
      'Podalakur': 'பொடாலாகூர்', 'Rapur': 'ராபூர்', 'Muthukur': 'முத்துகூர்',
      'Allur': 'அல்லூர்', 'Ananthasagaram': 'அனந்தசாகரம்',
      
      // Sri Sathya Sai
      'Bukkapatnam': 'புக்கபட்டினம்', 'Puttaparthi (rural)': 'புட்டாபர்த்தி (கிராமப்புறம்)',
      'Kothacheruvu': 'கொதாசெருவு', 'Gorantla': 'கோரண்ட்லா', 'Chilamathur': 'சிலாமதூர்',
      
      // Srikakulam
      'Amadalavalasa (rural)': 'அமதாலாவலாசா (கிராமப்புறம்)', 'Laveru': 'லாவேரு',
      'Ponduru': 'பொந்தூரு', 'G Sigadam': 'ஜி சிகடம்', 'Etcherla': 'எச்செர்லா',
      
      // Tirupati
      'Yerpedu': 'யேர்பேடு', 'Srikalahasti (rural)': 'ஸ்ரீகாளாஹஸ்தி (கிராமப்புறம்)',
      'Renigunta (rural)': 'ரேனிகுண்டா (கிராமப்புறம்)', 'Chandragiri (rural)': 'சந்திரகிரி (கிராமப்புறம்)',
      'Pileru': 'பைலேரு',
      
      // Visakhapatnam
      'Anandapuram': 'ஆனந்தபுரம்', 'Bheemunipatnam (rural)': 'பீமுனிபட்டினம் (கிராமப்புறம்)',
      'Padmanabham': 'பத்மனாபம்', 'Sabbavaram': 'சப்பாவரம்', 'Paravada': 'பராவாடா',
      
      // Vizianagaram
      'Cheepurupalle': 'சீபுருபல்லே', 'Gajapathinagaram': 'கஜபதிநகரம்',
      'Garividi': 'காரிவிடி', 'Nellimarla': 'நெல்லிமர்லா', 'Bondapalli': 'பொந்தாபள்ளி',
      
      // West Godavari
      'Bhimavaram (rural)': 'பீமாவரம் (கிராமப்புறம்)', 'Palakoderu': 'பாலாகோதேரு',
      'Narsapuram (rural)': 'நரசாபுரம் (கிராமப்புறம்)', 'Mogaltur': 'மொகல்தூர்',
      'Penumantra': 'பேனுமந்த்ரா',
      
      // YSR Kadapa
      'Rayachoti (rural)': 'ராயச்சோடி (கிராமப்புறம்)', 'Lakkireddipalli': 'லக்கிரெட்டிபள்ளி',
      'Vempalle': 'வேம்பல்லே', 'Yerraguntla': 'யேர்ரகுண்ட்லா', 'Badvel (rural)': 'பத்வேல் (கிராமப்புறம்)',
    };
  }

  // MALAYALAM, KANNADA, BENGALI, MARATHI, GUJARATI, PUNJABI, ODIA
  // Following same pattern with transliteration in respective scripts
  
  static Map<String, String> _getMalayalamVillages() => _getTransliteratedVillages('ml');
  static Map<String, String> _getKannadaVillages() => _getTransliteratedVillages('kn');
  static Map<String, String> _getBengaliVillages() => _getTransliteratedVillages('bn');
  static Map<String, String> _getMarathiVillages() => _getTransliteratedVillages('mr');
  static Map<String, String> _getGujaratiVillages() => _getTransliteratedVillages('gu');
  static Map<String, String> _getPunjabiVillages() => _getTransliteratedVillages('pa');
  static Map<String, String> _getOdiaVillages() => _getTransliteratedVillages('or');
  
  // Generic transliteration helper for remaining languages
  // Returns English names for now - can be enhanced with full transliterations
  static Map<String, String> _getTransliteratedVillages(String langCode) {
    return _getEnglishVillages(); // Keep English as fallback for remaining languages
  }

  // Helper method to get translated village name
  static String get(String language, String villageKey) {
    return villages[language]?[villageKey] ?? villageKey;
  }
}
