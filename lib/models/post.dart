class Post {
  final String author;
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
      this.id});

  double percentRaised() {
    var raised = double.parse(amountRaised.contains(",")
        ? amountRaised.replaceAll(",", "")
        : amountRaised);
    var target = double.parse(targetAmount.contains(",")
        ? targetAmount.replaceAll(",", "")
        : targetAmount);
    return raised / target;
  }
}
