// a lightweight interface between information in the database regarding Posts and the programmer.
//general thing to note is that queries are shallow:
//Remember, queries are shallow, meaning if we retrieve the documents inside
//the user collection, then the documents inside the sub-collection won't be retrieved.

//WARNING: THIS IS A DEPRECATED MODEL OF POST, WITHOUT MANY OF ITS FEATURES AND SOME STALE FEATURES.
//NEEDS REFACTORING

class Post {
  final String author;
  final String authorUsername;
  final String title;
  final String charity;
  final String amountRaised;
  final String targetAmount;
  final List likes;
  final int noLikes;
  final int noComments;

  final String subtitle;
  final timestamp;
  String imageUrl;
  String id;
  String status;
  final Set<String> peopleThatLikedThis;

  Post({
    this.noComments,
    this.noLikes,
    this.author,
    this.authorUsername,
    this.title,
    this.charity,
    this.amountRaised,
    this.targetAmount,
    this.subtitle,
    this.likes,
    this.timestamp,
    this.imageUrl,
    this.id,
    this.status,
    this.peopleThatLikedThis,
  });

  double percentRaised() {
    //print("Amount raised1" + amountRaised);
    //print("Amount target1" + targetAmount);
    double processAmount(String s) =>
        double.parse(s.contains(",") ? s.replaceAll(",", "") : s);
    //print("percent Raised" +
    //(processAmount(amountRaised) / processAmount(targetAmount)).toString());
    //print("Amount raised" + processAmount(amountRaised).toString());
    //print("Amount target" + processAmount(targetAmount).toString());
    return processAmount(amountRaised) / processAmount(targetAmount);
  }
}
