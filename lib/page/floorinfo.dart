import 'package:flutter/material.dart';

class FloorInfo extends StatefulWidget {
  const FloorInfo({super.key});

  @override
  State<FloorInfo> createState() => _FloorInfoState();
}

class _FloorInfoState extends State<FloorInfo> {
  int selectedFloor = 1;
  

  final Map<int, Map<String, dynamic>> floorData = {
    1: {
      'level': '지하 1층',
      'facilities': ['다목적실', '창고'],
      'image': 'assets/floor/ch1.gif',
    },
    2: {
      'level': '지상 1층',
      'facilities': ['접수및진료', '방사선실', '대기실', '약제실'],
      'image': 'assets/floor/ch2.gif',
    },
    3: {
      'level': '지상 2층',
      'facilities': ['영유아', '예방접종', '물리치료', '감염병관리'],
      'image': 'assets/floor/ch3.gif',
    },
    4: {
      'level': '지상 3층',
      'facilities': ['건강생활팀','마음건강팀', '소장실', '의약팀', '보건행정팀','회의실','의사실'],
      'image': 'assets/floor/ch4.jpg',
    },
    5: {
      'level': '옥상',
      'facilities': ['옥상휴게공간'],
      'image': 'assets/floor/ch5.gif',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('층별 안내'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: floorData.length,
                itemBuilder: (context, index) {
                  final floor = floorData.keys.toList().reversed.toList()[index];
                  return ListTile(
                    selected: selectedFloor == floor,
                    selectedTileColor: Colors.blue[100],
                    title: Text(floorData[floor]!['level']),
                    subtitle: Text(
                      floorData[floor]!['facilities'].join(', '),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      setState(() {
                        selectedFloor = floor;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          // 오른쪽 단면도 영역
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                floorData[selectedFloor]!['image'],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
