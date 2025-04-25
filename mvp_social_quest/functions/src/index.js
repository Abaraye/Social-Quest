import { onCall } from 'firebase-functions/v2/https';
import { migrateSlotsSetPrice } from './migrations/pricing.js';

export const migrateSlotsSetPrice = onCall(
  { timeoutSeconds: 540, memory: '512MiB', region: 'europe-west1' },
  async (req) => {
    const {
      defaultCents = 2000,
      currency = 'EUR',
      dryRun = false,
    } = req.data ?? {};
    const total = await migrateSlotsSetPrice(
      Number(defaultCents),
      currency,
      Boolean(dryRun),
    );
    return { updated: total, dryRun };
  },
);
