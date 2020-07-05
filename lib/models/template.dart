import 'package:fundder/models/post.dart';

class Template extends Post {
  // the user can choose if a specific person or anyone can use this template
  String whoDoes;

  // each template should record who has accepted and completed the challenge,
  List<String> acceptedBy;
  List<String> completedBy;

  // we also record whether the challenge is "active" or not
  bool active;

  Template(
      {author,
      title,
      charity,
      amountRaised,
      targetAmount,
      subtitle,
      likes,
      comments,
      timestamp,
      imageUrl,
      id,
      this.whoDoes,
      this.acceptedBy,
      this.completedBy,
      this.active})
      : super(
          author: author,
          title: title,
          charity: charity,
          amountRaised: amountRaised,
          targetAmount: targetAmount,
          subtitle: subtitle,
          likes: likes,
          comments: comments,
          timestamp: timestamp,
          imageUrl: imageUrl,
          id: id,
        );
}
