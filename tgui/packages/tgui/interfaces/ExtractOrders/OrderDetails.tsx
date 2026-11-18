import { useState } from 'react';
import { Box, Button, Icon, Input } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SlimeChip, SlimeName } from '../common/SlimeRancher';
import {
  type Item,
  itemName,
  parseItem,
  spriteId,
} from '../ExtractRequests/items';
import {
  BreedPath,
  breedingPath,
  Ingredient,
  ItemPreview,
} from '../ExtractRequests/Shared';
import {
  type ExtractRequest,
  REASON_LENGTH,
  RequestStatus,
} from '../ExtractRequests/types';
import type { SlimeColor, SlimepediaData } from '../Slimepedia/types';

type Props = {
  request: ExtractRequest;
  catalog: SlimepediaData;
  colors: Map<string, SlimeColor>;
  stock: Record<string, number>;
  bred: Set<string>;
  onClaim: () => void;
};

function HaveChip(props: { have: number; need: number }) {
  const { have, need } = props;

  return have >= need ? (
    <SlimeChip tone="good">Have {have}</SlimeChip>
  ) : (
    <SlimeChip tone="caution">Short {need - have}</SlimeChip>
  );
}

function ExtractPlan(props: {
  color: SlimeColor;
  needed: number;
  stock: Record<string, number>;
  colors: Map<string, SlimeColor>;
  bred: Set<string>;
}) {
  const { color, needed, stock, colors, bred } = props;
  const short = needed - (stock[color.id] ?? 0);

  if (short <= 0) {
    return null;
  }
  if (bred.has(color.id)) {
    return <SlimeChip tone="caution">Short by {short}</SlimeChip>;
  }
  return (
    <Box className="ExtractRequests__recipe">
      <Box bold>Breed it from</Box>
      <BreedPath
        path={breedingPath(color.id, bred, colors)}
        colors={colors}
        bred={bred}
      />
    </Box>
  );
}

function CrossbreedPlan(props: {
  source: SlimeColor;
  color: SlimeColor;
  needed: number;
  catalog: SlimepediaData;
  stock: Record<string, number>;
  colors: Map<string, SlimeColor>;
  bred: Set<string>;
}) {
  const { source, color, needed, catalog, stock, colors, bred } = props;
  const tanks =
    source.id === color.id
      ? [
          {
            color: source,
            count: needed * (catalog.effect_extracts + catalog.color_extracts),
            role: 'Both tanks',
          },
        ]
      : [
          {
            color: source,
            count: needed * catalog.effect_extracts,
            role: 'Type tank',
          },
          {
            color,
            count: needed * catalog.color_extracts,
            role: 'Color tank',
          },
        ];

  return (
    <Box className="ExtractRequests__recipe">
      <Box bold>Compress {needed} in the extract compressor</Box>
      {tanks.map((tank) => (
        <Box key={tank.role} className="ExtractRequests__recipe">
          <Ingredient
            color={tank.color}
            count={tank.count}
            role={tank.role}
            bred={bred.has(tank.color.id)}
          >
            <HaveChip have={stock[tank.color.id] ?? 0} need={tank.count} />
          </Ingredient>
          {!bred.has(tank.color.id) && (
            <BreedPath
              path={breedingPath(tank.color.id, bred, colors)}
              colors={colors}
              bred={bred}
            />
          )}
        </Box>
      ))}
    </Box>
  );
}

function offerText(request: ExtractRequest) {
  switch (request.status) {
    case RequestStatus.PickedUp:
      return `Paid ${request.offer} cr`;
    case RequestStatus.Declined:
    case RequestStatus.Cancelled:
      return `${request.offer} cr refunded`;
    default:
      return `Pays ${request.offer} cr on pickup`;
  }
}

function Actions(props: {
  request: ExtractRequest;
  item: Item;
  onClaim: () => void;
}) {
  const { request, item, onClaim } = props;
  const { act } = useBackend();
  const [declining, setDeclining] = useState(false);
  const [reason, setReason] = useState('');
  const { id } = request;

  if (declining) {
    return (
      <Box className="ExtractRequests__actions">
        <Input
          fluid
          autoFocus
          className="ExtractRequests__input"
          maxLength={REASON_LENGTH}
          placeholder="Why not?"
          value={reason}
          onChange={setReason}
          onEnter={() => act('decline', { id, reason: reason.trim() })}
        />
        <Button
          className="ExtractRequests__button"
          onClick={() => act('decline', { id, reason: reason.trim() })}
        >
          Decline
        </Button>
        <Button
          className="ExtractRequests__button ExtractRequests__button--quiet"
          icon="arrow-left"
          onClick={() => setDeclining(false)}
        >
          Back
        </Button>
      </Box>
    );
  }

  const decline = (
    <Button
      className="ExtractRequests__button ExtractRequests__button--quiet"
      onClick={() => setDeclining(true)}
    >
      Decline
    </Button>
  );

  switch (request.status) {
    case RequestStatus.Waiting:
      return (
        <Box className="ExtractRequests__actions">
          <Button
            className="ExtractRequests__button"
            icon="hand"
            onClick={onClaim}
          >
            Claim
          </Button>
          {decline}
        </Box>
      );
    case RequestStatus.Claimed:
      if (!request.mine) {
        return (
          <Box className="ExtractRequests__actions">
            <SlimeChip tone="muted">{request.claimer} has this one</SlimeChip>
          </Box>
        );
      }
      return (
        <Box className="ExtractRequests__actions">
          {!item.family && (
            <Button
              className="ExtractRequests__button"
              icon="check"
              onClick={() => act('ready', { id })}
            >
              Mark ready
            </Button>
          )}
          <Button
            className="ExtractRequests__button ExtractRequests__button--quiet"
            onClick={() => act('unclaim', { id })}
          >
            Unclaim
          </Button>
          {decline}
        </Box>
      );
    case RequestStatus.Ready:
      return (
        <Box className="ExtractRequests__actions">
          <SlimeChip tone="good">Waiting for pickup</SlimeChip>
          {!!request.mine && decline}
        </Box>
      );
    case RequestStatus.PickedUp:
      return (
        <Box className="ExtractRequests__actions">
          <SlimeChip tone="muted">Picked up</SlimeChip>
        </Box>
      );
    case RequestStatus.Declined:
      return (
        <Box className="ExtractRequests__actions">
          <SlimeChip tone="danger">
            {request.decline_reason || 'Declined'}
          </SlimeChip>
        </Box>
      );
    case RequestStatus.Cancelled:
      return (
        <Box className="ExtractRequests__actions">
          <SlimeChip tone="muted">Cancelled</SlimeChip>
        </Box>
      );
  }
}

export function OrderDetails(props: Props) {
  const { request, catalog, colors, stock, bred, onClaim } = props;
  const item = parseItem(request.item);
  const color = colors.get(item.color);
  const family = catalog.families.find((entry) => entry.id === item.family);
  const source = family && colors.get(family.source);
  const desc = family?.crossbreeds.find(
    (entry) => entry.color === item.color,
  )?.desc;
  const needed = request.count - request.loaded;
  const unfilled =
    request.status === RequestStatus.Waiting ||
    request.status === RequestStatus.Claimed;

  return (
    <Box className="SlimeRancher__card ExtractOrders__details">
      <ItemPreview sprite={spriteId(item)} />
      <Box className="ExtractOrders__details-scroll SlimeRancher__scroll">
        <Box className="ExtractRequests__title">
          <Box as="h2">
            {color ? (
              <SlimeName
                color={color.name}
                hex={color.hex}
                label={`${request.count}x ${itemName(item, colors)}`}
              />
            ) : (
              request.item
            )}
          </Box>
          <Box className="ExtractOrders__who">
            <Icon name="id-card" />
            <Box as="strong">{request.requester}</Box>
            <Box as="span" className="ExtractRequests__muted">
              {request.job}
            </Box>
          </Box>
        </Box>
        <Box className="SlimeRancher__well">
          {request.reason || 'No reason given.'}
        </Box>
        <Box className="ExtractRequests__chips">
          {request.offer > 0 && (
            <SlimeChip tone="caution" icon="coins">
              {offerText(request)}
            </SlimeChip>
          )}
          {!item.family && unfilled && (
            <SlimeChip tone={stock[item.color] ? 'good' : 'muted'}>
              {stock[item.color] ?? 0} in the fridge
            </SlimeChip>
          )}
          {request.loaded > 0 && request.status === RequestStatus.Claimed && (
            <SlimeChip tone="ink">
              Loaded {request.loaded} / {request.count}
            </SlimeChip>
          )}
        </Box>
        {!!desc && <Box>{desc}</Box>}
        {!!item.family && request.status === RequestStatus.Claimed && (
          <Box className="ExtractRequests__muted">
            Load by hand or with a science bag.
          </Box>
        )}
        {unfilled &&
          !!color &&
          (source ? (
            needed > 0 && (
              <CrossbreedPlan
                source={source}
                color={color}
                needed={needed}
                catalog={catalog}
                stock={stock}
                colors={colors}
                bred={bred}
              />
            )
          ) : (
            <ExtractPlan
              color={color}
              needed={needed}
              stock={stock}
              colors={colors}
              bred={bred}
            />
          ))}
      </Box>
      <Actions
        key={request.id}
        request={request}
        item={item}
        onClaim={onClaim}
      />
    </Box>
  );
}
