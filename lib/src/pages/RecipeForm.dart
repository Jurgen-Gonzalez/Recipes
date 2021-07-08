import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:recetas/src/model/Ingredient.dart';
import 'dart:io';
import 'package:recetas/src/model/Recipe.dart';
import 'package:recetas/src/model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../SQLite.dart';

class RecipeForm extends StatefulWidget {
  @override
  _RecipeForm createState() => _RecipeForm();
}

class _RecipeForm extends State<RecipeForm> {
  int _counter = 0;
  SQLite sql = new SQLite();
  String _filePath = '';
  File file = File('');
  String title = '';
  String desc = '';
  String imagePath = '';
  String time = '';
  String difficulty = '';
  String category = '';
  int times = 0;
  List<Widget> ingredientsRow = [];
  Map map = Map<int, List<Ingredient>>();
  List<Ingredient> ingredients = [];

  void _setFilePath(String path) {
    setState(() {
      _filePath = path;
    });
  }

  void _setIngredients(var row) {
    setState(() {
      ingredientsRow.add(row);
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTitle(),
          _buildDescription(),
          _buildUploadImage(),
          _buildIngredients(),
          _buildSteps(),
          _buildTime(),
          _buildDifficulty(),
          _buildCategory(),
          _buildSubmit(context),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          hintText: 'Recipe title', border: OutlineInputBorder()),
      onChanged: (value) => setState(() => title = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some title';
        }
        return null;
      },
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      onChanged: (value) => setState(() => desc = value),
      decoration: InputDecoration(
          hintText: 'Description', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your description';
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

              var path = "storage/emulated/0/recipes";
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
      final newFile = await sourceFile
          .copy('$newPath/${(await sql.searchRecipes()).length}.jpg');
      // await sourceFile.delete();
      return newFile;
    }
  }

  Widget _buildTime() {
    return TextFormField(
      keyboardType: TextInputType.number,
      onChanged: (value) => setState(() => time = value),
      decoration: InputDecoration(
          hintText: 'Time it takes, ex: 30min', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the time';
        }
        return null;
      },
    );
  }

  Widget _buildDifficulty() {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          hintText: 'Difficulty from 1 to 5', border: OutlineInputBorder()),
      onChanged: (value) => setState(() => difficulty = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some difficulty';
        } else if (int.parse(value) > 5 || int.parse(value) < 1) {
          return 'The difficulty must be between 1 and 5';
        }
        return null;
      },
    );
  }

  Widget _buildCategory() {
    return TextFormField(
      onChanged: (value) => setState(() => category = value),
      decoration:
          InputDecoration(hintText: 'Category', border: OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your difficulty';
        }
        return null;
      },
    );
  }

  Widget _buildSubmit(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        child: Text('Submit'),
        onPressed: () async {
          map = ingredients.asMap();
          final isValid = _formKey.currentState!.validate();

          // Validate returns true if the form is valid, or false otherwise.
          if (isValid) {
            _formKey.currentState!.save();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Processing Data'),
                duration: Duration(seconds: 2)));

            // Check that the user is logged in and insert the new Recipe by
            // inserting it on table recipe, ingredients and steps
            SharedPreferences prefs = await SharedPreferences.getInstance();
            int res = 0;
            if (prefs.containsKey('loginId')) {
              int id = prefs.getInt('loginId')!;
              User user = await sql.searchUser(id);

              // realUser is used to get around the null safety
              var realUser = user;
              if (realUser.name != '') {
                Recipe recipe = new Recipe.withoutidRecipe(
                    realUser.idUser,
                    title,
                    desc,
                    file.path,
                    time,
                    0,
                    int.parse(difficulty),
                    category);
                res = await sql.insertRecipe(recipe);

                print('res Recipe: $res');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You should be signed in first')));
              }
            }

            if (res == 0) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('There was an error in the recipe register')));
            } else {
              // The Recipe Register was a success and we can insert to ingredient and step
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recipe registered successfully')));
              map.forEach((key, value) {
                Ingredient ing = Ingredient.withoutidIngredient(
                    res, value.quantity, value.measure, value.name);
                sql.insertIngredient(ing);
              });
            }
          }

          // _formKey.currentState!.reset();
        },
      ),
    );
  }

  Widget _buildIngredients() {
    return Column(children: [
      Row(
        children: [
          Text('Quantity'),
          Text('Measure'),
          Text('Ingredient'),
        ],
      ),
      Row(
        children: ingredientsRow,
      ),
      ElevatedButton(
        child: Text('Add Ingredient'),
        onPressed: () {
          times = times++;
          Ingredient ingredient = Ingredient.empty();
          ingredients.add(ingredient);
          var row = [
            TextFormField(
              onChanged: (value) =>
                  setState(() => ingredient.quantity = value as double),
              decoration: InputDecoration(
                  hintText: 'Qty', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Missing value';
                }
                return null;
              },
            ),
            TextFormField(
              onChanged: (value) => setState(() => ingredient.measure = value),
              decoration: InputDecoration(
                  hintText: 'Measure', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Missing value';
                }
                return null;
              },
            ),
            TextFormField(
              onChanged: (value) => setState(() => ingredient.name = value),
              decoration: InputDecoration(
                  hintText: 'Ingredient', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Missing value';
                }
                return null;
              },
            ),
          ];
          _setIngredients(row);
        },
      )
    ]);
  }

  _buildSteps() {}
}
