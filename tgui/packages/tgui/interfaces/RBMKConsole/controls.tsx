import { useBackend } from '../../backend';
import {
  Section,
  Button,
  LabeledList,
  NumberInput,
  Flex,
  Box,
  ProgressBar,
} from '../../components';

export const RBMKControls = () => {
  const { data, act } = useBackend<any>();

  const depth = Number(data?.control_rods ?? 0);
  const running = Boolean(data?.running ?? false);
  const scrammed = Boolean(data?.scrammed ?? false);
  const maxRodDepth = Number(data?.max_control_rod ?? 100);

  const inletOpen = Boolean(data?.inlet_open ?? false);
  const inletRate = Number(data?.inlet_rate ?? 1);
  const inletMin = Number(data?.inlet_min ?? 1);
  const inletMax = Number(data?.inlet_max ?? 250);
  const inletPressure = Number(data?.inlet_pressure ?? 0);

  const outletOpen = Boolean(data?.outlet_open ?? false);
  const outletTargetPressure = Number(data?.outlet_target_pressure ?? 101.3);
  const outletPressureMax = Number(data?.outlet_pressure_max ?? 1200);
  const outletPressure = Number(data?.outlet_pressure ?? 0);

  const sendInletRate = (value: number) => {
    if (!Number.isFinite(value)) {
      return;
    }

    act('set_inlet_rate', {
      rate: Math.round(value),
    });
  };

  const sendOutletPressure = (value: number) => {
    if (!Number.isFinite(value)) {
      return;
    }

    act('set_outlet_pressure', {
      pressure: value,
    });
  };

  return (
    <Flex direction="column" gap={1}>
      <Section title="Control Rod Depth">
        <ProgressBar
          value={depth}
          maxValue={maxRodDepth}
          ranges={{
            bad: [0, maxRodDepth * 0.3],
            yellow: [maxRodDepth * 0.3, maxRodDepth * 0.7],
            good: [maxRodDepth * 0.7, maxRodDepth],
          }}>
          {depth.toFixed(0)}%
        </ProgressBar>

        <Flex justify="space-between" mt={0.5}>
          <Box color="label">0% — Fully Withdrawn</Box>
          <Box color="label">{maxRodDepth}% — Fully Inserted</Box>
        </Flex>

        <Box
          textAlign="center"
          mt={1}
          color={scrammed ? 'bad' : running ? 'good' : 'label'}>
          {scrammed ? 'SCRAMMED' : running ? 'RUNNING' : 'IDLE'}
        </Box>

        <Flex justify="space-between" mt={1}>
          <Button
            icon="arrow-up"
            content="Raise"
            onClick={() => act('rod_up')}
          />
          <Button
            icon="arrow-down"
            content="Lower"
            onClick={() => act('rod_down')}
          />
        </Flex>
      </Section>

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
            onClick={() => act('scram')}
          />
        </Flex>
      </Section>

      <Section title="Coolant Controls">
        <Flex direction="column" gap={1}>
          <Section title="Inlet">
            <LabeledList>
              <LabeledList.Item label="Injector">
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
                  width="80px"
                  minValue={inletMin}
                  maxValue={inletMax}
                  step={1}
                  onChange={sendInletRate}
                />
              </LabeledList.Item>

              <LabeledList.Item label="Inlet Pressure">
                <Box>{inletPressure.toFixed(2)} kPa</Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>

          <Section title="Outlet">
            <LabeledList>
              <LabeledList.Item label="Regulator">
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
                  step={10}
                  onChange={sendOutletPressure}
                />
              </LabeledList.Item>

              <LabeledList.Item label="Outlet Pressure">
                <Box>{outletPressure.toFixed(2)} kPa</Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex>
      </Section>
    </Flex>
  );
};

export default RBMKControls;
