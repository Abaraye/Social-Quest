import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v1';

admin.initializeApp();
const db = admin.firestore();

/**
 * Back-fills priceCents/currency on every slot document lacking it.
 * @param defaultCents  amount applied when missing (e.g. 2000 = 20 €)
 * @param currency      ISO-4217 code
 * @param dryRun        if true, no write is performed
 */
export async function migrateSlotsSetPrice(
  defaultCents = 2000,
  currency = 'EUR',
  dryRun = false,
): Promise<number> {
  logger.info(
    `migrateSlotsSetPrice | default=${defaultCents}c | currency=${currency} | dryRun=${dryRun}`,
  );

  const partners = await db.collection('partners').get();
  let updated = 0;

  for (const p of partners.docs) {
    let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;

    while (true) {
      let query = p.ref.collection('slots').orderBy('__name__').limit(500);
      if (lastDoc) query = query.startAfter(lastDoc);
      const snap = await query.get();
      if (snap.empty) break;

      const batch = db.batch();
      let batchCount = 0;

      for (const doc of snap.docs) {
        const data = doc.data();
        if (data.priceCents == null) {
          updated++;
          batchCount++;
          if (!dryRun) {
            batch.update(doc.ref, {
              priceCents: defaultCents,
              currency,
            });
          }
        }
      }

      if (!dryRun && batchCount > 0) {
        await batch.commit();
      }

      lastDoc = snap.docs[snap.docs.length - 1];
      if (snap.size < 500) break;
    }
  }

  logger.info(`✔ Migration finished → ${updated} document(s) ${dryRun ? 'would be' : 'were'} updated`);
  return updated;
}
