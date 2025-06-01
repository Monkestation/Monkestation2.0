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

type Data = {
  current_voice: string;
  previous_words: string;
  cooldown: number;
};

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
      <Window title="VOX Announcement" width={700} height={300}>
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
  const { act, data } = useBackend<Data>();
  const { previous_words } = data;

  return (
    <Section fill>
      <Stack vertical fill>
        <Stack.Item />
        <Stack.Item height="100%">
          <TextArea
            scrollbar
            height="100%"
            value={previous_words}
            // Attempt to save the text when user types
            onInput={(e, value) =>
              act('save_text', {
                message: value,
              })
            }
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SideMenu = (props) => {
  const [tabIndex, setTabIndex] = useLocalState('tabIndex', 1);

  return (
    <Section fill>
      <Tabs>
        <Tabs.Tab
          icon="bullhorn"
          width="50%"
          selected={tabIndex === 1}
          onClick={() => setTabIndex(1)}
        >
          Announcement Tab
        </Tabs.Tab>
        <Tabs.Tab
          icon="info"
          width="50%"
          selected={tabIndex === 2}
          onClick={() => setTabIndex(2)}
        >
          Word Tab
        </Tabs.Tab>
      </Tabs>
      <Divider />
      {tabIndex === 1 && <AnnouncementTab />}
      {tabIndex === 2 && <WordTab />}
    </Section>
  );
};

const AnnouncementTab = (_props) => {
  const { act, data } = useBackend<Data>();
  const { cooldown, previous_words, current_voice } = data;

  let voice_names = voices ? Object.keys(voices) : [];

  return (
    <Section>
      <Stack>
        <Stack.Item width="100%">
          {/* Disable announcement button if the cooldown is not finished */}
          <Button
            align="center"
            width="100%"
            disabled={cooldown > 0}
            onClick={() =>
              act('speak', {
                message: previous_words,
              })
            }
          >
            Announce
          </Button>
        </Stack.Item>
        <Stack.Item width="100%">
          <Button
            align="center"
            width="100%"
            onClick={() =>
              act('test', {
                message: previous_words,
              })
            }
          >
            Test Text
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
        // Attempt to set selected option as new voice
        onSelected={(e) =>
          act('set_voice', {
            voice: e,
          })
        }
      />
    </Section>
  );
};

const CooldownItem = (props) => {
  const { data } = useBackend<Data>();
  const { cooldown } = data;

  // If the cooldown is not finished, show the remaining time
  if (cooldown > 0) {
    return <Section align="Center">Cooldown Time: {cooldown}</Section>;
  } else {
    return <Section align="Center">Cooldown Finished</Section>;
  }
};

const WordTab = (props) => {
  const { data } = useBackend<Data>();

  return (
    <Section fill scrollable>
      List of words goes here
    </Section>
  );
};
