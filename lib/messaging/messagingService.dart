import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingService {
  final uid;
  MessagingService(this.uid);
  static CollectionReference chatsCollection =
      Firestore.instance.collection('chats');

  /**Given uids of two people chatting, return their doc reference for the chats
   * collection
   */

  static String getChatRoomId(String chatee1, String chatee2) {
    //sort the uids alphabetically in dictionary ordering and join
    //them with an underscore
    print("Generating chat ids");
    List<String> uids = [chatee1, chatee2];

    print("raw uid list: " + uids.toString());
    uids.sort();
    print("sorted uids: " + uids.toString());
    String chatId = uids.join('_');
    print("this is the generated chatId: " + chatId);
    return chatId;
  }

  /**given a chatId, get its messages. If the chat doesn't exist, then it will.
   * Mark this user as in the chatroom as well.
   */

  static Stream<QuerySnapshot> getMessages(String chatId) => chatsCollection
      .document(chatId)
      .collection('messages')
      .orderBy("when", descending: true)
      .snapshots();

  void sendText(String txt, String chatId) {
    var messages = chatsCollection.document(chatId).collection('messages');
    var timestamp = Timestamp.fromDate(DateTime.now().toUtc());
    messages.add({
      "from": this.uid,
      "when": timestamp,
      "msg": txt,
    });
    chatsCollection.document(chatId).setData({
      'latestMessage': {'txt': txt, 'timeStamp': timestamp}
    }, merge: true);
  }

  /**Get chats for the user for whom this messaging service was initialised */
  Stream<QuerySnapshot> getChats() => chatsCollection
      .where("chatMembers", arrayContains: uid)
      .orderBy('latestMessage.timeStamp', descending: true)
      .snapshots();

  /**register leaving a chatroom on the database. If no messages have been sent
   * on the chat, the database will not be modified.
   */
  void leaveChat(String chatId) async {
    var chat = await chatsCollection.document(chatId).get();
    if (chat.exists) {
      //this chat exists and so register the user leaving the chat

      var timestamp = Timestamp.fromDate(DateTime.now().toUtc());
      chatsCollection.document(chatId).setData({
        'leftChat': {uid: timestamp}
      }, merge: true);
    } else {
      print("Chat doesn't exist");
    }
  }

  void chatSeen() {
    Firestore.instance
        .collection('userChatStatus')
        .document(uid)
        .setData({'chatNeedsAttention': false}, merge: true);
  }

//not really used
  void chatNeedsAttention() {
    Firestore.instance
        .collection('userChatStatus')
        .document(uid)
        .setData({'chatNeedsAttention': true}, merge: true);
  }
}
