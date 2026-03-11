import 'package:badges/badges.dart' as badges;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../auth/screen/login_screen.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../../contact/screen/contact_screen.dart';
import '../../../developer/developer_screen.dart';
import '../../about_us/screen/aboutus_screen.dart';
import '../../money record/screen/user_money_record_screen.dart';
import '../../notification/screen/user_notification_screen.dart';
import '../../notification/service/user_notification_service.dart';
import '../../profile/screen/profile_screen.dart';
import '../../userlist/screen/userlist_screen.dart';
import '../service/home_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserNotificationService _notificationService = UserNotificationService();
  final HomeService _homeService = HomeService();

  bool _isLoading = false;
  String userDocId = '';
  String name = '';
  String DocId = '';
  int totalTk = 0;

  @override
  void initState() {
    super.initState();
    _initData();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _initData() async {
    await getUserDocId();
    await getName();
    await countTotal();
  }

  Future<void> countTotal() async {
    final totalUsers = await totalMoney();
    if (!mounted) return;
    setState(() => totalTk = totalUsers);
  }

  Future<int> totalMoney() async {
    try {
      if (!mounted) return 0;
      setState(() => _isLoading = true);

      final totalUsers = await _homeService.getAllUsersTotalAmountStream().first;

      if (!mounted) return 0;
      setState(() => _isLoading = false);
      return totalUsers;
    } catch (e) {
      if (!mounted) return 0;
      setState(() => _isLoading = false);
      debugPrint('Error loading total money: $e');
      return 0;
    }
  }

  Future<void> getName() async {
    final userName = await CacheHelper().getString('names');
    final userDocId = await CacheHelper().getString('userDocId');

    if (!mounted) return;

    setState(() {
      name = userName ?? '';
      DocId = userDocId ?? '';
    });
  }

  Future<void> getUserDocId() async {
    final id = await CacheHelper().getString('userDocId');
    if (!mounted) return;
    setState(() => userDocId = id ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // title: const Text('Home'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          const NotificationBadgeWidget(),
          PopupMenuButton<int>(
            onSelected: (item) => _onSelected(item, context),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.login, color: Colors.black),
                    SizedBox(width: 10.w),
                    Text('Logout'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Image.asset('assets/images/contact-mail.png', height: 20.h, width: 20.w),
                     SizedBox(width: 10.w),
                    const Text('Contact'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Image.asset('assets/images/coding.png', height: 20.h, width: 20.w),
                     SizedBox(width: 10.w),
                    const Text('About Developer'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Name
            Padding(
              padding:  EdgeInsets.all(10.0.r),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name.toUpperCase(),
                  style: TextStyle(
                      fontSize: 25.sp, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Total Amount Card
            Padding(
              padding: EdgeInsets.all(14.0.r),
              child: Card(
                elevation: 5,
                child: Container(
                  height: 100.h,
                  width: 300.w,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$totalTk Tk',
                          style: TextStyle(
                              color: Colors.red, fontSize: 25.sp, fontWeight: FontWeight.bold),
                        ),
                         Text(
                          'Balance',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Cards Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.r),
              child: Column(
                children: [
                  _buildCardRow(
                    context,
                    first: _HomeCardData(
                      title: 'Transaction Report',
                      imagePath: 'assets/images/transactional.png',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserMoneyRecordScreen()),
                        );
                      },
                    ),
                    second: _HomeCardData(
                      title: 'Members List',
                      imagePath: 'assets/images/userlist.png',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UsersListScreen()),
                        );
                      },
                    ),
                  ),
                   SizedBox(height: 10.h),
                  _buildCardRow(
                    context,
                    first: _HomeCardData(
                      title: 'Profile',
                      imagePath: 'assets/images/profile.png',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UserProfileScreen(userId: DocId)),
                        );
                      },
                    ),
                    second: _HomeCardData(
                      title: 'About us',
                      imagePath: 'assets/images/about-us.png',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AboutUsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSelected(int item, BuildContext context) async {
    switch (item) {
      case 0:
        await _auth.signOut();
        CacheHelper().clear();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
        break;

      case 1:
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ContactScreen(color: Colors.red,)));
        }
        break;

      case 2:
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(
              builder: (context)=>DeveloperScreen(color: Colors.red,)));
        }
        break;
    }
  }

  Widget _buildCardRow(BuildContext context,
      {required _HomeCardData first, required _HomeCardData second}) {
    return Row(
      children: [
        Expanded(child: _HomeCard(first)),
         SizedBox(width: 10.w),
        Expanded(child: _HomeCard(second)),
      ],
    );
  }
}

class _HomeCardData {
  final String title;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  _HomeCardData(
      {required this.title, required this.imagePath, required this.color, required this.onTap});
}

class _HomeCard extends StatelessWidget {
  final _HomeCardData data;

  const _HomeCard(this.data);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Card(
        elevation: 5,
        child: Container(
          height: 150.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0.r),
                child: Image.asset(data.imagePath, color: data.color, width: 80.w, height: 50.h),
              ),
               SizedBox(height: 5.h),
              Text(
                data.title,
                style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Notification Badge Widget
class NotificationBadgeWidget extends StatelessWidget {
  const NotificationBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _notificationService = UserNotificationService();

    return FutureBuilder<List<String>>(
      future: _notificationService.getAdminDocIds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Icon(Icons.notifications);

        final adminDocIds = snapshot.data!;
        return StreamBuilder<int>(
          stream: _notificationService.getTotalUnreadCount(adminDocIds),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return badges.Badge(
              showBadge: count > 0,
              badgeContent: Text('$count', style: TextStyle(color: Colors.white, fontSize: 10.sp)),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.green,
                padding: EdgeInsets.all(6.r),
                borderRadius: BorderRadius.circular(8.r),
                elevation: 4,
                borderSide: BorderSide(color: Colors.white, width: 1.w),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserNotificationScreen(adminDocIds: adminDocIds)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
