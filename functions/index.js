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
    await cleanupTokens(response, tokens);
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
        
        const whoLikedSnapshot = await admin.firestore().collection(`posts/${postId}/whoLiked`).get();
        const whoLikedDoc = whoLikedSnapshot.docs.map(doc => doc);

        console.log(whoLikedDoc);

        var tokens = [];

        const postOwner = await admin.firestore().doc(`users/${newValue['author']}`).get();

        
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
                docLikerUsername: postOwner.data()['username'],
                postId: postId,
                seen: false
            };

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
                  body: `${newValue['author']} completed a post that you like`, 
              },
          };

        if (tokens.length > 0) {
            // Send notifications to all tokens.
            const response = await admin.messaging().sendToDevice(tokens, payload);
            await cleanupTokens(response, tokens);
            console.log('Notifications have been sent and tokens cleaned up.');
            }
        
      }

      // perform desired operations ...
    });

// Cleans up the tokens that are no longer valid.
function cleanupTokens(response, tokens) {
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
   }