import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthometest/providers/kakao_user_provider.dart';
import 'package:smarthometest/providers/user_provider.dart';

class MyInfoPage extends StatelessWidget {
  static String routeName = "/MyInfoPage";
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kakaoUserProvider = Provider.of<KaKaoUserProvider>(context);
    final kakaoUser = kakaoUserProvider.user;
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.name;

    final String nickname = kakaoUser?.kakaoAccount?.profile?.nickname ?? (user ?? "사용자").toString();
    final String email = kakaoUser?.kakaoAccount?.email ?? '이메일 정보가 없습니다!';
    final String? profileImageUrl = kakaoUser?.kakaoAccount?.profile?.profileImageUrl;

    return Scaffold(
      body: Column(
        children: [
          // ✅ 유저 프로필 이미지 전달
          Expanded(flex: 2, child: _TopPortion(profileImageUrl: profileImageUrl)),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    nickname, // ✅ 닉네임 적용
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(email), // ✅ 이메일 적용
                  const SizedBox(height: 16),
                  const _ProfileInfoRow(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.surface,),
                              Text(
                                '뒤로가기',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:Theme.of(context).colorScheme.surface ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({Key? key}) : super(key: key);

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("테스트", 900),
    ProfileInfoItem("테스트2", 120),
    ProfileInfoItem("테스트3", 200),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items
            .map((item) => Expanded(
          child: Row(
            children: [
              if (_items.indexOf(item) != 0) const VerticalDivider(),
              Expanded(child: _singleItem(context, item)),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          item.value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      Text(
        item.title,
        style: Theme.of(context).textTheme.bodySmall,
      )
    ],
  );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatelessWidget {
  final String? profileImageUrl; // ✅ 전달받은 프로필 이미지 URL
  const _TopPortion({Key? key, this.profileImageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      // ✅ 유저 이미지가 있을 때는 NetworkImage, 없을 때는 AssetImage
                      image: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!) as ImageProvider
                          : const AssetImage("assets/good.png"),
                      fit: BoxFit.cover, // 이미지 크기 조정
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
