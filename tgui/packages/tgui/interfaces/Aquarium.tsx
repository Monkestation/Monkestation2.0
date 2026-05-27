import type { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, Flex, Knob, LabeledControls, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  temperature: number;
  fluid_type: string;
  minTemperature: number;
  maxTemperature: number;
  fluidTypes: string[];
  contents: { ref: string; name: string }[];
  allow_breeding: BooleanLike;
};

export const Aquarium = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    temperature,
    fluid_type,
    minTemperature,
    maxTemperature,
    fluidTypes,
    contents,
    allow_breeding,
  } = data;

  return (
    <Window width={500} height={400}>
      <Window.Content>
        <Section title="Aquarium Controls">
          <LabeledControls>
            <LabeledControls.Item label="Temperature">
              <Knob
                mt={3}
                size={1.5}
                mb={1}
                value={temperature}
                unit="K"
                minValue={minTemperature}
                maxValue={maxTemperature}
                step={1}
                stepPixelSize={1}
                tickWhileDragging
                onChange={(_, value) =>
                  act('temperature', {
                    temperature: value,
                  })
                }
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Fluid">
              <Flex direction="column" mb={1}>
                {fluidTypes.map((f) => (
                  <Flex.Item key={f}>
                    <Button
                      fluid
                      selected={fluid_type === f}
                      onClick={() => act('fluid', { fluid: f })}
                    >
                      {f}
                    </Button>
                  </Flex.Item>
                ))}
              </Flex>
            </LabeledControls.Item>
            <LabeledControls.Item label="Reproduction Prevention System">
              <Button
                selected={!allow_breeding}
                onClick={() => act('allow_breeding')}
              >
                {allow_breeding ? 'Offline' : 'Online'}
              </Button>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section title="Contents">
          {contents.map((movable) => (
            <Button
              key={movable.ref}
              content={movable.name}
              onClick={() => act('remove', { ref: movable.ref })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
