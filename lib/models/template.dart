import 'package:fundder/models/post.dart';

class Template extends Post {
    String whoDoes;

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
      this.whoDoes});
}
