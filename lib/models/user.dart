class User {
  
  // add properties to the user model here 
  final String uid;
  final String username;
  final String email;
  final String bio;
  final int followers;
  final int following;
  final String gender;


  // construct them into the object here
  User({ this.uid, this.username, this.email, 
  this.bio, this.followers, 
  this.following, this.gender});
}