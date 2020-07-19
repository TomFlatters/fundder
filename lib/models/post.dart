// a lightweight interface between information in the database regarding Posts and the programmer.
//general thing to note is that queries are shallow:
//Remember, queries are shallow, meaning if we retrieve the documents inside
//the user collection, then the documents inside the sub-collection won't be retrieved.

class Post {
  final String author;
  final String title;
  final String charity;
  final String amountRaised;
  final String targetAmount;
  final int likes;
  final comments;
  final String subtitle;
  final timestamp;
  String imageUrl;
  String id;
  String status;
  Set<String> peopleThatLikedThis;

  Post(
      {this.author,
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
      this.peopleThatLikedThis});

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
