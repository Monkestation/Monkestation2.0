import type { ExtractRequest } from '../ExtractRequests/types';

export type ExtractOrdersData = {
  requests: ExtractRequest[];
  /** Extracts in the fridges in reach, by color id. */
  stock: Record<string, number>;
  bred: string[];
};
