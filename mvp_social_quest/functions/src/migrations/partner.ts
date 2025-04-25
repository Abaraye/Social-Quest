import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v1';
import { onCall } from 'firebase-functions/v2/https';

admin.initializeApp();
const db = admin.firestore();

/** One-shot pricing migration déjà vu ici */
export async function migratePartners(dryRun = false) {
  const snap = await db.collection('partners').get();
  logger.info(`Partners: ${snap.size}`);
  let updated = 0;

  const batch = db.batch();
  snap.docs.forEach((d) => {
    batch.update(d.ref, { photos: [], avgRating: 0, reviewsCount: 0 });
    updated++;
  });
  if (!dryRun) await batch.commit();
  return updated;
}

/* Cloud Function callable */
export const migratePartnersFn = onCall(
  { region: 'europe-west1', timeoutSeconds: 540, memory: '512MiB' },
  async (req) => {
    const dry = Boolean(req.data?.dryRun);
    const total = await migratePartners(dry);
    return { dryRun: dry, updated: total };
  },
);
