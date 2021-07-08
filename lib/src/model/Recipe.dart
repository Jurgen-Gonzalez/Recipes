class Recipe {
  int idRecipe;
  int idUser;
  String title;
  String description;
  String imagePath;
  String time;
  int votes = 0;
  int difficulty;
  String category;

  Recipe.empty() : this(0, 0, '', '', '', '', 0, 0, '');

  Recipe(this.idRecipe, this.idUser, this.title, this.description,
      this.imagePath, this.time, this.votes, this.difficulty, this.category);

  Recipe.withoutidRecipe(int idUser, String title, String description,
      String imagePath, String time, int votes, int difficulty, String category)
      : this(0, idUser, title, description, imagePath, time, votes, difficulty,
            category);

  // Recipe( int idUser, String title, String description, String imagePath,
  //  String time, int votes, int difficulty,
  // String category ){
  //   this.idUser = idUser;
  //   this.title = title;
  //   this.description = description;
  //   this.imagePath = imagePath;
  //   this.time = time;
  //   this.votes = votes;
  //   this.difficulty = difficulty;
  //   this.category = category;
  // }
  //
  // Recipe.Full(int idRecipe, int idUser, String title, String description, String imagePath,
  //     String time, int votes, int difficulty,
  //     String category ){
  //   this.idRecipe = idRecipe;
  //   this.idUser = idUser;
  //   this.title = title;
  //   this.description = description;
  //   this.imagePath = imagePath;
  //   this.time = time;
  //   this.votes = votes;
  //   this.difficulty = difficulty;
  //   this.category = category;
  // }

}
