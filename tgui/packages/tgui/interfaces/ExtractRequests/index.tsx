import '../../styles/interfaces/ExtractRequests.scss';

import { useMemo, useState } from 'react';
import { Box, Icon, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { SlimeChip } from '../common/SlimeRancher';
import { useSlimepediaData } from '../Slimepedia';
import type { SlimepediaData } from '../Slimepedia/types';
import { CrossbreedsBrowser, ExtractsBrowser } from './Browse';
import { type Item, itemId, itemName } from './items';
import { MyRequests } from './MyRequests';
import { OrderBar } from './OrderBar';
import { type RequesterData, RequestStatus } from './types';

enum Tab {
  Extracts = 'extracts',
  Crossbreeds = 'crossbreeds',
  Requests = 'requests',
}

const TABS = [
  { tab: Tab.Extracts, label: 'Extracts', icon: 'tint' },
  { tab: Tab.Crossbreeds, label: 'Crossbreeds', icon: 'flask' },
  { tab: Tab.Requests, label: 'My requests', icon: 'clipboard-list' },
] as const;

export const ExtractRequests = () => (
  <Window width={780} height={620} theme="slime_rancher">
    <Window.Content fitted className="ExtractRequests">
      <ExtractRequestsBody canPickUp />
    </Window.Content>
  </Window>
);

/** Shared with the PDA app, which can order but can't collect. */
export function ExtractRequestsBody(props: { canPickUp: boolean }) {
  const catalog = useSlimepediaData();

  if (!catalog) {
    return (
      <Box className="ExtractRequests__shell">
        <Box className="ExtractRequests__empty">
          <Icon name="spinner" spin size={3} />
        </Box>
      </Box>
    );
  }
  return <Console catalog={catalog} canPickUp={props.canPickUp} />;
}

function Console(props: { catalog: SlimepediaData; canPickUp: boolean }) {
  const { catalog, canPickUp } = props;
  const { act, data } = useBackend<RequesterData>();
  const { user, requests = [] } = data;
  const [tab, setTab] = useState(Tab.Extracts);
  const [extractId, setExtractId] = useState<string>();
  const [familyId, setFamilyId] = useState<string>();
  const [crossId, setCrossId] = useState<string>();
  const [count, setCount] = useState(1);
  const [reason, setReason] = useState('');
  const [offer, setOffer] = useState(0);

  const colors = useMemo(
    () => new Map(catalog.colors.map((color) => [color.id, color])),
    [catalog],
  );
  // ordered by how far up the tree their source extract is, and only the ones xenobio can hand over
  const families = useMemo(
    () =>
      catalog.families
        .map((family) => ({
          ...family,
          crossbreeds: family.crossbreeds.filter((entry) => entry.orderable),
        }))
        .filter((family) => family.crossbreeds.length > 0)
        .sort(
          (a, b) =>
            (colors.get(a.source)?.tier ?? 0) -
            (colors.get(b.source)?.tier ?? 0),
        ),
    [catalog, colors],
  );
  const bred = new Set(data.bred);
  const extract = colors.get(extractId ?? '') ?? catalog.colors[0];
  const family = families.find((entry) => entry.id === familyId) ?? families[0];
  const crossbreed =
    family.crossbreeds.find((entry) => entry.color === crossId) ??
    family.crossbreeds.find((entry) => entry.color === family.source) ??
    family.crossbreeds[0];

  const ordering: Item =
    tab === Tab.Crossbreeds
      ? { family: family.id, color: crossbreed.color }
      : { family: null, color: extract.id };
  const active = requests.filter(
    (request) =>
      request.status === RequestStatus.Waiting ||
      request.status === RequestStatus.Claimed ||
      request.status === RequestStatus.Ready,
  ).length;

  return (
    <Box className="ExtractRequests__shell">
      <Box className="ExtractRequests__head">
        <Tabs className="SlimeRancher__tabs">
          {TABS.map((entry) => (
            <Tabs.Tab
              key={entry.tab}
              icon={entry.icon}
              selected={tab === entry.tab}
              rightSlot={
                entry.tab === Tab.Requests &&
                active > 0 && (
                  <Box key={active} className="ExtractRequests__count">
                    {active}
                  </Box>
                )
              }
              onClick={() => setTab(entry.tab)}
            >
              {entry.label}
            </Tabs.Tab>
          ))}
        </Tabs>
        <Box className="ExtractRequests__who">
          {user ? (
            <>
              <Icon name="id-card" />
              <Box as="strong">{user.name}</Box>
              {user.job}
              <SlimeChip key={user.balance} tone="caution" icon="coins">
                {user.balance.toLocaleString('en-US')} cr
              </SlimeChip>
            </>
          ) : (
            'Hold your ID card to order'
          )}
        </Box>
      </Box>
      {tab === Tab.Requests ? (
        <MyRequests
          requests={requests}
          colors={colors}
          canPickUp={canPickUp}
          onCancel={(id) => act('cancel', { id })}
          onPickUp={(id) => act('pickup', { id })}
        />
      ) : (
        <>
          {tab === Tab.Extracts ? (
            <ExtractsBrowser
              catalog={catalog}
              bred={bred}
              selected={extract}
              onSelect={setExtractId}
            />
          ) : (
            <CrossbreedsBrowser
              catalog={catalog}
              families={families}
              family={family}
              crossbreed={crossbreed}
              colors={colors}
              bred={bred}
              onFamily={setFamilyId}
              onColor={setCrossId}
            />
          )}
          <OrderBar
            name={itemName(ordering, colors)}
            balance={user ? user.balance : null}
            count={count}
            reason={reason}
            offer={offer}
            onCount={setCount}
            onReason={setReason}
            onOffer={setOffer}
            onSubmit={() => {
              act('request', {
                item: itemId(ordering),
                count,
                reason: reason.trim(),
                offer,
              });
              setCount(1);
              setReason('');
              setOffer(0);
              setTab(Tab.Requests);
            }}
          />
        </>
      )}
    </Box>
  );
}
