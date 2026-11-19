import '../../styles/interfaces/ExtractRequests.scss';
import '../../styles/interfaces/ExtractOrders.scss';

import { useMemo, useState } from 'react';
import { Box, Button, Icon, Tabs, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { SlimeChip } from '../common/SlimeRancher';
import { itemName, parseItem, spriteId } from '../ExtractRequests/items';
import { type ExtractRequest, RequestStatus } from '../ExtractRequests/types';
import { useSlimepediaData } from '../Slimepedia';
import { SlimepediaSprite } from '../Slimepedia/SlimepediaSprite';
import type { SlimeColor, SlimepediaData } from '../Slimepedia/types';
import { OrderDetails } from './OrderDetails';
import type { ExtractOrdersData } from './types';

enum Tab {
  Queue = 'queue',
  Mine = 'mine',
  Closed = 'closed',
}

const CLOSED = [
  RequestStatus.PickedUp,
  RequestStatus.Declined,
  RequestStatus.Cancelled,
];

export const ExtractOrders = () => {
  const catalog = useSlimepediaData();

  return (
    <Window width={780} height={620} theme="slime_rancher">
      <Window.Content fitted className="ExtractRequests ExtractOrders">
        {catalog ? (
          <Orders catalog={catalog} />
        ) : (
          <Box className="ExtractRequests__empty">
            <Icon name="spinner" spin size={3} />
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

function SlabChip(props: { request: ExtractRequest }) {
  const { request } = props;

  switch (request.status) {
    case RequestStatus.Waiting:
      return request.seen ? null : <SlimeChip tone="raspberry">New</SlimeChip>;
    case RequestStatus.Claimed:
      return request.mine ? (
        <SlimeChip tone="ink">Yours</SlimeChip>
      ) : (
        <SlimeChip tone="muted">{request.claimer}</SlimeChip>
      );
    case RequestStatus.Ready:
      return <SlimeChip tone="good">Ready</SlimeChip>;
    case RequestStatus.PickedUp:
      return <SlimeChip tone="muted">Picked up</SlimeChip>;
    case RequestStatus.Declined:
      return <SlimeChip tone="danger">Declined</SlimeChip>;
    case RequestStatus.Cancelled:
      return <SlimeChip tone="muted">Cancelled</SlimeChip>;
  }
}

function Slab(props: {
  request: ExtractRequest;
  colors: Map<string, SlimeColor>;
  selected: boolean;
  onSelect: () => void;
}) {
  const { request, colors, selected, onSelect } = props;
  const item = parseItem(request.item);
  const muted =
    CLOSED.includes(request.status) ||
    (request.status === RequestStatus.Claimed && !request.mine);

  return (
    <Button
      className={classes([
        'ExtractOrders__slab',
        muted && 'ExtractOrders__slab--muted',
        request.status === RequestStatus.Waiting &&
          !request.seen &&
          'ExtractOrders__slab--new',
      ])}
      selected={selected}
      onClick={onSelect}
    >
      <Box className="ExtractOrders__slab-art">
        <SlimepediaSprite id={spriteId(item)} scale={1} />
      </Box>
      <Box className="ExtractOrders__slab-text">
        <Box bold>
          {request.count}x {itemName(item, colors)}
        </Box>
        <Box className="ExtractOrders__slab-who">
          {request.requester}, {request.job}
        </Box>
      </Box>
      <Box className="ExtractOrders__slab-well">
        {request.offer > 0 && (
          <SlimeChip tone="caution" icon="coins">
            {request.offer} cr
          </SlimeChip>
        )}
        <SlabChip request={request} />
      </Box>
    </Button>
  );
}

function Orders(props: { catalog: SlimepediaData }) {
  const { catalog } = props;
  const { act, data } = useBackend<ExtractOrdersData>();
  const { requests = [], stock } = data;
  const [tab, setTab] = useState(Tab.Queue);
  const [selectedId, setSelectedId] = useState<number>();

  const colors = useMemo(
    () => new Map(catalog.colors.map((color) => [color.id, color])),
    [catalog],
  );
  const bred = new Set(data.bred);

  const lists: Record<Tab, ExtractRequest[]> = {
    [Tab.Queue]: [
      ...requests.filter((request) => request.status === RequestStatus.Waiting),
      ...requests.filter(
        (request) => request.status === RequestStatus.Claimed && !request.mine,
      ),
    ],
    [Tab.Mine]: requests.filter(
      (request) =>
        !!request.mine &&
        (request.status === RequestStatus.Claimed ||
          request.status === RequestStatus.Ready),
    ),
    [Tab.Closed]: requests
      .filter((request) => CLOSED.includes(request.status))
      .reverse(),
  };
  const list = lists[tab];
  const selected = list.find((request) => request.id === selectedId) ?? list[0];

  const wanted = new Map<string, number>();
  for (const request of requests) {
    if (
      request.status === RequestStatus.Waiting ||
      request.status === RequestStatus.Claimed
    ) {
      wanted.set(request.item, (wanted.get(request.item) ?? 0) + request.count);
    }
  }
  const topWanted = [...wanted].sort((a, b) => b[1] - a[1]).slice(0, 5);

  const tabs = [
    {
      tab: Tab.Queue,
      label: 'Queue',
      count: lists[Tab.Queue].filter(
        (request) => request.status === RequestStatus.Waiting,
      ).length,
    },
    { tab: Tab.Mine, label: 'Mine', count: lists[Tab.Mine].length },
    { tab: Tab.Closed, label: 'Closed', count: 0 },
  ];

  const select = (request: ExtractRequest) => {
    setSelectedId(request.id);
    if (!request.seen) {
      act('see', { id: request.id });
    }
  };

  return (
    <Box className="ExtractOrders__root">
      <Box className="ExtractOrders__head">
        <Tabs className="SlimeRancher__tabs">
          {tabs.map((entry) => (
            <Tabs.Tab
              key={entry.tab}
              selected={tab === entry.tab}
              rightSlot={
                entry.count > 0 && (
                  <Box key={entry.count} className="ExtractRequests__count">
                    {entry.count}
                  </Box>
                )
              }
              onClick={() => setTab(entry.tab)}
            >
              {entry.label}
            </Tabs.Tab>
          ))}
        </Tabs>
        {topWanted.length > 0 && (
          <Box className="ExtractOrders__wanted">
            <Box className="SlimeRancher__heading">Wanted</Box>
            {topWanted.map(([id, total]) => {
              const item = parseItem(id);
              return (
                <Tooltip key={id} content={itemName(item, colors)}>
                  <Box className="ExtractOrders__want">
                    <SlimepediaSprite id={spriteId(item)} scale={1} />x{total}
                  </Box>
                </Tooltip>
              );
            })}
          </Box>
        )}
      </Box>
      <Box className="ExtractOrders__main">
        <Box className="SlimeRancher__card SlimeRancher__scroll ExtractOrders__queue">
          {list.length === 0 ? (
            <Box className="ExtractRequests__empty">
              <Box className="ExtractRequests__empty-socket">?</Box>
              <Box as="h2">Nothing here.</Box>
            </Box>
          ) : (
            list.map((request) => (
              <Slab
                key={request.id}
                request={request}
                colors={colors}
                selected={request === selected}
                onSelect={() => select(request)}
              />
            ))
          )}
        </Box>
        {selected ? (
          <OrderDetails
            request={selected}
            catalog={catalog}
            colors={colors}
            stock={stock}
            bred={bred}
            onClaim={() => {
              act('claim', { id: selected.id });
              setTab(Tab.Mine);
            }}
          />
        ) : (
          <Box />
        )}
      </Box>
    </Box>
  );
}
