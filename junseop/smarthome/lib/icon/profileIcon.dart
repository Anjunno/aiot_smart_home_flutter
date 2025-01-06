import 'package:flutter/material.dart';
// 메뉴 항목을 정의하는 Enum
enum Menu { itemOne, itemTwo, itemThree }

// 프로필 아이콘을 클릭하면 나타나는 팝업 메뉴
class ProfileIcon extends StatelessWidget {
  const ProfileIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      icon: const Icon(Icons.person), // 프로필 아이콘
      offset: const Offset(0, 40), // 팝업 메뉴의 위치 설정
      onSelected: (Menu item) {}, // 항목 선택 시 처리할 내용
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
        const PopupMenuItem<Menu>(
          value: Menu.itemOne,
          child: Text('Account'), // 계정 메뉴 항목
        ),
        const PopupMenuItem<Menu>(
          value: Menu.itemTwo,
          child: Text('Settings'), // 설정 메뉴 항목
        ),
        const PopupMenuItem<Menu>(
          value: Menu.itemThree,
          child: Text('Sign Out'), // 로그아웃 메뉴 항목
        ),
      ],
    );
  }
}