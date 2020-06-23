// This file contains functions that could be useful throughout the app


// Takes in a Firestore timestamp object and returns a formatted string.
howLongAgo(timestamp){
  var postedAt = DateTime.parse(timestamp.toDate().toString());
  var thisInstant = new DateTime.now();
  var timeElapsed = thisInstant.difference(postedAt);
  if (timeElapsed.inDays>0){
    return timeElapsed.inDays.toString() + " day(s) ago";
  }
  else if (timeElapsed.inHours>0){
    return timeElapsed.inHours.toString() + " hour(s) ago";
  }
  else if (timeElapsed.inMinutes>0){
    return timeElapsed.inMinutes.toString() + " minute(s) ago";
  }
  else if (timeElapsed.inSeconds>0){
    return timeElapsed.inSeconds.toString() + " second(s) ago";
  }
  else {
    return "Unknown date of post";
  }
}