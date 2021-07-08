import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:recetas/src/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../SQLite.dart';
import 'UserForm.dart';

class LoginRegister extends StatefulWidget {
  @override
  _LoginRegister createState() => _LoginRegister();
}

class _LoginRegister extends State<LoginRegister> {
  SQLite sql = new SQLite();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('Login', style: TextStyle(fontSize: 34, color: Colors.cyan)),
          _buildEmail(),
          _buildPassword(),
          _buildSubmit(context),
          Text('Or if you are new register with: ',
              style: TextStyle(fontSize: 19, color: Colors.grey)),
          _buildRegister(context),
        ],
      ),
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      controller: email,
      decoration: InputDecoration(hintText: 'Email'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  Widget _buildPassword() {
    return TextFormField(
      controller: password,
      decoration: InputDecoration(hintText: 'Password'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildSubmit(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Processing Data')));
            int res = await sql.searchUserByEmail(email.text, password.text);
            print('user who wants to log in res: $res');
            if (res == -1) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('There was an error in the login')));
            } else {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('loggedIn', true);
              prefs.setInt('loginId', res);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Login Successful')));
            }
          }
        },
        child: Text('Submit'),
      ),
    );
  }

  Widget _buildRegister(BuildContext context) {
    return ElevatedButton(
        child: Text('Register'),
        onPressed: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => UserForm()))
            });
  }
}
