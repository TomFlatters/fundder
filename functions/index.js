const functions = require('firebase-functions');
const https = require('https');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

exports.onLike = functions.firestore
    .document('/posts/{postId}/whoLiked/{userId}')
    .onCreate(async (snapshot, context) =>
    {
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const docLiker = await userRef.get();
    const payload =
    {
        notification: { 
            title: 'Like',
            body: `${docLiker.data()['username']} liked your post`, 
        },
    };

    const postId = context.params.postId;
    const doc = await admin.firestore().doc(`posts/${postId}`).get();

    console.log("doc " + doc.data());

    const author = doc.data()['author'];

    console.log("author " + author);

    const postOwner = await admin.firestore().doc(`users/${author}`).get();

    console.log("owner " + postOwner.data());

    const data = {
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        category: 'like',
        docLiker: userId,
        docLikerUsername: docLiker.data()['username'],
        postId: postId,
        seen: false
    };
      
      // Add a new document in collection "cities" with ID 'LA'
    const res = await admin.firestore().collection(`users/${author}/activity`).add(data);

    console.log('Added document with ID: ', res.id);

    const tokens = postOwner.data()['fcm'];

    if (tokens.length > 0) {
    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    await cleanupTokens(response, tokens, author);
    console.log('Notifications have been sent and tokens cleaned up.');
    }
});

exports.onComment = functions.firestore
    .document('/posts/{postId}/comments/{docId}')
    .onCreate(async (snapshot, context) =>
    {
    console.log('snapshot author uid: ' + snapshot.data()['uid']);

    const userId = snapshot.data()['uid'];
    const userRef = admin.firestore().doc(`users/${userId}`);
    const payload =
    {
        notification: { 
            title: 'Comment',
            body: `${snapshot.data()['username']} commented on your post - ${snapshot.data()['text']}`, 
        },
    };

    const postId = context.params.postId;
    const doc = await admin.firestore().doc(`posts/${postId}`).get();

    console.log("doc " + doc.data());

    const author = doc.data()['author'];

    console.log("author " + author);

    const postOwner = await admin.firestore().doc(`users/${author}`).get();

    console.log("owner " + postOwner.data());

    const data = {
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        category: 'comment',
        text: snapshot.data()['text'],
        docLiker: userId,
        docLikerUsername: snapshot.data()['username'],
        postId: postId,
        seen: false
    };
      
      // Add a new document in collection "cities" with ID 'LA'
    const res = await admin.firestore().collection(`users/${author}/activity`).add(data);

    console.log('Added document with ID: ', res.id);

    const tokens = postOwner.data()['fcm'];

    if (tokens.length > 0) {
    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    await cleanupTokens(response, tokens, postOwner.id);
    console.log('Notifications have been sent and tokens cleaned up.');
    }
});

exports.onDonate = functions.firestore
    .document('/posts/{postId}/whoDonated/{userId}')
    .onCreate(async (snapshot, context) =>
    {
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const docDonor = await userRef.get();
    const payload =
    {
        notification: { 
            title: 'Donation',
            body: `${docDonor.data()['username']} donated to your challenge`, 
        },
    };

    const postId = context.params.postId;
    const doc = await admin.firestore().doc(`posts/${postId}`).get();

    console.log("doc " + doc.data());

    const author = doc.data()['author'];

    console.log("author " + author);

    const postOwner = await admin.firestore().doc(`users/${author}`).get();

    console.log("owner " + postOwner.data());

    const data = {
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        category: 'donate',
        docLiker: userId,
        docLikerUsername: docDonor.data()['username'],
        postId: postId,
        seen: false
    };
      
      // Add a new document in collection "cities" with ID 'LA'
    const res = await admin.firestore().collection(`users/${author}/activity`).add(data);

    console.log('Added document with ID: ', res.id);

    const tokens = postOwner.data()['fcm'];

    if (tokens.length > 0) {
    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    await cleanupTokens(response, tokens, postOwner.id);
    console.log('Notifications have been sent and tokens cleaned up.');
    }
});

exports.postDone = functions.firestore
    .document('/posts/{postId}')
    .onUpdate(async (change, context) => {
      // Get an object representing the document
      // e.g. {'name': 'Marie', 'age': 66}
      const newValue = change.after.data();

      // ...or the previous value before this update
      const previousValue = change.before.data();
      console.log('new value: ' + newValue);
      const postId = context.params.postId;

      // access a particular field as you would any JS property
      if(newValue["status"] === 'done' && previousValue["status"] === 'fund')
      {
        
        // first send a notification to all those that liked a post
        const whoLikedSnapshot = await admin.firestore().collection(`posts/${postId}/whoLiked`).get();
        const whoLikedDoc = whoLikedSnapshot.docs.map(doc => doc);

        console.log(whoLikedDoc);

        var tokens = [];

        

        
        /* eslint-disable no-await-in-loop */
        for(var i=0; i<whoLikedDoc.length; i++){
            console.log(whoLikedDoc[i]);
            const doc = whoLikedDoc[i];
            console.log(doc.id);

            if(doc.data()[doc.id] === true){
              const data = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                category: 'post completed',
                docLiker: newValue['author'],
                docLikerUsername: newValue['authorUsername'],
                postId: postId,
                seen: false
            };
            const postOwner = await admin.firestore().doc(`users/${doc.id}`).get();
            const res = await admin.firestore().collection(`users/${doc.id}/activity`).add(data);
            console.log('Added document with ID: ', res.id);
              if (postOwner.data()['fcm'] !== null) {
                tokens = tokens.concat(postOwner.data()['fcm']);
              }
            }
        }

        console.log(tokens);

        const payload =
          {
              notification: { 
                  title: 'Post completed',
                  body: `${newValue['authorUsername']} completed a post that you like`, 
              },
          };

        if (tokens.length > 0) {
            // Send notifications to all tokens.
            const response = await admin.messaging().sendToDevice(tokens, payload);
            //await cleanupTokens(response, tokens);
            console.log('Notifications have been sent and tokens cleaned up.');
            }

        // then send a notification to all those that donated to a post
        const whoDonatedSnapshot = await admin.firestore().collection(`posts/${postId}/whoDonated`).get();
        const whoDonatedDoc = whoDonatedSnapshot.docs.map(doc => doc);

        console.log(whoDonatedDoc);

        tokens = [];

        /* eslint-disable no-await-in-loop */
        for(var a=0; a<whoDonatedDoc.length; a++){
            console.log(whoDonatedDoc[a]);
            const doc = whoDonatedDoc[a];
            console.log(doc.id);

            if(doc.data()[doc.id] === true){
              const data = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                category: 'post donated to completed',
                docLiker: newValue['author'],
                docLikerUsername: newValue['authorUsername'],
                postId: postId,
                seen: false
            };
            const postOwner = await admin.firestore().doc(`users/${doc.id}`).get();
            const res = await admin.firestore().collection(`users/${doc.id}/activity`).add(data);
            console.log('Added document with ID: ', res.id);
              if (postOwner.data()['fcm'] !== null) {
                tokens = tokens.concat(postOwner.data()['fcm']);
              }
            }
        }

        console.log(tokens);

        const donationPayload =
          {
              notification: { 
                  title: 'Post completed',
                  body: `${newValue['authorUsername']} completed a post that you have donated to`, 
              },
          };

        if (tokens.length > 0) {
            // Send notifications to all tokens.
            const response = await admin.messaging().sendToDevice(tokens, donationPayload);
            //await cleanupTokens(response, tokens);
            console.log('Notifications have been sent and tokens cleaned up.');
            }
        
      }

      // perform desired operations ...
    });

    exports.postCreated = functions.firestore
    .document('/posts/{postId}')
    .onCreate(async (snapshot, context) => {

      const postId = context.params.postId;
        // currently if no template, then this is done on phone. Need to move this in future
        if(snapshot.data()['templateTag'] !== 'None') {
          const hashtags = snapshot.data()['hashtags'];
          var batch = admin.firestore().batch();
          for (var ind = 0; ind < hashtags.length; ind++) {
            batch.set(
              admin.firestore().collection('hashtags').doc(hashtags[ind]),
                {'count': admin.firestore.FieldValue.increment(1)},
                {merge: true});
            batch.set(
              admin.firestore()
                    .collection('hashtags')
                    .doc(hashtags[ind])
                    .collection('posts')
                    .doc(snapshot.id),
                {postId: true},
                {merge: true});
          }
          batch.commit();
        }
        

        var tokens = [];
        // first find the post owner followers
        const postOwnerFollowers = await admin.firestore().collection(`users/${snapshot.data()['author']}/myFollowers`).get();
        const postOwnerFollowersDoc = postOwnerFollowers.docs.map(doc => doc);

        
        /* eslint-disable no-await-in-loop */
        for(var i=0; i<postOwnerFollowersDoc.length; i++){
            console.log(postOwnerFollowersDoc[i]);
            const doc = postOwnerFollowersDoc[i];
            console.log(doc.id);

            if(doc.data()['following'] === true){
              const data = {
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                category: 'new post from following',
                docLiker: snapshot.data()['author'],
                docLikerUsername: snapshot.data()['authorUsername'],
                postId: postId,
                seen: false
            };

            const postOwner = await admin.firestore().doc(`users/${doc.id}`).get();
            const res = await admin.firestore().collection(`users/${doc.id}/activity`).add(data);
            console.log('Added document with ID: ', res.id);
              if (postOwner.data()['fcm'] !== null) {
                tokens = tokens.concat(postOwner.data()['fcm']);
              }
            }
        }

        console.log(tokens);

        const payload =
          {
              notification: { 
                  title: 'Post added',
                  body: `${snapshot.data()['authorUsername']}, who you follow, has added a new post`, 
              },
          };

        if (tokens.length > 0) {
            // Send notifications to all tokens.
            const response = await admin.messaging().sendToDevice(tokens, payload);
            //await cleanupTokens(response, tokens);
            console.log('Notifications have been sent and tokens cleaned up.');
            }
      // perform desired operations ...
    });

    exports.followerGained = functions.firestore
    .document('/users/{userId}/myFollowers/{followerId}')
    .onCreate(async (snapshot, context) => {

      const userId = context.params.userId;
      const user = await admin.firestore().doc(`users/${userId}`).get();
        
      const followerId = context.params.followerId;
      const follower = await admin.firestore().doc(`users/${followerId}`).get();

      var tokens = [];
      const data = {
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          category: 'new follower',
          docLiker: followerId,
          docLikerUsername: follower.data()['username'],
          postId: followerId,
          seen: false
      };

      const res = await admin.firestore().collection(`users/${userId}/activity`).add(data);
      console.log('Added document with ID: ', res.id);
      if (user.data()['fcm'] !== null) {
        tokens = tokens.concat(user.data()['fcm']);
      }


      console.log(tokens);

      const payload =
        {
            notification: { 
                title: 'New follower',
                body: `${follower.data()['username']} has started following you`, 
            },
        };

        console.log(`${follower.data()['username']} has started following you`);
        console.log(payload);

        if (tokens.length > 0) {
            // Send notifications to all tokens.
            const response = await admin.messaging().sendToDevice(tokens, payload);
            await cleanupTokens(response, tokens, user.id);
            console.log('Notifications have been sent and tokens cleaned up.');
            }
      // perform desired operations ...
    });

// Cleans up the tokens that are no longer valid.
  function cleanupTokens(response, tokens, uid) {
    // For each notification we check if there was an error.
    console.log("cleanup tokens v12");
    var tokensDelete = [];
    var batch = admin.firestore().batch();
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error('Failure sending notification to', tokens[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
          console.log("token to delete: ", [tokens[index]]);
          const FieldValue = require('firebase-admin').firestore.FieldValue;
          batch.update(admin.firestore().collection('users').doc(uid), {
            'fcm': FieldValue.arrayRemove(tokens[index])
          });
        }
      }
    });
    batch.commit();
    
   }


   //////FUNCTIONS TO HANDLE DELETION OF POSTS AND USERS

   exports.deletePost = functions.firestore
    .document('posts/{postID}')
    .onDelete(async (snap, context) => {
      const postId = context.params.postId;
      // Get an object representing the document prior to deletion
      // e.g. {'name': 'Marie', 'age': 66}
      const res = await admin.firestore().doc(`deletedPosts/${snap.id}`).set(snap.data());

      const userLiking = await admin.firestore().collection('users').where('likes', 'array-contains',
        snap.id).get();

      userLiking.forEach(function (documentSnapshot) {
        const doc = documentSnapshot;
        console.log(doc.id);

        const arrayWithLike = doc.data()['likes'];
        var index = arrayWithLike.indexOf(snap.id);
        if (index > -1) {
          arrayWithLike.splice(index, 1);
        }

        admin.firestore().collection('users').doc(doc.id).update({
          "likes": arrayWithLike});
        // do something with the data of each document.
      });

      const hashtags = snap.data()['hashtags'];

      const FieldValue = require('firebase-admin').firestore.FieldValue;

      for(var a=0; a<hashtags.length; a++){

        const hashtag = hashtags[a];
        admin.firestore().collection('hashtags').doc(hashtag).collection('posts').doc('{' + snap.id + '}').delete();
        admin.firestore().collection('hashtags').doc(hashtag).update({'count': FieldValue.increment(-1)});
      }

      if(snap.data()['templateTag'] !== 'None') {
        const template = await admin.firestore().collection('templates').doc(snap.data()['templateTag']).get();
        const acceptedByArray = template.data()['acceptedBy'];
        var index2 = acceptedByArray.indexOf(snap.data()['authorUsername']);
        if (index2 > -1) {
          acceptedByArray.splice(index2, 1);
        }
        admin.firestore().collection('templates').doc(snap.data()['templateTag']).update({
          "acceptedBy": acceptedByArray});
      }
      // perform desired operations ...
    });


    ////////////////FUNCTIONS TO HANDLE MESSAGING///////////////////////////

    exports.chatCreated = functions.firestore.document('chats/{chatId}').onCreate((snap, context)=>{

      const chatId = context.params.chatId;
      const chatMemberIds = chatId.split('_');
      const uid1 = chatMemberIds[0];
      const uid2 = chatMemberIds[1];
      let leftChatData = {};
      leftChatData[uid1] = null;
      leftChatData[uid2] = null;
      
      const data = {
        'chatMembers' : chatMemberIds,
        leftChat: leftChatData
      }
      admin.firestore().collection('chats').doc(chatId).update(data);
      

    })

    exports.messageSent = functions.firestore
    .document('/chats/{chatId}/messages/{messageId}')
    .onCreate(async (snapshot, context) =>
    {
    // Getting chat id from input
    const chatId = context.params.chatId;
    
    // Getting sennder id from snapshot and using it to find sender doc for username
    const senderId = snapshot.data()['from'];
    const senderDoc = await admin.firestore().doc(`users/${senderId}`).get();

    // Getting chat members to see who to send notification to
    const chatRef = admin.firestore().doc(`chats/${chatId}`);
    const chat = await chatRef.get();
    const chatMembers = chat.data()['chatMembers'];

    

    // Create notification payload
    const payload =
    {
        notification: { 
            title: `Message from ${senderDoc.data()['username']}`,
            body: `${snapshot.data()['msg']}`, 
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            
        },
        data: {
          
          type: 'Chat',
          senderUid: senderId,
          senderUsername: senderDoc.data()['username']
        }
    };

    // Remove chat member who sent message
    var index2 = chatMembers.indexOf(senderId);
    if (index2 > -1) {
      chatMembers.splice(index2, 1);
    }

    // Find fcm tokens of all chat members apart from sender
    var tokens = [];
    for(var i=0; i<chatMembers.length; i++){
        console.log(chatMembers[i]);
        const doc = await admin.firestore().doc(`users/${chatMembers[i]}`).get();
        console.log(doc.id);
        if (doc.data()['fcm'] !== null) {
          tokens = tokens.concat(doc.data()['fcm']);
        }
    }

    // Send notification message to all tokens 
    if (tokens.length > 0) {
      const response = await admin.messaging().sendToDevice(tokens, payload);
      await cleanupTokens(response, tokens, author);
      console.log('Notifications have been sent and tokens cleaned up.');
    }
});


exports.handleUnreadMessages = functions.firestore.document('chats/{chatId}').onUpdate((change, context)=>{
  const newValue = change.after.data();

  const uid1 = newValue.chatMembers[0];
  const uid2 = newValue.chatMembers[1];
  const latestMessageTimestamp = newValue.latestMessage.timeStamp.toDate();
  const uid1LeftChatTime = (newValue.leftChat[uid1]===null)?null:newValue.leftChat[uid1].toDate();
  const uid2LeftChatTime = (newValue.leftChat[uid2]===null)?null:newValue.leftChat[uid2].toDate();
  if (uid1LeftChatTime<latestMessageTimestamp || uid1LeftChatTime === null){
    let data = {chatNeedsAttention: true}
    admin.firestore().collection('userChatStatus').doc(uid1).set(data, {merge: true})
  }
  if (uid2LeftChatTime<latestMessageTimestamp || uid2LeftChatTime === null){
    let data = {chatNeedsAttention: true}
    admin.firestore().collection('userChatStatus').doc(uid2).set(data, {merge: true})
  }

  


})

exports.facebookUser = functions.https.onCall(async ([userId, friendsList], context) =>
    {
    console.log('uid: ' + userId);
    // Retrieve user file of Fundder user to provide right data for notification
    const receiver = await admin.firestore().doc(`users/${userId}`).get();
    const newValue = receiver.data();

    // For now we pass the friend data, as retrieving on node js is a headache, but in future can refactor.
    const friends = friendsList;
    // If error return 'wrong token' message
    if ('error' in friends) {
          console.log('wrong token');
    } else {
      // If no error, then add the facebook ids of all friends to array
      console.log('friend maps: ' + friends['data'].toString());
      var friendsFacebookIds = [];

      for(var j in friends['data']){
        var fid = friends['data'][j]['id'];
        friendsFacebookIds.push(fid.toString());
      }

      console.log('facebook friends: ' + friendsFacebookIds);
      
      // Retrieve users with the facebook ids in the array
      const userFriendsSnapshot = await admin.firestore().collection('users').where('facebookId', 'in', friendsFacebookIds).get();
      const userFriends = userFriendsSnapshot.docs.map(doc => doc);
      var tokens = [];
      // For every friend add to their activity feed to say that facebook friend has joined
      for(var i=0; i<userFriends.length; i++){
        console.log('user friend: ' + userFriends[i].toString());
        const doc = userFriends[i];
        console.log('user friend id: ' + doc.id);
        // Data to add to activity feed
        const data = {
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          category: 'new facebook friend',
          docLiker: userId,
          docLikerUsername: newValue['name'],
          postId: userId,
          seen: false};

        console.log('data: ' + doc.id);
        
        const res = await admin.firestore().collection(`users/${doc.id}/activity`).add(data);
        
        // Retrieve each receiver to find out their fcm token to send notification to
        const receiver = await admin.firestore().doc(`users/${doc.id}`).get();
        
        console.log('Added document with ID: ', res.id);
        if (receiver.data()['fcm'] !== null) {
          tokens = tokens.concat(receiver.data()['fcm']);
        }
      }

      // Log all tokens we are sending notification to
      console.log('tokens: ' + tokens);

      // Craft the notification
      const payload =
        {
            notification: { 
                title: 'Friends on Fundder',
                body: `Your facebook friend ${newValue['username']} is on Fundder`, 
            },
        };

      if (tokens.length > 0) {
          // Send notifications to all tokens.
          const response = await admin.messaging().sendToDevice(tokens, payload);
          console.log('Notifications have been sent and tokens cleaned up.');
          }
      }

    });
