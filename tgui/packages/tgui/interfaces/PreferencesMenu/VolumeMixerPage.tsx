import { useBackend } from '../../backend';
import { Box, Button, Icon, Section, Slider, Stack } from '../../components';
import type { Channel, PreferencesMenuData } from './data';

export const VolumeMixerPage = () => {
  const { data } = useBackend<PreferencesMenuData>();
  const { channels } = data;

  return (
    <Section title="Volume Mixers" overflow="auto">
      <Stack align="start" direction="row" wrap>
        {channels.map((channel) => (
          <Stack.Item key={channel.num} width={28} style={{ margin: '5px' }}>
            <VolumeSlider channel={channel} />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const VolumeSlider = (props: { channel: Channel }) => {
  const { act } = useBackend<PreferencesMenuData>();
  const { channel } = props;

  return (
    <Box
      backgroundColor="rgba(0, 0, 0, 0.25)"
      style={{
        padding: '5px 10px',
      }}
    >
      <Box fontSize="1.25rem" mt={'0.5rem'}>
        {channel.name}
      </Box>
      <Box mt="0.5rem">
        <Stack>
          <Stack.Item grow={1}>
            <Slider
              minValue={0}
              maxValue={100}
              stepPixelSize={3.13}
              tickWhileDragging
              value={channel.volume}
              onChange={(_, value) =>
                act('volume', {
                  channel: channel.num,
                  volume: value,
                })
              }
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              width="30px"
              color="transparent"
              tooltip="Mute"
              tooltipPosition="bottom"
              ml="5px"
            >
              <Icon
                name="volume-xmark"
                size={1.8}
                onClick={() =>
                  act('volume', { channel: channel.num, volume: 0 })
                }
              />
            </Button>
            <Button
              width="30px"
              color="transparent"
              tooltip="Reset"
              tooltipPosition="bottom"
              ml="3px"
            >
              <Icon
                name="arrow-rotate-right"
                size={1.8}
                onClick={() =>
                  act('volume', { channel: channel.num, volume: 50 })
                }
              />
            </Button>
            <Button
              width="30px"
              color="transparent"
              tooltip="Max"
              tooltipPosition="bottom"
              ml="3px"
            >
              <Icon
                name="volume-up"
                size={1.8}
                onClick={() =>
                  act('volume', {
                    channel: channel.num,
                    volume: 100,
                  })
                }
              />
            </Button>
          </Stack.Item>
        </Stack>
      </Box>
    </Box>
  );
};
