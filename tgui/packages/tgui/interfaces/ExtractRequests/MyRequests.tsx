import { Box, Button } from 'tgui-core/components';

import { SlimeChip } from '../common/SlimeRancher';
import { SlimepediaSprite } from '../Slimepedia/SlimepediaSprite';
import type { SlimeColor } from '../Slimepedia/types';
import { itemName, parseItem, spriteId } from './items';
import { type ExtractRequest, RequestStatus } from './types';

type Props = {
  requests: ExtractRequest[];
  colors: Map<string, SlimeColor>;
  canPickUp: boolean;
  onCancel: (id: number) => void;
  onPickUp: (id: number) => void;
};

function StatusChip(props: { request: ExtractRequest }) {
  const { request } = props;

  switch (request.status) {
    case RequestStatus.Waiting:
      return <SlimeChip tone="caution">Waiting</SlimeChip>;
    case RequestStatus.Claimed:
      return <SlimeChip tone="ink">{request.claimer} is on it</SlimeChip>;
    case RequestStatus.Ready:
      return <SlimeChip tone="good">Ready for pickup</SlimeChip>;
    case RequestStatus.PickedUp:
      return <SlimeChip tone="muted">Picked up</SlimeChip>;
    case RequestStatus.Declined:
      return (
        <SlimeChip tone="danger">
          {request.decline_reason || 'Declined'}
        </SlimeChip>
      );
    case RequestStatus.Cancelled:
      return null;
  }
}

function offerText(request: ExtractRequest) {
  switch (request.status) {
    case RequestStatus.PickedUp:
      return `Paid ${request.offer} cr`;
    case RequestStatus.Declined:
    case RequestStatus.Cancelled:
      return 'Refunded';
    default:
      return `${request.offer} cr held`;
  }
}

function RowAction(props: {
  request: ExtractRequest;
  canPickUp: boolean;
  onCancel: () => void;
  onPickUp: () => void;
}) {
  const { request, canPickUp, onCancel, onPickUp } = props;

  if (request.status === RequestStatus.Waiting) {
    return (
      <Button
        className="ExtractRequests__button ExtractRequests__button--quiet"
        onClick={onCancel}
      >
        Cancel
      </Button>
    );
  }
  if (request.status !== RequestStatus.Ready) {
    return null;
  }
  if (!canPickUp) {
    return <Box className="ExtractRequests__note">Pick up at a console</Box>;
  }
  return (
    <Button
      className="ExtractRequests__button"
      icon="hand-holding"
      onClick={onPickUp}
    >
      Pick up
    </Button>
  );
}

export function MyRequests(props: Props) {
  const { requests, colors, canPickUp, onCancel, onPickUp } = props;

  if (requests.length === 0) {
    return (
      <Box className="ExtractRequests__empty">
        <Box className="ExtractRequests__empty-socket">?</Box>
        <Box as="h2">No requests yet.</Box>
      </Box>
    );
  }
  return (
    <Box className="ExtractRequests__list SlimeRancher__scroll">
      {[...requests].reverse().map((request) => {
        const item = parseItem(request.item);
        return (
          <Box key={request.id} className="ExtractRequests__row">
            <Box className="ExtractRequests__row-art">
              <SlimepediaSprite id={spriteId(item)} scale={2} />
            </Box>
            <Box className="ExtractRequests__row-text">
              <Box bold>
                {request.count}x {itemName(item, colors)}
              </Box>
              <Box className="ExtractRequests__row-reason">
                {request.reason || 'No reason given'}
              </Box>
            </Box>
            <Box className="ExtractRequests__chips">
              {request.offer > 0 && (
                <SlimeChip tone="caution" icon="coins">
                  {offerText(request)}
                </SlimeChip>
              )}
              <StatusChip request={request} />
            </Box>
            <RowAction
              request={request}
              canPickUp={canPickUp}
              onCancel={() => onCancel(request.id)}
              onPickUp={() => onPickUp(request.id)}
            />
          </Box>
        );
      })}
    </Box>
  );
}
