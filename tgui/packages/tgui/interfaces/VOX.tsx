import { useBackend, useLocalState } from '../backend';
import {
  Stack,
  Box,
  Section,
  TextArea,
  Tabs,
  Divider,
  Button,
  Dropdown,
} from '../components';
import { Window } from '../layouts';
import { Component } from 'inferno';
import { fetchRetry } from '../http';
import { resolveAsset } from '../assets';
import { formatTime } from '../format';

type Data = {
  current_voice: string;
  previous_words: string;
  cooldown: number;
};

enum Tab {
  Announcement,
  Word,
}

// Cache response so it's only sent once
// this is in the format of {"voice name": ["mrrp", "mrow", "nya"]}
let voices: Record<string, string[]> | undefined;

export class VOX extends Component {
  componentDidMount() {
    this.fetchVoices();
  }

  async fetchVoices() {
    const response = await fetchRetry(resolveAsset('vox_voices.json'));
    voices = await response.json();
  }

  render() {
    return (
      <Window title="VOX Announcement" fixed width={700} height={300}>
        <Window.Content>
          <Stack fill>
            <Stack.Item width="100%">
              <TextAreaSection />
            </Stack.Item>
            <Stack.Item width="60%">
              <SideMenu />
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
}

const TextAreaSection = (props) => {
  const [message, setMessage] = useLocalState('message', '');

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item height="100%">
          <TextArea
            scrollbar
            height="100%"
            value={message}
            onInput={(_, value) => setMessage(value)}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SideMenu = () => {
  const [tabIndex, setTabIndex] = useLocalState<Tab>(
    'tabIndex',
    Tab.Announcement,
  );

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
      {tabIndex === Tab.Announcement && <AnnouncementTab />}
      {tabIndex === Tab.Word && <WordTab />}
    </Section>
  );
};

const AnnouncementTab = () => {
  const { act, data } = useBackend<Data>();
  const { cooldown, current_voice } = data;
  const [message] = useLocalState('message', '');

  let voice_names = voices ? Object.keys(voices) : [];

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

const WordTab = () => {
  const { data } = useBackend<Data>();

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
            content={word}
            onClick={() => {
              setMessage([message.trim(), word].join(' ').trim());
            }}
          />
        );
      })}
    </Section>
  );
};
