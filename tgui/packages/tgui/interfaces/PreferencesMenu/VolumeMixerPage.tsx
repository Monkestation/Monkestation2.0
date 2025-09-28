import { Fragment } from 'inferno';
import { useBackend } from '../../backend';
import { Box, Button, Flex, Icon, Section, Slider } from '../../components';
import { Channel, PreferencesMenuData } from './data';

export const VolumeMixerPage = () => {
  const { data } = useBackend<PreferencesMenuData>();
  const { channels } = data;

  return (
    <Section title="Volume Mixers" height="100%" overflow="auto">
      <Flex align="start" direction="row" wrap>
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
    </Section>
  );
};

const VolumeSlider = (props: { channel: Channel }) => {
  const { act } = useBackend<PreferencesMenuData>();
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
