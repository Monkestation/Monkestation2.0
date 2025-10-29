import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  rate: number;
  max_heat_transfer_rate: number;
  temperature: number;
  min_temperature: number;
  max_temperature: number;
};

export const AtmosTempPump = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    on,
    rate,
    max_heat_transfer_rate,
    temperature,
    min_temperature,
    max_temperature,
  } = data;

  return (
    <Window width={345} height={140}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Heat transfer rate">
              <NumberInput
                animated
                value={rate}
                unit="%"
                width="75px"
                minValue={0}
                maxValue={max_heat_transfer_rate}
                step={1}
                onChange={(e, value) =>
                  act('rate', {
                    rate: value,
                  })
                }
              />
              <Button
                ml={1}
                icon="plus"
                content="Max"
                disabled={rate === max_heat_transfer_rate}
                onClick={() =>
                  act('rate', {
                    rate: 'max',
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Heat settings">
              <NumberInput
                animated
                value={temperature}
                unit="K"
                width="75px"
                minValue={min_temperature}
                maxValue={max_temperature}
                step={1}
                onChange={(e, value) =>
                  act('temperature', {
                    temperature: value,
                  })
                }
              />
              <Button
                ml={1}
                icon="plus"
                content="Max"
                disabled={temperature === max_temperature}
                onClick={() =>
                  act('temperature', {
                    temperature: 'tmax',
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
