import { useBackend, useLocalState } from '../backend';
import { Dropdown, LabeledList, Section, Stack } from '../components';
import { Button, ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

// ---- Types ----

export interface SoundQueryEntry {
  file: string | null;
  channel: number;
  repeat: number;
  status: number;
  offset: number;
  len: number;
  wait: number;
}

export interface SoundQueryClient {
  ckey: string;
  key: string;
  name: string;
}

export interface SoundQueryDebugData {
  clients: SoundQueryClient[];
  selected: string | null;
  results: SoundQueryEntry[];
}

// ---- Component ----

export const SoundQueryDebug = () => {
  const { act, data } = useBackend<SoundQueryDebugData>();
  const { clients = [], selected = null, results = [] } = data;

  const [persistMissing, setPersistMissing] = useLocalState<boolean>(
    'persistMissing',
    false,
  );

  const [cached, setCached] = useLocalState<Record<number, SoundQueryEntry>>(
    'cachedSounds',
    {},
  );

  const nextCache = { ...cached };
  const activeChannels = new Set<number>();

  for (const s of results) {
    nextCache[s.channel] = s;
    activeChannels.add(s.channel);
  }

  const clearCache = () => {
    for (const ch in nextCache) {
      if (!activeChannels.has(Number(ch))) {
        delete nextCache[ch];
      }
    }
  };

  if (!persistMissing) {
    clearCache();
  }

  // Only write if something actually changed
  const cacheChanged =
    Object.keys(nextCache).length !== Object.keys(cached).length ||
    results.some((s) => cached[s.channel] !== s);

  if (cacheChanged) {
    setCached(nextCache);
  }

  const displayed = Object.values(nextCache).sort(
    (a, b) => a.channel - b.channel,
  );

  return (
    <Window width={750} height={550} title="SoundQuery Debug">
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Dropdown
              width="100%"
              displayText={
                (() => {
                  const c = clients.find((e) => e.ckey === selected);
                  return c ? `${c.key} (${c.name})` : selected;
                })() || selected
              }
              selected={selected}
              options={clients.map((c) => ({
                displayText: `${c.key} (${c.name})`,
                value: c.ckey,
              }))}
              onSelected={(ckey) => act('select_client', { ckey })}
            />
          </Stack.Item>

          <Stack.Item>
            <Button onClick={clearCache}>Clear</Button>
            <ButtonCheckbox
              checked={persistMissing}
              onClick={() => setPersistMissing(!persistMissing)}
            >
              Persist missing entries
            </ButtonCheckbox>
          </Stack.Item>

          {displayed.map((s) => {
            const isStale = !results.some((r) => r.channel === s.channel);

            return (
              <Stack.Item key={s.channel}>
                <Section
                  title={`Channel ${s.channel}${isStale ? ' (stopped)' : ''}`}
                >
                  <LabeledList>
                    <LabeledList.Item label="File">
                      {s.file ?? '<null>'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Repeat">
                      {s.repeat}
                    </LabeledList.Item>
                    <LabeledList.Item label="Status">
                      {s.status}
                    </LabeledList.Item>
                    <LabeledList.Item label="Offset (s)">
                      {s.offset.toFixed(2)}
                    </LabeledList.Item>
                    <LabeledList.Item label="Length (s)">
                      {s.len.toFixed(2)}
                    </LabeledList.Item>
                    <LabeledList.Item label="Queued (s)">
                      {s.wait.toFixed(2)}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
            );
          })}
        </Stack>
      </Window.Content>
    </Window>
  );
};
