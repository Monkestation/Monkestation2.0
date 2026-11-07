import hljs from 'highlight.js/lib/core';
import x86asm from 'highlight.js/lib/languages/x86asm';
import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

// hljs 11 throws on an unregistered language name.
hljs.registerLanguage('x86asm', x86asm);

enum Tab {
  Status = 1,
  Tools,
  Assembly,
}

type Data = {
  loaded: BooleanLike;
  armed: BooleanLike;
  hooks_enabled: BooleanLike;
  counting_threshold: number;
  status_text: string | null;
  last_result: string | null;
  asm_proc_path: string | null;
  asm_text: string | null;
};

export function DmeowPanel() {
  const { data } = useBackend<Data>();
  const { loaded, armed, last_result } = data;
  const [tab, setTab] = useState(Tab.Status);

  return (
    <Window title="dmeow" width={720} height={620}>
      <Window.Content>
        <Stack fill vertical>
          {!loaded && (
            <Stack.Item>
              <LoadNotice />
            </Stack.Item>
          )}
          {!!loaded && !armed && (
            <Stack.Item>
              <NoticeBox danger>
                The JIT refused to arm. Every compile silently returns 0, so
                nothing is running compiled. Check Status.
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === Tab.Status}
                onClick={() => setTab(Tab.Status)}
              >
                Status
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Tools}
                onClick={() => setTab(Tab.Tools)}
              >
                Tools
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === Tab.Assembly}
                onClick={() => setTab(Tab.Assembly)}
              >
                Assembly
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === Tab.Status && <StatusTab />}
            {tab === Tab.Tools && <ToolsTab />}
            {tab === Tab.Assembly && <AssemblyTab />}
          </Stack.Item>
          {!!last_result && (
            <Stack.Item>
              <Box color="label" fontSize="0.9em">
                {last_result}
              </Box>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
}

function LoadNotice() {
  const { act } = useBackend<Data>();

  return (
    <NoticeBox info>
      <Stack align="center">
        <Stack.Item grow>dmeow is not loaded.</Stack.Item>
        <Stack.Item>
          <Button icon="plug" onClick={() => act('load')}>
            Load
          </Button>
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
}

function StatusTab() {
  const { act, data } = useBackend<Data>();
  const { armed, hooks_enabled, counting_threshold, status_text } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="State">
          <LabeledList>
            <LabeledList.Item label="JIT" color={armed ? 'good' : 'bad'}>
              {armed ? 'armed' : 'disabled'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Native hooks"
              buttons={
                <Button
                  icon="power-off"
                  selected={hooks_enabled}
                  onClick={() => act('toggle_hooks')}
                >
                  {hooks_enabled ? 'On' : 'Off'}
                </Button>
              }
            >
              {hooks_enabled ? 'compiled procs are being used' : 'bypassed'}
            </LabeledList.Item>
            <LabeledList.Item label="Promotion">
              {counting_threshold ? `after ${counting_threshold} calls` : 'off'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Deopt + debug status"
          buttons={
            <Button icon="rotate" onClick={() => act('refresh_status')}>
              Refresh
            </Button>
          }
        >
          {status_text ? (
            <Box preserveWhitespace fontFamily="monospace" fontSize="0.9em">
              {status_text}
            </Box>
          ) : (
            <Box color="label">
              Not read yet. Each read locks the DLL, so it is on demand.
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function ToolsTab() {
  const { act } = useBackend<Data>();
  const [procName, setProcName] = useState('');
  const [marker, setMarker] = useState('');

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="A single proc">
          <Stack align="center">
            <Stack.Item grow>
              <Input
                fluid
                placeholder="/datum/gas_mixture/proc/share"
                value={procName}
                onChange={setProcName}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="microchip"
                disabled={!procName}
                onClick={() => act('compile', { proc_name: procName })}
              >
                Compile
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-code"
                disabled={!procName}
                onClick={() => act('bytecode', { proc_name: procName })}
              >
                Bytecode
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Dumps">
          <Button icon="list" onClick={() => act('analysis')}>
            Proc analysis
          </Button>
          <Button icon="filter" onClick={() => act('eligible')}>
            Eligibility list
          </Button>
          <Button.Confirm icon="hammer" onClick={() => act('census')}>
            Compile census (stalls!)
          </Button.Confirm>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Debug log">
          <Stack align="center">
            <Stack.Item>
              <Button icon="hard-drive" onClick={() => act('debug_flush')}>
                Flush
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Input
                fluid
                placeholder="marker text..."
                value={marker}
                onChange={setMarker}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="bookmark"
                disabled={!marker}
                onClick={() => act('debug_marker', { text: marker })}
              >
                Mark
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function AssemblyTab() {
  const { act, data } = useBackend<Data>();
  const { asm_proc_path, asm_text } = data;
  const [procName, setProcName] = useState('');

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Optimized x86">
          <Stack align="center">
            <Stack.Item grow>
              <Input
                fluid
                placeholder="/datum/gas_mixture/proc/heat_capacity"
                value={procName}
                onChange={setProcName}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-code"
                disabled={!procName}
                onClick={() => act('dump_asm', { proc_name: procName })}
              >
                Dump
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable scrollableHorizontal title={asm_proc_path}>
          {asm_text ? (
            <Box
              as="pre"
              fontSize="0.9em"
              dangerouslySetInnerHTML={{
                __html: hljs.highlight(sanitizeText(asm_text), {
                  language: 'x86asm',
                }).value,
              }}
            />
          ) : (
            <Box color="label">
              Nothing dumped yet. This compiles the proc for real but throws the
              result away, so it stays interpreted either way.
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
