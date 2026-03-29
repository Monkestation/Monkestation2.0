import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, NumberInput, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

export const Signaler = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={280} height={132}>
      <Window.Content>
        <SignalerContent />
      </Window.Content>
    </Window>
  );
};

export const SignalerContent = (props) => {
  const { act, data } = useBackend();
  const { code, frequency, cooldown, minFrequency, maxFrequency } = data;
  const color = 'rgba(13, 13, 213, 0.7)';
  const backColor = 'rgba(0, 0, 69, 0.5)';
  return (
    <Section>
      <Stack>
        <Stack.Item grow size={1.4} color="label">
          Frequency:
        </Stack.Item>
        <Stack.Item>
          <NumberInput
            animate
            unit="kHz"
            step={0.2}
            stepPixelSize={6}
            minValue={minFrequency / 10}
            maxValue={maxFrequency / 10}
            value={frequency / 10}
            format={(value) => toFixed(value, 1)}
            width="80px"
            tickWhileDragging
            onChange={(value) =>
              act('freq', {
                freq: value,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            ml={1.3}
            icon="sync"
            content="Reset"
            onClick={() =>
              act('reset', {
                reset: 'freq',
              })
            }
          />
        </Stack.Item>
      </Stack>
      <Stack mt={0.6}>
        <Stack.Item grow size={1.4} color="label">
          Code:
        </Stack.Item>
        <Stack.Item>
          <NumberInput
            animate
            step={1}
            stepPixelSize={6}
            minValue={1}
            maxValue={100}
            value={code}
            width="80px"
            tickWhileDragging
            onChange={(value) =>
              act('code', {
                code: value,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            ml={1.3}
            icon="sync"
            content="Reset"
            onClick={() =>
              act('reset', {
                reset: 'code',
              })
            }
          />
        </Stack.Item>
      </Stack>
      <Table mt={0.8}>
        <Stack.Item>
          <Button
            mb={-0.1}
            fluid
            tooltip={cooldown && `Cooldown: ${cooldown * 0.1} seconds`}
            icon="arrow-up"
            content="Send Signal"
            textAlign="center"
            onClick={() => act('signal')}
          />
        </Stack.Item>
      </Table>
    </Section>
  );
};
