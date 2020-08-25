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
  final double moneyRaised;
  final String targetAmount;
  final List likes;
  final int noLikes;
  final int noComments;
  final double aspectRatio;
  final List<dynamic> hashtags;

  final String subtitle;
  final timestamp;
  String imageUrl;
  String id;
  String status;
  final Set<String> peopleThatLikedThis;

  final String templateTag;
  final String charityLogo;
  final String charityId;

  Post(
      {this.noComments,
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
      // Add an optional parameter for posts to have a template tag
      this.templateTag = 'None',
      this.aspectRatio,
      this.moneyRaised,
      this.hashtags,
      this.charityLogo,
      this.charityId});

  double percentRaised() {
    double processAmount(String s) =>
        double.parse(s.contains(",") ? s.replaceAll(",", "") : s);
    //print("percent Raised" +
    //(processAmount(amountRaised) / processAmount(targetAmount)).toString());
    //print("Amount raised" + processAmount(amountRaised).toString());
    //print("Amount target" + processAmount(targetAmount).toString());
    if (moneyRaised != null && moneyRaised / processAmount(targetAmount) <= 1) {
      return moneyRaised / processAmount(targetAmount);
    } else if (moneyRaised != null &&
        moneyRaised / processAmount(targetAmount) > 1) {
      return 1;
    } else {
      return 0;
    }
  }
}
