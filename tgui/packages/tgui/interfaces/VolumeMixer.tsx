import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, Section, Slider, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  channels: Channel[];
};

type Channel = {
  num: number;
  name: string;
  volume: number;
};

export const VolumeMixer = (properties) => {
  return (
    <Window width={800} height={800}>
      <Window.Content>
        <Section height="100%" overflow="auto">
          <Stack horizontal>
            <Stack.Item>
              <SettingsCatergories />
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <VolumeMixerPage />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SettingsCatergories = () => {
  return (
    <Stack vertical>
      <Stack.Item>
        <Button>Quick Settings</Button>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>Settings</Stack.Item>
      <Stack.Item>
        <Button>General</Button>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Button>Key Bindings</Button>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Button>Volume Mixer</Button>
      </Stack.Item>
    </Stack>
  );
};

export const VolumeMixerPage = () => {
  // return <Box>text</Box>;
  const { act, data } = useBackend<Data>();
  const { channels } = data;

  return (
    <Flex align="start" direction="row" wrap minWidth={60}>
      {channels.map((channel) => (
        <Flex.Item
          key={channel.num}
          width={25}
          style={{ margin: '10px 10px 10px 10px' }}
        >
          <VolumeSlider channel={channel} />
        </Flex.Item>
      ))}
    </Flex>
  );
};

const VolumeSlider = (props: { channel: Channel }) => {
  const { act, data } = useBackend<Data>();
  const { channel } = props;

  return (
    <Fragment>
      <Box fontSize="1.25rem" color="label" mt={'0.5rem'}>
        {channel.name}
      </Box>
      <Box mt="0.5rem">
        <Flex>
          <Flex.Item>
            <Button width="24px" color="transparent">
              <Icon
                name="volume-off"
                size={1.5}
                mt="0.1rem"
                onClick={() =>
                  act('volume', { channel: channel.num, volume: 1 })
                }
              />
            </Button>
          </Flex.Item>
          <Flex.Item grow="1" mx="1rem">
            <Slider
              minValue={1}
              maxValue={100}
              stepPixelSize={3.13}
              value={channel.volume}
              onChange={(e, value) =>
                act('volume', {
                  channel: channel.num,
                  volume: value,
                })
              }
            />
          </Flex.Item>
          <Flex.Item>
            <Button width="24px" color="transparent">
              <Icon
                name="volume-up"
                size={1.5}
                mt="0.1rem"
                onClick={() =>
                  act('volume', {
                    channel: channel.num,
                    volume: 100,
                  })
                }
              />
            </Button>
          </Flex.Item>
        </Flex>
      </Box>
    </Fragment>
  );
};
