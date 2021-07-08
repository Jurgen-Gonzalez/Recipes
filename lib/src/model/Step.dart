class Step {
  int idStep;
  int idRecipe;
  int number;
  String description;
  String imagePath;

  Step.empty() : this(0, 0, 0, '', '');
  Step(
    this.idStep,
    this.idRecipe,
    this.number,
    this.description,
    this.imagePath,
  );
  Step.withoutidStep(
      int idRecipe, int number, String description, String imagePath)
      : this(0, idRecipe, number, description, imagePath);

//   Step(int idRecipe, int number,String description, String imagePath){
//     this.idRecipe = idRecipe;
//     this.number = number;
//     this.description = description;
//     this.imagePath = imagePath;
// }
//
//   Step.Full(int idStep, int idRecipe, int number,String description, String imagePath){
//     this.idStep = idStep;
//     this.idRecipe = idRecipe;
//     this.number = number;
//     this.description = description;
//     this.imagePath = imagePath;
//   }
//

}
