/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.migratePartners = functions.https.onRequest(async (_, res) => {
    const partnersSnap = await db.collection('partners').get();
    const batch = db.batch();
  
    partnersSnap.forEach((doc) => {
      batch.update(doc.ref, { photos: [], avgRating: 0, reviewsCount: 0 });
    });
  
    await batch.commit();
    res.send('Migration OK');
  });
  
