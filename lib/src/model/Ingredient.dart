class Ingredient {
  int idIngredient;
  int idRecipe;
  double quantity;
  String measure;
  String name;

  Ingredient.empty() : this(0, 0, 0, '', '');

  Ingredient(
      this.idIngredient, this.idRecipe, this.quantity, this.measure, this.name);

  Ingredient.withoutidIngredient(idRecipe, quantity, measure, name)
      : this(0, idRecipe, quantity, measure, name);
}
