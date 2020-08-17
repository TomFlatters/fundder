class Template {
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
  final double aspectRatio;

  // the user can choose if a specific person or anyone can use this template
  String whoDoes;

  // each template should record who has accepted and completed the challenge,
  List acceptedBy;
  List completedBy;
  final List<dynamic> hashtags;

  // we also record whether the challenge is "active" or not
  bool active;

  Template(
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
      this.whoDoes,
      this.acceptedBy,
      this.completedBy,
      this.active,
      this.aspectRatio,
      this.hashtags});

  double percentRaised() {
    double processAmount(String s) =>
        double.parse(s.contains(",") ? s.replaceAll(",", "") : amountRaised);
    if (processAmount(amountRaised) != null &&
        processAmount(amountRaised) / processAmount(targetAmount) <= 1) {
      return processAmount(amountRaised) / processAmount(targetAmount);
    } else if (processAmount(amountRaised) != null &&
        processAmount(amountRaised) / processAmount(targetAmount) > 1) {
      return 1;
    } else {
      return 0;
    }
  }
}
