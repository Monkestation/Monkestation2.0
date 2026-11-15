import type { BooleanLike } from 'tgui-core/react';

export enum RequestStatus {
  Waiting = 'waiting',
  Claimed = 'claimed',
  Ready = 'ready',
  PickedUp = 'picked_up',
  Declined = 'declined',
  Cancelled = 'cancelled',
}

export type ExtractRequest = {
  id: number;
  item: string;
  count: number;
  reason: string;
  offer: number;
  status: RequestStatus;
  requester: string;
  job: string;
  claimer: string | null;
  mine: BooleanLike;
  decline_reason: string | null;
  loaded: number;
  seen: BooleanLike;
};

export type RequesterData = {
  bred: string[];
  user: { name: string; job: string; balance: number } | null;
  requests: ExtractRequest[];
};

export const REASON_LENGTH = 60;
