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
      this.whoDoes}) : super(
        author:author,
        title:title,
        charity:charity,
        amountRaised:amountRaised,
        targetAmount:targetAmount,
        subtitle:subtitle,
        likes:likes,
        comments:comments,
        timestamp:timestamp,
        imageUrl:imageUrl,
        id:id,
      );
}
