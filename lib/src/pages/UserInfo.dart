import 'package:flutter/material.dart';
import 'dart:io';
import 'package:recetas/src/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../SQLite.dart';
import 'LoginRegister.dart';

class UserInfo extends StatefulWidget {
  @override
  _UserInfo createState() => _UserInfo();
}

class _UserInfo extends State<UserInfo> {
  SQLite sql = new SQLite();
  String imagePath = '';
  User _user = User.empty();

  void doSomething() async {
    _user = await getUser();
  }

  @override
  Widget build(BuildContext context) {
    doSomething();
    double width = MediaQuery.of(context).size.width * 0.95;

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: Colors.grey)),
      width: width,
      child: Column(children: <Widget>[
        Row(children: <Widget>[
          _buildProfileImage(),
          Spacer(),
          _buildName(),
          Spacer(),
        ]),
        _buildDescription(),
        _buildLogout(),
        Text('Activity:', style: TextStyle(fontSize: 21, color: Colors.red)),

        //List of all the User's Recipes and liked Recipes
        // ListView(
        //   children: [
        //
        //
        //   ],
        // )
      ]),
    );
  }

  Widget _buildName() {
    double c_width = MediaQuery.of(context).size.width * 0.6;

    return Container(
        padding: const EdgeInsets.all(16.0),
        width: c_width,
        child: Text('${_user.name}',
            style: TextStyle(fontSize: 24, color: Colors.black)));
  }

  Widget _buildProfileImage() {
    return Container(
      width: 60,
      height: 80,
      // padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.all(Radius.circular(5)),
          image: DecorationImage(
            image: FileImage(new File(_user.imagePath)),
          )),
    );
  }

  Future<User> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User user;
    var realUser;
    if (prefs.containsKey('loginId')) {
      int id = prefs.getInt('loginId')!;
      print('id of user: $id');
      user = await sql.searchUser(id);
      realUser = user;
      if (realUser != null && realUser.name != '') {
        print('user: ${realUser.imagePath}');
        imagePath = realUser.imagePath;
      }
      return realUser;
    }
    return User.empty();
  }

  Widget _buildDescription() {
    //80% of screen width
    double c_width = MediaQuery.of(context).size.width * 0.8;

    return Container(
      padding: const EdgeInsets.all(16.0),
      width: c_width,
      child: Text('"${_user.description}"',
          style: TextStyle(fontSize: 15, color: Colors.grey),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildLogout() {
    return ElevatedButton(
      child: Text('Logout'),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('loggedIn', false);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginRegister()));
      },
    );
  }
}
