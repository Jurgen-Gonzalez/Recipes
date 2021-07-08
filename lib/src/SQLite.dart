import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'model/Ingredient.dart';
import 'model/Interest.dart';
import 'model/Recipe.dart';
import 'model/Step.dart';
import 'model/User.dart';

class SQLite {
  void createRecipes() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'recipe_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE recipe(idRecipe INTEGER PRIMARY KEY AUTOINCREMENT, idUser INTEGER'
          ', title TEXT, description TEXT, imagePath TEXT, time TEXT'
          ', votes INTEGER, difficulty INTEGER, category TEXT'
          ', FOREIGN KEY(idUser) REFERENCES user(idUser))',
        );
      },
      version: 1,
    );
  }

  void createUser() async {
    String path = await getDatabasesPath();
    // await deleteDatabase(path);
    // print('database deleted');
    Future<Database> database = openDatabase(
      join(path, 'user_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE user(idUser INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT'
          ', description TEXT, imagePath TEXT, votes INTEGER, email TEXT'
          ', password TEXT)',
        );
      },
      version: 1,
    );
  }

  void createStep() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'step_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE step(idStep INTEGER PRIMARY KEY AUTOINCREMENT, idRecipe INTEGER'
          ', number INTEGER, description TEXT, imagePath TEXT'
          ', FOREIGN KEY(idRecipe) REFERENCES recipe(idRecipe))',
        );
      },
      version: 1,
    );
  }

  void createInterest() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'interest_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE interest(idInterest INTEGER PRIMARY KEY AUTOINCREMENT, idUser INTEGER'
          ', idRecipe INTEGER, owned INTEGER'
          ', FOREIGN KEY(idRecipe) REFERENCES recipe(idRecipe)'
          ', FOREIGN KEY(idUser) REFERENCES user(idUser))',
        );
      },
      version: 1,
    );
  }

  void createIngredient() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'ingredient_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE ingredient(idIngredient INTEGER PRIMARY KEY AUTOINCREMENT, idRecipe INTEGER'
          ', quantity REAL, measure TEXT, name TEXT'
          ', FOREIGN KEY(idRecipe) REFERENCES recipe(idRecipe))',
        );
      },
      version: 1,
    );
  }

  Future<Database> openRecipe() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'recipe_database.db'),
      version: 1,
    );

    return database;
  }

  Future<int> insertRecipe(Recipe dog) async {
    final db = await openRecipe();
    try {
      return await db.rawInsert(
        'insert into recipe ' //(idUser, title, description, imagePath, time, votes, difficulty, category) '
        'values (NULL, ${dog.idUser},"${dog.title}","${dog.description}",'
        '"${dog.imagePath}",${dog.time}, ${dog.votes},${dog.difficulty},"${dog.category}")',
      );
    } on Error catch (error, stacktrace) {
      return 0;
    }
  }

  Future<Recipe?> searchRecipe(int id) async {
    final db = await openRecipe();
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from recipe where idRecipe = ' + id.toString(),
      );
      list.forEach((element) {
        print(element.toString());
      });
      return Recipe.withoutidRecipe(
        list[0]["idUser"],
        list[0]["title"],
        list[0]["description"],
        list[0]["imagePath"],
        list[0]["time"],
        list[0]["votes"],
        list[0]["difficulty"],
        list[0]["category"],
      );
    } on Error catch (error, stacktrace) {
      return null;
    }
  }

  Future<Recipe?> searchRecipesFromUser(int id) async {
    final db = await openRecipe();
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from recipe where idUser = ' + id.toString(),
      );
      list.forEach((element) {
        print(element.toString());
      });
      return Recipe.withoutidRecipe(
        list[0]["idUser"],
        list[0]["title"],
        list[0]["description"],
        list[0]["imagePath"],
        list[0]["time"],
        list[0]["votes"],
        list[0]["difficulty"],
        list[0]["category"],
      );
    } on Error catch (error, stacktrace) {
      return null;
    }
  }

  Future<List<Recipe>> searchRecipes() async {
    final db = await openRecipe();
    List<Recipe> recipes = [];
    try {
      List<Map<String, dynamic>> list =
          await db.rawQuery('select * from recipe');
      Recipe recipe;
      list.forEach((element) {
        recipe = new Recipe(
          element["idRecipe"],
          element["idUser"],
          element["title"],
          element["description"],
          element["imagePath"],
          element["time"],
          element["votes"],
          element["difficulty"],
          element["category"],
        );
        recipes.add(recipe);
      });
      return recipes;
    } on Error catch (error, stacktrace) {
      return [];
    }
  }

  Future<int> updateRecipe(Recipe dog) async {
    final db = await openRecipe();
    return await db.rawUpdate('update recipe set idUser = ${dog.idUser}, '
        'description = "${dog.description}", title = "${dog.title}", '
        'imagePath = "${dog.imagePath}", time = "${dog.time}", '
        'difficulty = ${dog.difficulty}, category = "${dog.category}", '
        'where idRecipe = ${dog.idRecipe}');
  }

  Future<int> deleteRecipe(int id) async {
    final db = await openRecipe();
    return await db.delete(
      'recipe',
      where: 'idRecipe = ?',
      whereArgs: [id],
    ).catchError((error) {
      return 0;
    });
  }

  Future<Database> openUser() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'user_database.db'),
      version: 1,
    );

    return database;
  }

  Future<int> insertUser(User dog) async {
    final db = await openUser();
    try {
      return await db.rawInsert(
        'insert into user ' //( name, description, imagePath, votes, email, password) '
        'values (NULL, "${dog.name}","${dog.description}",'
        '"${dog.imagePath}", ${dog.votes},"${dog.email}","${dog.password}")',
      );
    } on Error catch (error, stacktrace) {
      return -1;
    }
  }

  Future<User> searchUser(int id) async {
    final db = await openUser();
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from user where idUser = ' + id.toString(),
      );
      list.forEach((element) {
        print(element.toString());
      });
      return User(
        list[0]["idUser"],
        list[0]["name"],
        list[0]["description"],
        list[0]["imagePath"],
        list[0]["votes"],
        list[0]["email"],
        list[0]["password"],
      );
    } on Error catch (error, stacktrace) {
      return User.empty();
    }
  }

  Future<int> searchUserByEmail(String email, String password) async {
    final db = await openUser();
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from user where email = "$email" AND password = "$password"',
      );
      list.forEach((element) {
        print(element.toString());
      });
      return list[0]['idUser'];
    } on Error catch (error, stacktrace) {
      return -1;
    }
  }

  Future<User> searchUsers() async {
    final db = await openUser();
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from user',
      );
      list.forEach((element) {
        print(element.toString());
      });
      return User(
        list[0]["idUser"],
        list[0]["name"],
        list[0]["description"],
        list[0]["imagePath"],
        list[0]["votes"],
        list[0]["email"],
        list[0]["password"],
      );
    } on Error catch (error, stacktrace) {
      return User.empty();
    }
  }

  Future<int> updateUser(User dog) async {
    final db = await openUser();
    return await db.rawUpdate('update user set '
        'description = "${dog.description}", name = "${dog.name}", '
        'imagePath = "${dog.imagePath}", votes = ${dog.votes}, '
        'email = "${dog.email}", password = "${dog.password}", '
        'where idUser = ${dog.idUser}');
  }

  Future<int> deleteUser(int id) async {
    final db = await openUser();
    return await db.delete(
      'user',
      where: 'idUser = ?',
      whereArgs: [id],
    ).catchError((error) {
      return 0;
    });
  }

  Future<Database> openStep() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'step_database.db'),
      version: 1,
    );

    return database;
  }

  Future<int> insertStep(Step dog) async {
    final db = await openStep();
    try {
      return await db.rawInsert(
        'insert into step( idRecipe, number, description, imagePath) '
        'values (${dog.idRecipe},${dog.number},'
        '"${dog.description}", "${dog.imagePath}")',
      );
    } on Error catch (error, stacktrace) {
      return 0;
    }
  }

  Future<List<Step>?> searchStep(int id) async {
    final db = await openStep();
    List<Step> steps = [];
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from step where idStep = ' + id.toString(),
      );
      Step step;
      list.forEach((element) {
        step = new Step.withoutidStep(element["idRecipe"], element["number"],
            element["description"], element["imagePath"]);
        steps.add(step);
      });
      return steps;
    } on Error catch (error, stacktrace) {
      return null;
    }
  }

  Future<List<Step>?> searchSteps(int id) async {
    final db = await openStep();
    List<Step> steps = [];
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from step where idRecipe = ' + id.toString(),
      );
      Step step;
      list.forEach((element) {
        step = new Step.withoutidStep(element["idRecipe"], element["number"],
            element["description"], element["imagePath"]);
        steps.add(step);
      });
      return steps;
    } on Error catch (error, stacktrace) {
      return null;
    }
  }

  Future<int> updateStep(Step dog) async {
    final db = await openStep();
    return await db.rawUpdate('update step set '
        'number = ${dog.number}, description = "${dog.description}", '
        'imagePath = "${dog.imagePath}", '
        'where idStep = ${dog.idStep}');
  }

  Future<int> deleteStep(int id) async {
    final db = await openStep();
    return await db.delete(
      'step',
      where: 'idStep = ?',
      whereArgs: [id],
    ).catchError((error) {
      return 0;
    });
  }

  Future<Database> openInterest() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'interest_database.db'),
      version: 1,
    );

    return database;
  }

  Future<int> insertInterest(Interest dog) async {
    final db = await openInterest();
    try {
      return await db.rawInsert(
        'insert into interest( idUser, idRecipe, owned) '
        'values (${dog.idUser},${dog.idRecipe},'
        '${dog.owned})',
      );
    } on Error catch (error, stacktrace) {
      return 0;
    }
  }

  Future<List<Interest>> searchInterest(int id) async {
    final db = await openInterest();
    List<Interest> interests = [];
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from interest where idInterest = ' + id.toString(),
      );
      Interest interest;
      list.forEach((element) {
        interest = new Interest.withoutidInterest(
            element["idUser"], element["idRecipe"], element["owned"]);
        interests.add(interest);
      });
      return interests;
    } on Error catch (error, stacktrace) {
      return interests;
    }
  }

  Future<List<Interest>> searchInterests(int id) async {
    final db = await openInterest();
    List<Interest> interests = [];
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from interest where idUser = ' + id.toString(),
      );
      Interest interest;
      list.forEach((element) {
        interest = new Interest.withoutidInterest(
            element["idRecipe"], element["number"], element["owned"]);
        interests.add(interest);
      });
      return interests;
    } on Error catch (error, stacktrace) {
      return interests;
    }
  }

  Future<int> updateInterest(Interest dog) async {
    final db = await openInterest();
    return await db.rawUpdate('update interest set '
        'idUser = ${dog.idUser}, idRecipe = "${dog.idRecipe}", '
        'owned = "${dog.owned}", '
        'where idInterest = ${dog.idInterest}');
  }

  Future<int> deleteInterest(int id) async {
    final db = await openInterest();
    return await db.delete(
      'interest',
      where: 'idInterest = ?',
      whereArgs: [id],
    ).catchError((error) {
      return 0;
    });
  }

  Future<Database> openIngredient() async {
    Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'ingredient_database.db'),
      version: 1,
    );

    return database;
  }

  Future<int> insertIngredient(Ingredient dog) async {
    final db = await openIngredient();
    try {
      return await db.rawInsert(
        'insert into ingredient '
        'values (NULL, ${dog.idRecipe},${dog.quantity},"${dog.measure}",'
        '"${dog.name}")',
      );
    } on Error catch (error, stacktrace) {
      return 0;
    }
  }

  Future<Ingredient?> searchIngredient(int id) async {
    final db = await openIngredient();
    try {
      List<Map<String, dynamic>> list = await db.rawQuery(
        'select * from ingredient where idIngredient = ' + id.toString(),
      );
      list.forEach((element) {
        print(element.toString());
      });
      return Ingredient(
        list[0]["idIngredient"],
        list[0]["idRecipe"],
        list[0]["quantity"],
        list[0]["measure"],
        list[0]["name"],
      );
    } on Error catch (error, stacktrace) {
      return null;
    }
  }

  Future<List<Ingredient>> searchIngredientsFromRecipe(int id) async {
    final db = await openIngredient();
    List<Ingredient> ingredients = [];
    try {
      List<Map<String, dynamic>> list =
          await db.rawQuery('select * from ingredient where idRecipe = ' + id.toString());
      Ingredient ingredient;
      list.forEach((element) {
        ingredient = new Ingredient(
          element["idIngredient"],
          element["idRecipe"],
          element["quantity"],
          element["measure"],
          element["name"],
        );
        ingredients.add(ingredient);
      });
      return ingredients;
    } on Error catch (error, stacktrace) {
      return ingredients;
    }
  }

  Future<List<Ingredient>> searchIngredients() async {
    final db = await openIngredient();
    List<Ingredient> ingredients = [];
    try {
      List<Map<String, dynamic>> list =
          await db.rawQuery('select * from ingredient');
      Ingredient ingredient;
      list.forEach((element) {
        ingredient = new Ingredient(
          element["idIngredient"],
          element["idRecipe"],
          element["quantity"],
          element["measure"],
          element["name"],
        );
        ingredients.add(ingredient);
      });
      return ingredients;
    } on Error catch (error, stacktrace) {
      return [];
    }
  }

  Future<int> updateIngredient(Ingredient dog) async {
    final db = await openIngredient();
    return await db.rawUpdate('update ingredient set name = ${dog.name}, '
        'quantity = "${dog.quantity}", measure = "${dog.measure}", '
        'where idIngredient = ${dog.idIngredient}');
  }

  Future<int> deleteIngredient(int id) async {
    final db = await openIngredient();
    return await db.delete(
      'ingredient',
      where: 'idIngredient = ?',
      whereArgs: [id],
    ).catchError((error) {
      return 0;
    });
  }
}
