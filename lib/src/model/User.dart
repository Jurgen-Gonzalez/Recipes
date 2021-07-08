import 'Recipe.dart';
class User {
  int idUser;
  String name;
  String description;
  String _imagePath;
  int votes;
  String email;
  String password;

  User.empty(): this(0, '', '', '', 0, '', '');

  User(this.idUser, this.name, this.description, this._imagePath, this.votes,
      this.email, this.password);

  User.withoutidUser(String name, String description, String _imagePath, int votes,
  String email, String password): this(0, name, description, _imagePath, votes, email, password);
  //
  // User(String name, String description, String imagePath, int votes,
  // String email, String password){
  //   this.name = name;
  //   this.description = description;
  //   this._imagePath = imagePath;
  //   this.votes = votes;
  //   this.email = email;
  //   this.password = password;
  // }
  //
  // User.Full(int idUser, String name, String description, String imagePath, int votes,
  //     String email, String password){
  //   this.idUser = idUser;
  //   this.name = name;
  //   this.description = description;
  //   this._imagePath = imagePath;
  //   this.votes = votes;
  //   this.email = email;
  //   this.password = password;
  // }
  String get imagePath => _imagePath;

  set imagePath(String value) {
    _imagePath = value;
  }

// User({
  //   this.id,
  //   this.name,
  //   this.description,
  //   this.imagePath,
  //   this.votes,
  //   this.email,
  //   this.password,
  //   this.recipes,
  //   this.likedRecipes,
  // });


}
