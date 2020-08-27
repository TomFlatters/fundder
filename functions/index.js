const functions = require('firebase-functions');

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
    await cleanupTokens(response, tokens);
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
    //await cleanupTokens(response, tokens);
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
    //await cleanupTokens(response, tokens);
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
            //await cleanupTokens(response, tokens);
            console.log('Notifications have been sent and tokens cleaned up.');
            }
      // perform desired operations ...
    });

// Cleans up the tokens that are no longer valid.
/*function cleanupTokens(response, tokens) {
    // For each notification we check if there was an error.
    const tokensDelete = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error('Failure sending notification to', tokens[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered') {
          const deleteTask = admin.firestore().collection('fcmTokens').doc(tokens[index]).delete();
          tokensDelete.push(deleteTask);
        }
      }
    });
    return Promise.all(tokensDelete);
   }*/


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
      // perform desired operations ...
    });



