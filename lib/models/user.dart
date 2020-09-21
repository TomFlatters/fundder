class User {
  // add properties to the user model here
  final String uid;
  final String username;
  final String email;
  final String bio;
  final int followers;
  final int following;
  final String gender;
  final String name;
  final String profilePic;
  final bool seenTutorial;
  final bool dpSetterPrompted;
  final bool verified;
  final bool profileTutorialSeen;
  final bool fundTutorialSeen;
  final bool doTutorialSeen;
  final bool doneTutorialSeen;
  final double amountDonated;
  final List<dynamic> likes;

  // construct them into the object here
  User(
      {this.uid,
      this.username,
      this.email,
      this.bio,
      this.followers,
      this.following,
      this.gender,
      this.name,
      this.profilePic,
      this.seenTutorial,
      this.dpSetterPrompted,
      this.verified,
      this.profileTutorialSeen,
      this.fundTutorialSeen,
      this.doTutorialSeen,
      this.doneTutorialSeen,
      this.amountDonated,
      this.likes});
}
