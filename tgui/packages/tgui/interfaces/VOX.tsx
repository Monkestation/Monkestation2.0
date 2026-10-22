import { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Section,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';
import { formatTime } from 'tgui-core/format';
import { fetchRetry } from 'tgui-core/http';
import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { logger } from '../logging';

type Data = {
  current_voice: string;
  previous_words: string;
  cooldown: number;
};

// This is in the format of {"voice name": ["mrrp", "mrow", "nya"]}.
type VoiceData = Record<string, string[]>;

enum Tab {
  Announcement,
  Word,
}

export const VOX = () => {
  const [voices, setVoices] = useState<VoiceData | undefined>();
  useEffect(() => {
    fetchRetry(resolveAsset('vox_voices.json'))
      .then((response) => response.json())
      .then((voiceData: VoiceData) => setVoices(voiceData))
      .catch((error) => {
        logger.log('Failed to fetch vox_voices.json', JSON.stringify(error));
      });
  }, []);

  return (
    <Window title="VOX Announcement" width={700} height={300}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="100%">
            <TextAreaSection />
          </Stack.Item>
          <Stack.Item width="60%">
            <SideMenu voices={voices} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TextAreaSection = () => {
  const [message, setMessage] = useLocalState('message', '');

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item height="100%">
          <TextArea
            height="100%"
            width="100%"
            value={message}
            onChange={(value) => setMessage(value)}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SideMenu = (props: { voices?: VoiceData }) => {
  const [tabIndex, setTabIndex] = useState<Tab>(Tab.Announcement);

  return (
    <Section fill>
      <Tabs>
        <Tabs.Tab
          icon="bullhorn"
          width="50%"
          selected={tabIndex === Tab.Announcement}
          onClick={() => setTabIndex(Tab.Announcement)}
        >
          Announcement
        </Tabs.Tab>
        <Tabs.Tab
          icon="info"
          width="50%"
          selected={tabIndex === Tab.Word}
          onClick={() => setTabIndex(Tab.Word)}
        >
          Words
        </Tabs.Tab>
      </Tabs>
      <Divider />
      {tabIndex === Tab.Announcement && (
        <AnnouncementTab voices={props.voices} />
      )}
      {tabIndex === Tab.Word && <WordTab voices={props.voices} />}
    </Section>
  );
};

const AnnouncementTab = (props: { voices?: VoiceData }) => {
  const { act, data } = useBackend<Data>();
  const { cooldown, current_voice } = data;
  const [message] = useLocalState('message', '');

  const voice_names = useMemo(
    () => (props.voices ? Object.keys(props.voices) : []),
    [props.voices],
  );

  return (
    <Section>
      <Stack>
        <Stack.Item width="50%">
          <Button
            align="center"
            width="100%"
            disabled={cooldown > 0 || message.length === 0}
            onClick={() => act('speak', { message })}
          >
            Announce
          </Button>
        </Stack.Item>
        <Stack.Item width="50%">
          <Button
            align="center"
            width="100%"
            disabled={message.length === 0}
            onClick={() => act('test', { message })}
          >
            Preview
          </Button>
        </Stack.Item>
      </Stack>
      <CooldownItem />
      <Divider />
      <Box align="center">Selected Voice</Box>
      <Dropdown
        width="100%"
        selected={current_voice}
        displayText={current_voice}
        options={voice_names}
        onSelected={(voice) => act('set_voice', { voice })}
      />
    </Section>
  );
};

const CooldownItem = () => {
  const {
    data: { cooldown },
  } = useBackend<Data>();

  return (
    <Section align="center">
      {cooldown > 0
        ? `Cooldown Time: ${formatTime(cooldown, 'short')}`
        : 'Cooldown Finished'}
    </Section>
  );
};

const WordTab = (props: { voices?: VoiceData }) => {
  const { data } = useBackend<Data>();
  const { voices } = props;

  if (!voices) {
    return (
      <Section fill scrollable>
        Please wait for the voice data to load...
      </Section>
    );
  }
  const words: string[] = voices[data.current_voice];
  const [message, setMessage] = useLocalState('message', '');

  return (
    <Section fill height="85%" scrollable>
      {words.map((word) => {
        return (
          <Button
            key={word}
            onClick={() => {
              setMessage([message.trim(), word].join(' ').trim());
            }}
          >
            {word}
          </Button>
        );
      })}
    </Section>
  );
};
