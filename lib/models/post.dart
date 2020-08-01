// a lightweight interface between information in the database regarding Posts and the programmer.
//general thing to note is that queries are shallow:
//Remember, queries are shallow, meaning if we retrieve the documents inside
//the user collection, then the documents inside the sub-collection won't be retrieved.

class Post {
  final String author;
  final String authorUsername;
  final String title;
  final String charity;
  final String amountRaised;
  final String targetAmount;
  final List likes;
  int noLikes;
  final comments;
  final String subtitle;
  final timestamp;
  String imageUrl;
  String id;
  String status;
  final Set<String> peopleThatLikedThis;

  final String templateTag;

  Post(
      {this.noLikes,
      this.author,
      this.authorUsername,
      this.title,
      this.charity,
      this.amountRaised,
      this.targetAmount,
      this.subtitle,
      this.likes,
      this.comments,
      this.timestamp,
      this.imageUrl,
      this.id,
      this.status,
      this.peopleThatLikedThis,
      // Add an optional parameter for posts to have a template tag
      this.templateTag = 'None'});

  double percentRaised() {
    double processAmount(String s) =>
        double.parse(s.contains(",") ? s.replaceAll(",", "") : s);
    return processAmount(amountRaised) / processAmount(targetAmount);
  }
}
