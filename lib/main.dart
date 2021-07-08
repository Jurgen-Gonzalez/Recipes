import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:recetas/src/SQLite.dart';
import 'package:recetas/src/model/Recipe.dart';
import 'package:recetas/src/pages/Home.dart';
import 'package:recetas/src/pages/LoginRegister.dart';
import 'package:recetas/src/pages/RecipeForm.dart';
import 'package:recetas/src/pages/UserForm.dart';
import 'package:recetas/src/pages/UserInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  createDatabases();
  getPermissions();
  bool loggedIn = await getLoggedInPreferences();
  runApp(Main(loggedIn: loggedIn));
}

void createDatabases() async {
  SQLite sql = new SQLite();
  sql.createUser();
  sql.createRecipes();
  sql.createStep();
  sql.createInterest();
  sql.createIngredient();
  List<Recipe> recipes = await sql.searchRecipes();
  recipes.forEach((element) {
    print('Recipes: ${element.title}');
  });
}

Future<bool> getLoggedInPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.clear();
  // print('preferences removed');
  // prefs.remove('loggedIn');
  bool loggedIn = false;
  if (prefs.containsKey('loggedIn')) {
    var logged = prefs.getBool('loggedIn');
    if (logged == null) {
      return loggedIn;
    }
    loggedIn = logged;
    print('loggedIn: $loggedIn');
  }
  return loggedIn;
}

void getPermissions() async {
  var status = await Permission.storage.status;
  if (status.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    print('isdenied');
  }

// You can can also directly ask the permission about its status.
  if (await Permission.storage.isRestricted) {
    // The OS restricts access, for example because of parental controls.
    print('isRestricted');
  }

  if (await Permission.storage.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    print('isGranted');
  }

// You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();
  print(statuses[Permission.storage]);
}

class Main extends StatefulWidget {
  final loggedIn;
  const Main({Key? key, this.loggedIn}) : super(key: key);

  @override
  _Main createState() => _Main();
}

class _Main extends State<Main> {
  int _currentIndex = 0;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
        body: new IndexedStack(
          index: _currentIndex,
          children: <Widget>[
            Home(title: 'Recetas'),
            Text('placeholder'),
            RecipeForm(),
            widget.loggedIn ? UserInfo() : LoginRegister(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.purple,
            selectedItemColor: Colors.red,
            currentIndex: _currentIndex,
            onTap: (newIndex) => setState(() => {_currentIndex = newIndex}),
            items: [
              BottomNavigationBarItem(
                  icon: new Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.grid_view), label: 'Categories'),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.local_dining), label: 'My Recipes'),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.person), label: 'Profile'),
            ]),
      ),
    );
  }
}
