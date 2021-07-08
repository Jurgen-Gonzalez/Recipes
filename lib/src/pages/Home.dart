import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recetas/src/model/Recipe.dart';

import '../SQLite.dart';
import 'RecipeInfo.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({Key? key, required this.title}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  int _counter = 0;
  SQLite sql = new SQLite();
  int _vote = 0;

  void _likeDislike() {
    setState(() {
      if (_vote == 1) {
        _vote = 0;
      } else if (_vote == 0) {
        _vote = 1;
      }
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    sql.openRecipe();
    return Container(
      margin: const EdgeInsets.all(3.0),
      padding: const EdgeInsets.only(bottom: 8.0),
      // child: Column(children: <Widget>[
      //   Text('Hottest Recipes',
      //       style: TextStyle(fontSize: 22, color: Colors.red)),
      //   Container(
      //     margin: const EdgeInsets.all(5.0),
      child: _buildListViewRecipes(context),
      //   )
      // ])
    );
  }

  Future<List<Recipe>> _sqliteCall() async {
    List<Recipe> list = await sql.searchRecipes();
    list.forEach((element) {
      print('Recipes id: ${element.idRecipe}, desc:  ${element.description}');
    });
    return list;
  }

  Widget _buildListViewRecipes(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
        future: _sqliteCall(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var recipes = snapshot.data!;
            return SingleChildScrollView(
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(children: <Widget>[
                            _buildPhoto(recipes[index]),
                            Text(recipes[index].title,
                                style: TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'Raleway',
                                    color: Colors.black)),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    recipes[index].votes.toString(),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
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
                                ])
                          ]));
                    }));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _buildPhoto(Recipe recipe) {
    return Expanded(
      child: OutlinedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RecipeInfo(recipe: recipe)));
          },
          child: Container(
            width: 700,
            height: 350,
            // padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                image: DecorationImage(
              image: FileImage(new File(recipe.imagePath)),
              alignment: Alignment.topRight,
            )),
          )),
    );
  }
}
