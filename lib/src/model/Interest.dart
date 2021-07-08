class Interest {
  int idInterest;
  int idUser;
  int idRecipe;
  int owned;

  Interest.empty() : this(0, 0, 0, 0);
  Interest(this.idInterest, this.idUser, this.idRecipe, this.owned);
  Interest.withoutidInterest(int idUser, int idRecipe, int owned)
      : this(0, idUser, idRecipe, owned);

  // Interest(int idUser, int idRecipe, int owned) {
  //   this.idUser = idUser;
  //   this.idRecipe = idRecipe;
  //   this.owned = owned;
  // }
  //
  // Interest.Full(int idInterest, int idUser, int idRecipe, int owned) {
  //   this.idInterest = idInterest;
  //   this.idUser = idUser;
  //   this.idRecipe = idRecipe;
  //   this.owned = owned;
  // }

}
