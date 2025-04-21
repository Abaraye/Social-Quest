import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

initializeApp();
const db = getFirestore();

(async () => {
  const partners = await db.collection("partners").get();
  const batch = db.batch();

  partners.forEach((doc) => {
    batch.update(doc.ref, {
      photos: [],          // start empty, UI gérera le placeholder
      avgRating: 0,
      reviewsCount: 0,
    });
  });

  await batch.commit();
  console.log(`✅  Migrated ${partners.size} partners`);
  process.exit(0);
})();
