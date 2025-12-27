import { useBackend } from '../../backend';
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
} from '../../components';

export const RBMKControls = () => {
  const { data, act } = useBackend<any>();

  /* ---- Core ---- */
  const depth = Number(data?.control_rods ?? 0);
  const running = Boolean(data?.running ?? false);
  const maxRodDepth = Number(data?.max_control_rod ?? 100);

  /* ---- Inlet ---- */
  const inletOpen = Boolean(data?.inlet_open ?? false);
  const inletRate = Number(data?.inlet_rate ?? 1);

  /* ---- Outlet ---- */
  const outletOpen = Boolean(data?.outlet_open ?? false);
  const outletTargetPressure = Number(data?.outlet_target_pressure ?? 101.3);

  return (
    <Flex direction="column" gap={1}>

      {/* Control Rod Depth */}
      <Section title="Control Rod Depth">
        <Flex justify="center" mb={1}>
          <Knob
            size={3}
            minValue={0}
            maxValue={maxRodDepth}
            step={1}
            value={depth}
            onDrag={(_, v) => act('set_rods', { depth: v })}
          />
        </Flex>

        <ProgressBar
          value={depth}
          maxValue={maxRodDepth}
          ranges={{
            good: [0, 30],
            yellow: [30, 70],
            bad: [70, maxRodDepth],
          }}
        >
          {depth}%
        </ProgressBar>

        <Flex justify="space-between" mt={0.5}>
          <Box color="label">0% — Fully Withdrawn</Box>
          <Box color="label">{maxRodDepth}% — Fully Inserted</Box>
        </Flex>

        <Box textAlign="center" mt={1} color={running ? 'good' : 'bad'}>
          {running ? 'RUNNING' : 'SCRAMMED'}
        </Box>
      </Section>

      {/* Emergency Controls */}
      <Section title="Emergency Controls">
        <Flex justify="center">
          <Button
            fluid
            icon="radiation"
            color="bad"
            bold
            content="AZ-5 SCRAM"
            tooltip="Emergency full rod insertion."
            style={{
              fontSize: '1.2em',
              padding: '0.8em',
            }}
            onClick={() =>
              act('set_rods', { depth: maxRodDepth })
            }
          />
        </Flex>
      </Section>

      {/* Coolant Controls */}
      <Section title="Coolant Controls">
        <Stack>

          {/* Inlet */}
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

              <LabeledList.Item label="Input Rate">
                <NumberInput
                  value={inletRate}
                  unit="L/s"
                  width="75px"
                  minValue={1}
                  maxValue={200}
                  step={1}
                  suppressFlicker={2000}
                  onChange={(_, value) =>
                    act('set_inlet_rate', { rate: value })
                  }
                />
              </LabeledList.Item>

              <LabeledList.Item label="Inlet Pressure">
                <Box color="label">Derived from coolant system</Box>
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>

          {/* Outlet */}
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
                  maxValue={10000}
                  step={10}
                  suppressFlicker={2000}
                  onChange={(_, value) =>
                    act('set_outlet_pressure', { pressure: value })
                  }
                />
              </LabeledList.Item>

              <LabeledList.Item label="Outlet Pressure">
                <Box color="label">Derived from coolant system</Box>
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>

        </Stack>
      </Section>
    </Flex>
  );
};

export default RBMKControls;
