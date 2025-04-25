// functions/scripts/migrate_partners.js   (version corrigée)
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp({ credential: applicationDefault() });
const db = getFirestore();

(async () => {
  const snap = await db.collection('partners').get();
  console.log(`🔎  ${snap.size} partenaires…`);
  const batch = db.batch();

  snap.docs.forEach((doc) => {
    batch.update(doc.ref, {
      photos: [],          // ✅ tableau vide directement
      avgRating: 0,
      reviewsCount: 0,
      // Optionnel : ne touche pas aux champs s’ils existent déjà
      // Utilise FieldValue.increment pour init si absent :
      // avgRating: FieldValue.increment(0),
    });
  });

  await batch.commit();
  console.log('✅  Migration terminée.');
  process.exit(0);
})();
