
// List<Map<String, dynamic>> getDayData(BuildContext context)
List<Map<String, dynamic>> getDeviceEData() {
  // List<dynamic> data = response.data;
  List<dynamic> data = [
    {
      "device": "TV",
      "electricalEnergy": 120.5
    },
    {
      "device": "냉장고",
      "electricalEnergy": 200.0
    },
    {
      "device": "에어컨",
      "electricalEnergy": 180.0
    },
    {
      "device": "세탁기",
      "electricalEnergy": 90.0
    },
    {
      "device": "조명",
      "electricalEnergy": 20.0
    },
    {
      "device": "기타",
      "electricalEnergy": 70.0
    }
  ];


  List<Map<String, dynamic>> deviceList = data.map((item) {
    return {
      "device": item['device'],
      "electricalEnergy": item['electricalEnergy']
    };
  }).toList();

  // electricalEnergy를 기준으로 내림차순 정렬
  deviceList.sort((a, b) => b['electricalEnergy'].compareTo(a['electricalEnergy']));

  return deviceList;
}

//일별 전력량
List<Map<String, dynamic>> getDayEData() {
  // List<dynamic> data = response.data;
  List<dynamic> data = [
    {
      "date": "24/10/08",
      "electricalEnergy": 1.8
    },
    {
      "date": "24/10/09", // 월요일
      "electricalEnergy": 1.2 // 평일, 사용량이 약간 낮음
    },
    {
      "date": "24/10/10", // 화요일
      "electricalEnergy": 1.3 // 평일, 일반적인 사용량
    },
    {
      "date": "24/10/11", // 수요일
      "electricalEnergy": 1.1 // 평일, 사용량이 조금 더 낮음
    },
    {
      "date": "24/10/12", // 목요일
      "electricalEnergy": 1.4 // 평일, 사용량이 다시 상승
    },
    {
      "date": "24/10/13", // 금요일
      "electricalEnergy": 1.5 // 평일, 주말을 앞두고 약간의 증가
    },
    {
      "date": "24/10/14", // 토요일
      "electricalEnergy": 2.0 // 주말, 사용량 증가
    },
  ];

  List<Map<String, dynamic>> dayList = data.map((item) {
    return {
      "date": item['date'],
      "electricalEnergy": item['electricalEnergy']
    };
  }).toList();
  return dayList;
}

List<Map<String, dynamic>> getMonthEData() {
  ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  List<Map<String, dynamic>> data = [
    {
      'month': "Jan",
      'electricalEnergy': 450
    },
    {
      'month': "Feb", // 겨울
      'electricalEnergy': 420 // 난방기 사용 지속
    },
    {
      'month': "Mar", // 초봄
      'electricalEnergy': 320 // 난방 사용 감소
    },
    {
      'month': "Apr", // 봄
      'electricalEnergy': 350 // 온화한 날씨로 전력 소비 감소
    },
    {
      'month': "May", // 늦봄
      'electricalEnergy': 400 // 날씨가 따뜻해지며 소비량 약간 증가
    },
    {
      'month': "Jun", // 초여름
      'electricalEnergy': 500 // 에어컨 사용 시작으로 소비량 증가
    },
    {
      'month': "Jul", // 여름
      'electricalEnergy': 600 // 에어컨 사용량 최대치
    },
    {
      'month': "Aug", // 여름
      'electricalEnergy': 600 // 여전히 높은 에어컨 사용량
    },
    {
      'month': "Sep", // 초가을
      'electricalEnergy': 550 // 에어컨 사용량 감소
    },
    {
      'month': "Oct", // 가을
      'electricalEnergy': 350 // 온화한 날씨로 소비량 감소
    },
    {
      'month': "Nov", // 늦가을
      'electricalEnergy': 400 // 난방기 사용 시작
    },
    {
      'month': "Dec", // 겨울
      'electricalEnergy': 480 // 난방 사용으로 소비량 증가
    },
  ];

  List<Map<String, dynamic>> monthList = data.map((item) {
    return {
      "month": item['month'],
      "electricalEnergy": item['electricalEnergy']
    };
  }).toList();
  return monthList;
}

List<Map<String, dynamic>> getDeviceList() {
  List<dynamic> data = [
    {"deviceName": "TV", "modelName": "SmartSense-3000"},
    {"deviceName": "냉장고", "modelName": "EcoBuddy-Pro"},
    {"deviceName": "에어컨", "modelName": "VisionAI-V10"},
    {"deviceName": "세탁기", "modelName": "QuantumEdge-X2"},
    {"deviceName": "조명", "modelName": "AeroFlex-G1"},
    {"deviceName": "컴퓨터", "modelName": "SmartCore-AI8"},

    {"deviceName": "TV", "modelName": "SmartSense-3000"},
    {"deviceName": "냉장고", "modelName": "EcoBuddy-Pro"},
    {"deviceName": "에어컨", "modelName": "VisionAI-V10"},
    {"deviceName": "세탁기", "modelName": "QuantumEdge-X2"},
    {"deviceName": "조명", "modelName": "AeroFlex-G1"},
    {"deviceName": "컴퓨터", "modelName": "SmartCore-AI8"},

    {"deviceName": "TV", "modelName": "SmartSense-3000"},
    {"deviceName": "냉장고", "modelName": "EcoBuddy-Pro"},
    {"deviceName": "에어컨", "modelName": "VisionAI-V10"},
    {"deviceName": "세탁기", "modelName": "QuantumEdge-X2"},
    {"deviceName": "조명", "modelName": "AeroFlex-G1"},
    {"deviceName": "컴퓨터", "modelName": "SmartCore-AI8"}
  ];
  List<Map<String, dynamic>> deviceList = data.map((item) {
    return {
      "deviceName": item['deviceName'],
      "modelName": item['modelName']
    };
  }).toList();
  return deviceList;
}