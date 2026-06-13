import { Fragment, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

type Data = {
  overclock_progress: number;
  has_cpu: BooleanLike;
  speed: number;
  last_values: LastValuesData[];
  power_multiplier: number;
  power_usage: number;
};

type LastValuesData = {
  speed: number;
  power: number;
  valid: BooleanLike;
};

export const AiOverclocking = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    overclock_progress,
    has_cpu,
    speed,
    last_values = [],
    power_multiplier,
    power_usage,
  } = data;

  const [increment, setIncrement] = useState(0.1);

  const applyResult = (index) => {
    act('set_speed', { new_speed: last_values[index].speed });
    act('set_power', { new_power: last_values[index].power });
  };

  return (
    <Window width={600} height={550}>
      <Window.Content scrollable>
        {(!overclock_progress && (
          <Section
            title="Overclocking"
            buttons={
              <Button color="bad" icon="eject" onClick={() => act('eject_cpu')}>
                Eject CPU
              </Button>
            }
          >
            {(has_cpu && (
              <Fragment>
                <Collapsible title="Past Results">
                  {last_values.map((result, index) => (
                    <Section
                      key={index}
                      title={`Result #${index + 1}`}
                      buttons={
                        <Button icon="check" onClick={() => applyResult(index)}>
                          Apply
                        </Button>
                      }
                    >
                      <LabeledList>
                        <LabeledList.Item label="Clock Speed">
                          {result.speed}THz &nbsp;
                        </LabeledList.Item>
                        <LabeledList.Item label="Power Multiplier">
                          {result.power}THz &nbsp;
                        </LabeledList.Item>
                        <LabeledList.Item label="Valid Overclock">
                          {(result.valid && <Box color="good">Valid</Box>) || (
                            <Box color="bad">Invalid</Box>
                          )}
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  ))}
                </Collapsible>
                <Section
                  title="Settings"
                  buttons={
                    <Button
                      color="good"
                      icon="vial"
                      onClick={() => act('test_overclock')}
                    >
                      Test Overclock
                    </Button>
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label="Increment">
                      <NumberInput
                        value={increment}
                        minValue={0.1}
                        maxValue={1}
                        step={0.1}
                        onChange={(value) => setIncrement(value)}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Clock Speed">
                      {speed}THz &nbsp;
                      <Button
                        icon="minus"
                        onClick={() =>
                          act('set_speed', {
                            new_speed: speed - increment,
                          })
                        }
                      />
                      <NumberInput
                        value={speed}
                        minValue={1}
                        maxValue={10}
                        onChange={(value) =>
                          act('set_speed', {
                            new_speed: value,
                          })
                        }
                      />
                      <Button
                        icon="plus"
                        onClick={() =>
                          act('set_speed', {
                            new_speed: speed + increment,
                          })
                        }
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Power Multiplier">
                      {power_multiplier}x ({power_usage}W)&nbsp;
                      <Button
                        icon="minus"
                        onClick={() =>
                          act('set_power', {
                            new_power:
                              power_multiplier - increment > 0.5
                                ? power_multiplier - increment
                                : 0.5,
                          })
                        }
                      />
                      <NumberInput
                        value={power_multiplier}
                        minValue={0.5}
                        maxValue={5}
                        onChange={(value) =>
                          act('set_power', {
                            new_power: value,
                          })
                        }
                      />
                      <Button
                        icon="plus"
                        onClick={() =>
                          act('set_power', {
                            new_power: power_multiplier + increment,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Fragment>
            )) || <NoticeBox>Please insert a CPU</NoticeBox>}
          </Section>
        )) || (
          <Section title="Overclocking in progress">
            <NoticeBox>Overclocking...</NoticeBox>
            <ProgressBar value={overclock_progress} />
            <Button
              color="bad"
              fluid
              icon="trash"
              mt={0.5}
              onClick={() => act('stop_overclock')}
            >
              Cancel
            </Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
