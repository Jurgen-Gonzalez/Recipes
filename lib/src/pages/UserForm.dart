import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:recetas/src/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../SQLite.dart';
import 'UserInfo.dart';

class UserForm extends StatefulWidget {
  @override
  _UserForm createState() => _UserForm();
}

class _UserForm extends State<UserForm> {
  String _filePath = '';
  SQLite sql = new SQLite();
  File file = File('');
  TextEditingController name = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController imagePath = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void _setFilePath(String path) {
    setState(() {
      _filePath = path;
    });
  }

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return MaterialApp(
        title: 'Recetas',
        theme: ThemeData(
          backgroundColor: Colors.grey,
          primarySwatch: Colors.purple,
        ),
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: new Text('Recetas'),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildUsername(),
                  _buildDescription(),
                  _buildUploadImage(),
                  _buildEmail(),
                  _buildPassword(),
                  _buildSubmit(context),
                ],
              ),
            )));
  }

  Widget _buildUsername() {
    return TextFormField(
      controller: name,
      decoration: InputDecoration(hintText: 'Username'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some username';
        }
        return null;
      },
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      controller: desc,
      decoration: InputDecoration(hintText: 'Description'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your description';
        }
        return null;
      },
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

  Widget _buildUploadImage() {
    return Column(
      children: <Widget>[
        ElevatedButton(
          child: Text('Upload Image'),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.image,
            );

            var res = result;
            if (res != null) {
              file = File(res.files.single.path as String);

              var path = "storage/emulated/0/users";
              if (await Directory(path).exists()) {
              } else {
                var directory = await Directory(path).create(recursive: true);
              }
              print('filepath: ${file.path}');
              file = await moveFile(file, path);
            } else {
              // User canceled the picker
              file = File('');
            }
            _setFilePath(file.path.toString());
          },
        ),
        Text(_filePath),
      ],
    );
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy('$newPath/profileImage.jpg');
      // await sourceFile.delete();
      return newFile;
    }
  }

  Widget _buildSubmit(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        onPressed: () async {
          // Validate returns true if the form is valid, or false otherwise.
          if (_formKey.currentState!.validate()) {
            // If the form is valid, display a snackbar. In the real world,
            // you'd often call a server or save the information in a database.
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Processing Data'),
                duration: Duration(seconds: 2)));
            User user = User.withoutidUser(
                name.text, desc.text, file.path, 0, email.text, password.text);
            int res = await sql.insertUser(user);
            print('insertUser res: $res');
            if (res == -1) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('There was an error in the register')));
            } else {
              //User successfully registered
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('loggedIn', true);
              prefs.setInt('loginId', res);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User registered successfully')));

              Navigator.pop(context);
            }
          }
        },
        child: Text('Submit'),
      ),
    );
  }
}
