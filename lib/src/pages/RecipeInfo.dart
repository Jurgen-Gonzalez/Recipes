import 'package:flutter/material.dart';
import 'package:recetas/src/model/Ingredient.dart';
import 'package:recetas/src/model/Recipe.dart';
import 'dart:io';

import '../SQLite.dart';

class RecipeInfo extends StatefulWidget {
  final recipe;
  const RecipeInfo({Key? key, required this.recipe}) : super(key: key);
  @override
  _RecipeInfo createState() => _RecipeInfo();
}

class _RecipeInfo extends State<RecipeInfo> {
  String _filePath = '';
  SQLite sql = new SQLite();
  Recipe recipe = Recipe.empty();
  List ingredients = [];
  File file = File('');
  int _vote = 0;

  void _setFilePath(String path) {
    setState(() {
      _filePath = path;
    });
  }

  void _likeDislike() {
    setState(() {
      if (_vote == 1) {
        _vote = 0;
      } else if (_vote == 0) {
        _vote = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    recipe = widget.recipe;
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
            body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(children: <Widget>[
                        _buildPhoto(recipe.imagePath),
                        _buildTitle(),
                        _buildDescription(),
                        _buildCategoryTime(),
                        Text('Difficulty:', style: TextStyle(fontSize: 15)),
                        _buildStars(context),
                        _buildVotes(),
                        _buildIngredients(recipe.idRecipe),
                        _buildSteps(recipe.idRecipe),
                      ]))
                ]))));
  }

  Widget _buildStars(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) => buildStar(context, index)),
    );
  }

  Widget _buildPhoto(String imagePath) {
    return Row(children: <Widget>[
      Expanded(
          child: Container(
        width: 700,
        height: 350,
        // padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            image: DecorationImage(
          image: FileImage(new File(imagePath)),
          alignment: Alignment.topRight,
        )),
      ))
    ]);
  }

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= recipe.difficulty) {
      icon = new Icon(
        Icons.star_border,
        color: Colors.grey,
      );
      // }
      // else if (index > recipe.difficulty - 1 && index < recipe.difficulty) {
      //   icon = new Icon(
      //     Icons.star_half,
      //     color: color ?? Theme.of(context).primaryColor,
      //   );
    } else {
      icon = new Icon(
        Icons.star,
        color: Colors.yellow,
      );
    }
    return InkResponse(
      child: icon,
    );
  }

  Widget _buildVotes() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      Text(
        recipe.votes.toString(),
        style: TextStyle(fontSize: 16, color: Colors.grey),
        textAlign: TextAlign.right,
      ),
      GestureDetector(
        onTap: _likeDislike,
        child: Container(
          height: 56,
          width: 56,
          child: _vote == 1
              ? Icon(
                  Icons.favorite,
                  color: Colors.purple,
                )
              : Icon(Icons.favorite_border),
        ),
      )
    ]);
  }

  Widget _buildTitle() {
    return Text(
      recipe.title,
      style: TextStyle(fontSize: 25, color: Colors.black),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text('"${recipe.description}"',
        style: TextStyle(fontSize: 19, color: Colors.grey));
  }

  Widget _buildCategoryTime() {
    return Row(
      children: [
        Text('Plate: ${recipe.category}', style: TextStyle(fontSize: 25)),
        Spacer(),
        Text('Time: ${recipe.time} min',
            style: TextStyle(fontSize: 25, color: Colors.red)),
      ],
    );
  }

  Future<void> getIngredientsRecipe(int id) async {
    ingredients = await sql.searchIngredientsFromRecipe(id);
  }

  Widget _buildIngredients(int id) {
    getIngredientsRecipe(id);
    return ListView.builder(
        // gridDelegate:
        //     SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: ingredients.length,
        itemBuilder: (BuildContext ctx, index) {
          return Row(
            children: [
              Text(ingredients[index].quantity),
              Text(ingredients[index].measure),
              Text(ingredients[index].name),
            ],
          );
        });
  }

  _buildSteps(int id) {}
}
