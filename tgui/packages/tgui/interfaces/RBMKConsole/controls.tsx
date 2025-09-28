import { useBackend } from 'tgui/backend';
import {
  Section,
  Button,
  LabeledList,
  NumberInput,
  Stack,
  Box,
  Knob,
  ProgressBar,
  Flex,
} from 'tgui/components';

export const RBMKControls = () => {
  const { data, act } = useBackend<any>();

  // Core data
  const depth = Number(data?.control_rods ?? 0);

  // Inlet
  const inletOpen = Boolean(data?.inlet_open ?? false);
  const inletRate = Number(data?.inlet_rate ?? 1);
  const inletPressure = Number(data?.inlet_pressure ?? 0); // actual pressure
  const inletMin = Number(data?.inlet_min ?? 0);
  const inletMax = Number(data?.inlet_max ?? 200);

  // Outlet
  const outletOpen = Boolean(data?.outlet_open ?? false);
  const outletTargetPressure = Number(data?.outlet_target_pressure ?? 101.3);
  const outletPressure = Number(data?.outlet_pressure ?? 0); // actual pressure
  const outletPressureMax = Number(data?.outlet_pressure_max ?? 10000);

  return (
    <Flex direction="column" gap={1}>
      {/* Control Rod Depth */}
      <Section title="Control Rod Depth">
        <Flex justify="center" mb={1}>
          <Knob
            size={3}
            minValue={0}
            maxValue={100}
            step={1}
            value={depth}
            onDrag={(_, v) => act('set_rods', { depth: v })}
          />
        </Flex>
        <ProgressBar
          value={depth}
          maxValue={100}
          ranges={{
            good: [0, 30],
            yellow: [30, 70],
            bad: [70, 100],
          }}
        >
          {depth}%
        </ProgressBar>
        <Flex justify="space-between" mt={0.5}>
          <Box color="label">0% — Fully Withdrawn</Box>
          <Box color="label">100% — Fully Inserted</Box>
        </Flex>
      </Section>

      {/* Emergency Controls */}
      <Section title="Emergency Controls">
        <Flex justify="center">
          <Button
            fluid
            color="bad"
            content="AZ-5"
            bold
            style={{
              fontSize: '1.2em',
              padding: '0.8em',
              textAlign: 'center',
            }}
            onClick={() => act('scram')}
          />
        </Flex>
      </Section>

      {/* Coolant Controls */}
      <Section title="Coolant Controls">
        <Stack>
          {/* Inlet injector + rate + actual pressure */}
          <Stack.Item grow>
            <LabeledList>
              <LabeledList.Item label="Inlet Injector">
                <Button
                  content={inletOpen ? 'Injecting' : 'Off'}
                  selected={inletOpen}
                  color={inletOpen ? 'good' : 'bad'}
                  onClick={() => act('toggle_inlet')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Input Rate (Target)">
                <NumberInput
                  value={inletRate}
                  unit="L/s"
                  width="75px"
                  minValue={inletMin}
                  maxValue={inletMax}
                  step={1}
                  onChange={(v) => act('set_inlet_rate', { rate: v })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Inlet Pressure (Actual)">
                {inletPressure.toFixed(1)} kPa
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>

          {/* Outlet regulator + target + actual pressure */}
          <Stack.Item grow>
            <LabeledList>
              <LabeledList.Item label="Outlet Regulator">
                <Button
                  content={outletOpen ? 'Open' : 'Closed'}
                  selected={outletOpen}
                  color={outletOpen ? 'good' : 'bad'}
                  onClick={() => act('toggle_outlet')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Target Pressure">
                <NumberInput
                  value={outletTargetPressure}
                  unit="kPa"
                  width="90px"
                  minValue={0}
                  maxValue={outletPressureMax}
                  step={1}
                  onChange={(v) =>
                    act('set_outlet_pressure', { pressure: v })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Outlet Pressure (Actual)">
                {outletPressure.toFixed(1)} kPa
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Section>
    </Flex>
  );
};

export default RBMKControls;
