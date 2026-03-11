import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../cachehelper/toast.dart';
import '../../../res/apptextstyle.dart';
import 'UsermoneyInfo_screen.dart';


class UserListScreen extends StatelessWidget {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('List of users'),centerTitle: true,),
      body: StreamBuilder<QuerySnapshot>(
        // Filter করে শুধু role = "User"
        stream: usersCollection.where('role', isEqualTo: 'user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;

          return Column(
            children: [
              Card(
                elevation: 3,
                color: Colors.green.shade50,
                child: SizedBox(
                    width: double.infinity,
                    height: 30.h,
                    child: Center(child: Text('User Length:${ users.length}',
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),))),
              ),
              SizedBox(height: 5.h,),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final user = doc.data() as Map<String, dynamic>;
                    final userDocId = doc.id; //
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>
                                UserMoneyInfoScreen (
                                  userId: user['user_id'],
                                  name: user['name'],
                                  email: user['email'],
                                  phone: user['phone'],
                                  nid: user['nid'],
                                  birthdate: user['birthdate'],
                                  address: user['address'],
                                  nomineeName: user['nomineeName'],
                                  nomineeRelation: user['nomineeRelation'],
                                )));
                          },
                          child: Card(
                            margin:  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:  EdgeInsets.only(left: 8.0.r),
                                      child: Text('UserDocID: $userDocId',style: AppTextStyles.style10_bold,)
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, color: Colors.blue),
                                      onPressed: () async {
                                        await Clipboard.setData(ClipboardData(text: userDocId)); // ✅ Copy to clipboard
                                        CustomToast().showToast(context,'Copied: $userDocId', Colors.green);
                                      },
                                    ),
                                  ],
                                ),
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.teal.shade100,
                                    child: const Icon(Icons.person, color: Colors.teal),
                                  ),
                                  title: Text(
                                    user['name']?? 'No Name',maxLines: 2,
                                    style: AppTextStyles.small_bold,
                                  ),
                                  subtitle: Text('${user['email'] ?? 'N/A'}',overflow: TextOverflow.ellipsis,maxLines: 1,
                                  style: AppTextStyles.style10_normal,),
                                  trailing: Text(
                                    'ID: ${user['user_id'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );

                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}





