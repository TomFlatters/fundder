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
const { user } = require('firebase-functions/lib/providers/auth');
admin.initializeApp();

exports.onLike = functions.firestore
    .document('/postsV2/{postId}/whoLiked/{userId}')
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
    const doc = await admin.firestore().doc(`postsV2/${postId}`).get();

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
    .document('/postsV2/{postId}/comments/{docId}')
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
    const doc = await admin.firestore().doc(`postsV2/${postId}`).get();

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
    .document('/postsV2/{postId}/whoDonated/{userId}')
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
    const doc = await admin.firestore().doc(`postsV2/${postId}`).get();

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
    .document('/postsV2/{postId}')
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
        const whoLikedSnapshot = await admin.firestore().collection(`postsV2/${postId}/whoLiked`).get();
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
        const whoDonatedSnapshot = await admin.firestore().collection(`postsV2/${postId}/whoDonated`).get();
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
    .document('/postsV2/{postId}')
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
    .document('postsV2/{postID}')
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
        admin.firestore().collection('hashtags').doc(hashtag).collection('postsV2').doc('{' + snap.id + '}').delete();
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

/**Houses various triggers to perform various actions on db.
 * DO NOT DEPLOY...I deployed it anyway LOL
 */


exports.populateDB = functions.firestore.document('dummyCollectionForTriggers/triggerDoc').onUpdate(async (change, context)=>{
  let res = {};
  const newValue = change.after.data();
  if (newValue.moreUsers  === true){
    res['moreUsersAcquired'] =  true
    //populate the users collection 
    let users = admin.firestore().collection('users');
    let faker = require('faker');


    var i;
    for (i =0; i<10; i++){
      const name = faker.name.findName();
      const email = faker.internet.email()
      const username = faker.internet.userName();

      const data = {
      noFollowers: 0,
      noFollowing: 0, 
      dpSetterPrompted: true,
      profilePic: "https://image.shutterstock.com/image-vector/september-23-2016-vector-icon-260nw-487367941.jpg",
      seenTutorial: true, 
      amountDonated: 0, 
      isPrivate: false, 
      username: username,
      name: name, 
      email: email,
      search_username: username.toLowerCase(),
    }
    users.add(data);
    } 
  }


  if (newValue.getMoreFollowers === true){
    //set a follower and followee and make the follower follow the followee
    res['moreFollowersAcquired'] = true;


      console.log("running userFollowedSomeone");
      const FieldValue = require('firebase-admin').firestore.FieldValue;
      const follower = newValue.dummyFollower; 
      const followee = newValue.dummyFollowee;
      const userCollection = admin.firestore().collection('users')
      const userDoc = await userCollection.doc(followee).get();
      const followeeIsPrivate = (userDoc.get('isPrivate')===null)?false:userDoc.get('isPrivate');
      const status = await initiateFollow(followee, follower, followeeIsPrivate);


  }

  if (newValue.assignUsersRandomNumbers===true){
    //there are 45 users in the doc....so on average 9 docs will be assigned to each number from 0 to 4
    const generateRandomNumber = (upperBound) => Math.ceil(Math.random() * upperBound); 
    const userCollection =  admin.firestore().collection('users')
    const userDocs = await userCollection.get();
    userDocs.docs.forEach( (q)=> userCollection.doc(q.id).set({'randomNumber': generateRandomNumber(4)}, {merge: true}))

  }

  if (newValue.migratePosts === true){
    const userCollection = admin.firestore().collection('users');
    const userDocs = await userCollection.get();
    const oldPostsCollection = admin.firestore().collection('posts');
    const oldPosts = await oldPostsCollection.get();
    const newPostsCollection = admin.firestore().collection('postsV2');
    oldPosts.docs.forEach((q)=>{const doc = q.data(); doc['isPrivate']=false;newPostsCollection.doc(q.id).set(doc)})

  }
  if (newValue.migrateWhoLiked ===true){
    const postId = newValue.postId;
    const whoLiked = admin.firestore().collection('posts').doc(postId).collection('whoLiked')
    const whoLikedDocs = await whoLiked.get();
    const newPostsCollection = admin.firestore().collection('postsV2');
    whoLikedDocs.forEach((q)=>{const doc = q.data(); newPostsCollection.doc(postId).collection('whoLiked').doc(q.id).set(doc)});

  }
  if (newValue.migrateComments ===true){
    const postId = newValue.postId;
    const comments =  admin.firestore().collection('posts').doc(postId).collection('comments');
    const commentDocs = await comments.get();
    const newPostsCollection = admin.firestore().collection('postsV2');
    commentDocs.forEach((q)=>{const doc = q.data(); newPostsCollection.doc(postId).collection('comments').doc(q.id).set(doc,{merge: true})});

  }
  if (newValue.migrateWhoDonated ===true){
    const postId = newValue.postId;
    const whoDonated =  admin.firestore().collection('posts').doc(postId).collection('whoDonated');
    const whoDonatedDocs = await whoDonated.get();
    const newPostsCollection = admin.firestore().collection('postsV2');
    whoDonatedDocs.forEach((q)=>{const doc = q.data(); newPostsCollection.doc(postId).collection('whoDonated').doc(q.id).set(doc,{merge: true})});

  }

  if (newValue.migrateFollowing ===true){
    const FieldValue = require('firebase-admin').firestore.FieldValue;
    const uid = newValue.uid;
    //get the people following 
    const followingCollection = admin.firestore().collection('users').doc(uid).collection('following');
    const followersCollection = admin.firestore().collection('followers')
    const followingDocSnaps = await followingCollection.get();
    followingDocSnaps.forEach((docSnap)=>{
      const followingId = docSnap.id
      followersCollection.doc(uid).set({'following': FieldValue.arrayUnion(followingId)}, {merge: true});
      followersCollection.doc(followingId).set({'followers': FieldValue.arrayUnion(uid)}, {merge: true});

    })

  }
  return res
})



/**Register a follower if followee is public, otherwise sends a follow request. */
exports.userFollowedSomeone = functions.https.onCall(async (data, context)=>  {
  //chang to arrayUnion if possible in production 
  //operation not working in emulation

  console.log("running userFollowedSomeone");
  const FieldValue = require('firebase-admin').firestore.FieldValue;
  const follower = data.follower; 
  const followee = data.followee;

  const userCollection = admin.firestore().collection('users')
  const userDoc = await userCollection.doc(followee).get();
  const followeeIsPrivate = (userDoc.get('isPrivate')===null)?false:userDoc.get('isPrivate');
  const status = await initiateFollow(followee, follower, followeeIsPrivate);
  return {status: status};
}
)

/**
 * If a user x follows user y, make x unfollow x from y. Otherwise do nothing.
 */

 exports.unfollowXfromY = functions.https.onCall(async (data, context)=>{
  console.log("running unfollowXfromY");
  const FieldValue = require('firebase-admin').firestore.FieldValue;
  const follower = data.x; 
  const followee = data.y;

  /**
   * Remove y from 'following' field of x
   * Remove x from 'followers' field of y
   * decrement noFollowers of y by one
   * decrement noFollowing of x by one
   */
  const userCollection = admin.firestore().collection('users');
  const followersCollection = admin.firestore().collection('followers');
  followersCollection.doc(followee).set({'followers': FieldValue.arrayRemove(follower)}, {merge: true});
  followersCollection.doc(follower).set({'following': FieldValue.arrayRemove(followee) }, {merge: true});
  userCollection.doc(follower).set({'noFollowing': FieldValue.increment(-1)}, {merge: true} );
  userCollection.doc(followee).set({'noFollowers': FieldValue.increment(-1)}, {merge: true});
  return {'status': 'removed'};
 })



/**Determines the follow relationship status of user x to user y. 
 * returns : `\n`
 * 
 * if (x follows y) returns 'following' `\n`
 * if (x requested to follow y) returns 'follow_requested' `\n`
 * otherwise returns 'not_following' `\n`
 * 
 */

 async function doesXfollowY(x, y)  {
  const followersCollection = admin.firestore().collection('followers');
  const xDoc = await followersCollection.doc(x).get();
  //////////////////SANITY CHECKS///////////////////////////
  if (!xDoc.exists){
    return 'not_following';
  }

  if (!("following" in xDoc.data() )){
    return 'not_following';
  }

  ////////////////////////////////////////////////////////////

  let xFollowing = xDoc.data()['following'];
  if (xFollowing.includes(y)){
    console.log("In if 2")
    return 'following'
  }
  else {
    //doesn't follow so either requested to follow or not yet following
    //check if requested 
    const yDoc = await followersCollection.doc(y).get();
    if (!yDoc.exists){return 'not_following'}

    if ("requestedToFollowMe" in yDoc.data())
    {
        const yRequested = yDoc.get('requestedToFollowMe')
        if (yRequested.includes(x)){

          return 'follow_requested'
        }
    }
    //the other two response have been ruled out at this point
    return 'not_following'
  }
 }

/**takes the id of the prospective followee
 * and id follower and the 'isPrivate' status of followee in that order.  */

async function initiateFollow (followee, follower, followeeIsPrivate){
   const FieldValue = require('firebase-admin').firestore.FieldValue;
   const followersCollection = admin.firestore().collection('followers');
   const userCollection = admin.firestore().collection('users')
   let status = "nothing";
   if (followeeIsPrivate){
     followersCollection.doc(followee).set({'requestedToFollowMe': FieldValue.arrayUnion(follower)}, {merge: true} )
     //if the user has nothing in the 'followers' field, initialise it to empty array
     const followerDoc = await followersCollection.doc(follower).get()
     if (!followerDoc.exists){

        followersCollection.doc(follower).set({'following': []}, {merge: true})

     }

    status ="requested"
    userCollection.doc(followee).set({'noFollowRequestsForMe': FieldValue.increment(1)}, {merge: true});
   }    
   else{
     followersCollection.doc(followee).set({'followers': FieldValue.arrayUnion(follower)}, {merge: true});
     followersCollection.doc(follower).set({'following': FieldValue.arrayUnion(followee) }, {merge: true});
     //send notification to followee that this user is now following you 
     userCollection.doc(follower).set({'noFollowing': FieldValue.increment(1)}, {merge: true} );
     userCollection.doc(followee).set({'noFollowers': FieldValue.increment(1)}, {merge: true});
     status = "nowFollowing"
   }
     return {'status': status};
}


exports.doesXfollowY = functions.https.onCall(async (data, context)=>{
  console.log("does x follow y???")
  const x = data.x;
  const y = data.y;
  const status =  await doesXfollowY(x, y);
  return {status: status};
})




/**Deploy posts to the post's author's feed and their followers. `\n`
 * Additionally, if the post is public then deploy to OTHER random users as well.
 * TODO: Keep track of Function times....
 */
exports.deployPostsToFeeds = functions.firestore.document('postsV2/{postId}').onCreate(async (snap, context)=>{
  const postValue = snap.data();
  const postId = context.params.postId;
  //deploy to feed of all followers
  const postAuthor =  postValue.author;
  const isPrivate = postValue.isPrivate;
  const userCollection = admin.firestore().collection('users');
  const FieldValue = require('firebase-admin').firestore.FieldValue;
  var userHasFollowers = false;

  //we are only putting static values in this feed. The mutable fields like noLikes, isPrivate etc... will be held only in the central collection.
  //post will be accessed from central collection anyway 
  //this is just for housekeeping and any future features which may require the static but not dynamic info
  //first put it in the author's feed and then the author's followers' feed

  //info regarding the nature of the post has been omitted if the author deletes the post later on. These posts in myFeed will persist but all sensitive data about them in the central collection will have 
  //been removed

  const postForMyFeed = {
    aspectRatio: postValue.aspectRatio,
    author: postValue.author,
    authorUsername: postValue.authorUsername,
    charity: postValue.charity,
    charityLogo: postValue.charityLogo, 
    timestamp: postValue.timestamp, 
    status: postValue.status,
    postId: postId,
    hashtags: postValue.hashtags,
  }
  userCollection.doc(postAuthor).collection('myFeed').doc(postId).set(postForMyFeed);
  const authorFollowersDoc = await admin.firestore().collection('followers').doc(postAuthor).get();
  if (authorFollowersDoc.exists){
    if ("followers" in authorFollowersDoc.data()){
      userHasFollowers = true;
      var followers = authorFollowersDoc.get('followers');
      followers.forEach(
        (followerId)=> {
          userCollection.doc(followerId).collection('myFeed').doc(postId).set(postForMyFeed);
          admin.firestore().collection('postsV2').doc(postId).collection('feedsDeployedTo').doc(followerId).set({'following': true, 'timestamp':FieldValue.serverTimestamp()});

        }
      );
    }
  }

  //if this post is public, deploy to random people to now....probability of random deployment can be adjusted
  //All random deployment will be to non-followers, as followers already have the post in their feed and we do
  // not want to override it with wrong info about follow relationship.

  if (!isPrivate){
    //right now each doc has a random integer between 0 to 4
    //in deployment generate a random number in the appropriate range but for now, we will use one

    const query = await userCollection.where('randomNumber', "==", 1).get();
    query.forEach((q)=>{
      const id = q.id;
      if (id !== postAuthor){
        let canProceed = true;
        if (userHasFollowers){
            followers.includes(id)?canProceed=false:canProceed=true
        }
        if (canProceed){
          userCollection.doc(id).collection('myFeed').doc(postId).set(postForMyFeed);
          admin.firestore().collection('postsV2').doc(postId).collection('feedsDeployedTo').doc(id).set({'following': false, 'timestamp':FieldValue.serverTimestamp()});
        }
      }
    })
  }
})


exports.onRefreshHashtag = functions.https.onCall(async (data, context)=>{
  const hashtag = data.hashtag;
  const limit = data.limit;
    // the format of data.timeStamp is "Timestamp(seconds=1601043492, nanoseconds=743686000)"....i.e. a string
  // this needs to be converted to a Timestamp dobject for querying purposes 
  const regEx = /\d+/g;
  const startTimestamp = data.timeStamp;
  const [secs, nanoSecs] = startTimestamp.match(regEx); //returns an array in the formt [1601043492,743686000]
  const timeStamp = new  admin.firestore.Timestamp( parseInt(secs),  parseInt(nanoSecs));
  const uid = context.auth.uid;

  const postsCollection = admin.firestore().collection('postsV2');

  const query = await postsCollection.where("hashtags", "array-contains", hashtag).orderBy("timestamp", 'desc').startAfter(timeStamp).limit(limit).get();
  const queryDocSnap = query.docs
  const queryData = queryDocSnap.map((qDocSnap)=> qDocSnap.data())


  const myFollowersDoc = await admin.firestore().collection('followers').doc(uid).get();
  const following = myFollowersDoc.exists?((myFollowersDoc.data()['following'] === undefined)?[]:myFollowersDoc.data()['following']):[];


  let postJSONS = queryData.filter( (postObj)=>{
      //Check if you're allowed access to this post.
       allowedAccess = amIallowedAccess(following, postObj, uid);
       return allowedAccess;
  });

  console.log(postJSONS);
  console.log("printing filtered jsons of posts with this hashtag"); 
  postJSONS = postJSONS.filter((docSnap)=> docSnap!==null);
  console.log(postJSONS);
  return {"listOfJsonDocs": postJSONS}


});
/**Returns a list of json objects representing the latest 'limit' posts
 * of either a fund or done status from a specified timestamp for a given user.
 */

exports.onRefreshPost = functions.https.onCall(async (data, context)=>{
  const postStatus = data.status;
  const limit = data.limit;
  // the format of data.timeStamp is "Timestamp(seconds=1601043492, nanoseconds=743686000)"....i.e. a string
  // this needs to be converted to a Timestamp dobject for querying purposes 
  const regEx = /\d+/g;
  const startTimestamp = data.timeStamp;
  const [secs, nanoSecs] = startTimestamp.match(regEx); //returns an array in the formt [1601043492,743686000]
  const timeStamp = new  admin.firestore.Timestamp( parseInt(secs),  parseInt(nanoSecs));
  const uid = context.auth.uid;
  const myFeed = admin.firestore().collection('users').doc(uid).collection('myFeed');
  const postsCollection = admin.firestore().collection('postsV2');

  const query = await myFeed.where("status", "==", postStatus).orderBy("timestamp", 'desc').startAfter(timeStamp).limit(limit).get();
  const queryDocSnap = query.docs
  const queryData = queryDocSnap.map((qDocSnap)=> qDocSnap.data()['postId'])

  const myFollowersDoc = await admin.firestore().collection('followers').doc(uid).get();
  const following = myFollowersDoc.exists?((myFollowersDoc.data()['following'] === undefined)?[]:myFollowersDoc.data()['following']):[];
  console.log(`this is the list of users I'm following ${following}`);

  let postJSONS = await Promise.all(queryData.map(async (postId)=>{
    const postDoc = await postsCollection.doc(postId).get();
    if (postDoc.exists){
      let postObj = postDoc.data();
      //Check if you're allowed access to this post.
      const allowedAccess = amIallowedAccess(following, postObj, uid);
      (allowedAccess)?console.log("Access allowed"):console.log("Access is denied");
      if (allowedAccess === true){
        if (postObj['status']===postStatus){ 
          //It may have changed from 'fund' to 'done'.
          postObj['postId'] = postId;
          return postObj;
        }
        else {
          console.log("Status of this post has changed");
          changePostStatusInFeed(uid, postId, postObj['status']);
          return null;
        }
      }  
      else{
        //if access is not allowed then this post ought to be PRUNED from this feed
        deletePostFromMyFeed(postId, uid);
        return null;
      }   
    }
    else {
      deletePostFromMyFeed(postId, uid);
      return null;
    }
  }));

  console.log(postJSONS);
  console.log("printing filtered jsons"); 
  postJSONS = postJSONS.filter((docSnap)=> docSnap!==null);
  console.log(postJSONS);
  return {"listOfJsonDocs": postJSONS}
})



/**Get post by an author */
exports.getAuthorPosts = functions.https.onCall(async (data, context)=>{
  const authorId = data.id;
  const postsCollection = admin.firestore().collection('postsV2');
  const query = await postsCollection.where('author', '==', authorId).orderBy("timestamp", 'desc').get();
  const queryDocSnap = query.docs;
  //filter for posts to which access is not denied
  const queryData = queryDocSnap.map((qDocSnap)=> {const postJSON = qDocSnap.data(); postJSON['postId']=qDocSnap.id; return postJSON})
  const uid = context.auth.uid;

  const myFollowersDoc = await admin.firestore().collection('followers').doc(uid).get();
  const following = myFollowersDoc.exists?((myFollowersDoc.data()['following'] === undefined)?[]:myFollowersDoc.data()['following']):[];


  let postJSONS = queryData.filter( (postObj)=>{
      //Check if you're allowed access to this post.

       const allowedAccess = amIallowedAccess(following, postObj, uid);
       return allowedAccess;
  });



  console.log("printing jsons of author posts....")
  console.log(postJSONS);
  return {"listOfJsonDocs": postJSONS}


})

/**
 * Sets the 'status' of a post in myFeed to newStatus 
 * Invoked when loading up posts from myFeed to display to the user. Status discrepancies that may 
 * be caused when the user migrates a post from fund to done will be fixed here, on the fly.
*/

function changePostStatusInFeed(feedUid, postId, newStatus){
  const myFeed = admin.firestore().collection('users').doc(feedUid).collection('myFeed');
  myFeed.doc(postId).set({'status': newStatus}, {merge: true});
}

/**Removes a post with postId from myFeed of user uid */

function deletePostFromMyFeed(postId, uid){
  const myFeed = admin.firestore().collection('users').doc(uid).collection('myFeed');
  myFeed.doc(postId).delete();
  console.log(`deleted doc ${postId}`);
}

/**Check to see if user is allowed access to a certain post */

function amIallowedAccess(following, postObj, uid){
  console.log("Checking if access is allowed");
  const authorId = postObj["author"];
  const isPrivate = postObj["isPrivate"];
  const selectedPrivateViewers = postObj["selectedPrivateViewers"];
  if (authorId === uid){
    return true;
  }
  if (isPrivate === true){
    //the post is private so only followers ought to be able to see
    const isFollowing = following.includes(authorId);
    //a further check to see if the post is only available to specific followers
    if (selectedPrivateViewers === undefined){
      console.log("Post is private but not for only select few followers");
      //this post is private but not to specific people
      return isFollowing;
    }
    else {
      console.log("Post is private but only for specific followers")
      const isChosenToView = selectedPrivateViewers.includes(uid) ||  selectedPrivateViewers.length === 0;
      return isChosenToView;
    }
  }
  else {
    console.log("This is a public post")
    //post is public so anyone can see
    return true;
  }
}


/**
 * Assign each user a random number and give them every public post in their feed
 * TODO: update 'feedsDeployedTo' on the post doc subcollection & keep track of function times...
 */
exports.feedManagementOnUserCreated = functions.runWith({memory: '2GB', timeoutSeconds: '540' }).firestore.document('users/{uid}').onCreate(async (snap, context)=>{
  const uid = context.params.uid;
  const FieldValue = require('firebase-admin').firestore.FieldValue;
  const bookKeepingCollection = admin.firestore().collection('bookKeeping');
  bookKeepingCollection.doc('userList').set({'listOfUsers': FieldValue.arrayUnion(uid)},  {merge: true});
  const userCollection =  admin.firestore().collection('users');
  const postsCollection = admin.firestore().collection('postsV2');

  userCollection.doc(uid).set({'randomNumber': 1}, {merge: true});

  //give them every public post

  const myFeed = userCollection.doc(uid).collection('myFeed');
  const publicPostQuery = await postsCollection.where('isPrivate', '==', false).get();
  const publicPosts = publicPostQuery.docs

  publicPosts.forEach((q)=>{
    if (q.exists){
      const postValue = q.data();
      console.log(postValue.authorUsername);
      const postForMyFeed = {
        aspectRatio: postValue.aspectRatio,
        author: postValue.author,
        authorUsername: postValue.authorUsername,
        charity: postValue.charity,
        charityLogo: postValue.charityLogo, 
        timestamp: postValue.timestamp, 
        status: postValue.status,
        postId: q.id,
        hashtags: postValue.hashtags,
      }
      myFeed.doc(q.id).set(postForMyFeed);
    }
  })



})


exports.getAListOfUsers = functions.runWith({memory: '2GB', timeoutSeconds: '540' }).pubsub.schedule('every 2 minutes').onRun(async (context)=>{
  admin.auth().listUsers(1000).then(async function(listUsersResult) {
    //in parallel deploy posts to all 1000 users
    promiseOfDeployment = await Promise.all(listUsersResult.users.map(function(userRecord){
      const uid = userRecord.uid;
      const FieldValue = require('firebase-admin').firestore.FieldValue;
      const bookKeepingCollection = admin.firestore().collection('bookKeeping');
      return bookKeepingCollection.doc('userList').set({'listOfUsers': FieldValue.arrayUnion(uid)},  {merge: true});

    }))
  return null;
}).catch(function(error) {
  console.log('Error managing feed', error);
})
});
exports.scheduledFunction = functions.runWith({memory: '2GB', timeoutSeconds: '540' }).pubsub.schedule('every 120 minutes').onRun(async (context) => {
  const postsCollection = admin.firestore().collection('postsV2');
  //get the 50 most recent public posts....
  const publicPostQuery = await postsCollection.where('isPrivate', '==', false).orderBy('timestamp', 'desc').limit(10).get();
  const publicPosts = publicPostQuery.docs;

  //get a list of all users (MODIFY THIS IMMEDIATELY ONCE WE GET)
  admin.auth().listUsers(1000)
  .then(async function(listUsersResult) {
    //in parallel deploy posts to all 1000 users
    const promiseOfDeployment = await Promise.all(listUsersResult.users.map(function(userRecord){
      const uid = userRecord.uid;

      //async function that takes a user id and a bunch of posts and deploys them to the user

      const deployPromiseForUser = deployPostsToUser(uid, publicPosts);
      return deployPromiseForUser
    }))
  return promiseOfDeployment;
}).catch(function(error) {
  console.log('Error managing feed', error);
});
});


async function deployPostsToUser(uid, publicPosts){

  const myFeed = admin.firestore().collection('users').doc(uid).collection('myFeed');
  const deployPromiseForUser =  await Promise.all(publicPosts.map(async function(docSnap){
    if (docSnap.exists){
      const postValue = docSnap.data();
      const postForMyFeed = {
        aspectRatio: postValue.aspectRatio,
        author: postValue.author,
        authorUsername: postValue.authorUsername,
        charity: postValue.charity,
        charityLogo: postValue.charityLogo, 
        timestamp: postValue.timestamp, 
        status: postValue.status,
        postId: docSnap.id,
        hashtags: postValue.hashtags,
      }
      const postDeployedToThisUser = await myFeed.doc(docSnap.id).set(postForMyFeed);
      return postDeployedToThisUser;
    }
    else{
      return null;
    }
  }));
  return deployPromiseForUser;
}