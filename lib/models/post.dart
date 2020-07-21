class Post {
  final String author;
  final String authorUsername;
  final String title;
  final String charity;
  final String amountRaised;
  final String targetAmount;
  final List likes;
  final comments;
  final String subtitle;
  final timestamp;
  String imageUrl;
  String id;
  String status;

  Post(
      {this.author,
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
      this.status});

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
