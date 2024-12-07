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
      'facilities': ['접수 및 진료', '방사선실', '대기실', '약제실'],
      'image': 'assets/floor/ch2.gif',
    },
    3: {
      'level': '지상 2층',
      'facilities': ['영유아', '예방접종', '물리치료', '감염병 관리'],
      'image': 'assets/floor/ch3.gif',
    },
    4: {
      'level': '지상 3층',
      'facilities': [
        '건강생활팀',
        '마음건강팀',
        '소장실',
        '의약팀',
        '보건행정팀',
        '회의실',
        '의사실',
      ],
      'image': 'assets/floor/ch4.jpg',
    },
    5: {
      'level': '옥상',
      'facilities': ['옥상 휴게 공간'],
      'image': 'assets/floor/ch5.gif',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: floorData.length,
                itemBuilder: (context, index) {
                  final floor = floorData.keys.toList().reversed.toList()[index];
                  return _buildFloorCard(floor);
                },
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Container(
                key: ValueKey<int>(selectedFloor),
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.topCenter,
                child: _buildImageCard(floorData[selectedFloor]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorCard(int floor) {
    final isSelected = selectedFloor == floor;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFloor = floor;
        });
      },
      child: Card(
        color: isSelected ? Colors.blue[50] : Colors.white,
        elevation: isSelected ? 6 : 2,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                floorData[floor]!['level'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blueAccent : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                floorData[floor]!['facilities'].join(', '),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(Map<String, dynamic> floorInfo) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Image.asset(
            floorInfo['image'],
            fit: BoxFit.cover,
            width: 2000,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    floorInfo['level'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    floorInfo['facilities'].join(', '),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
