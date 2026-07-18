import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from '../../components';

export const RBMKControls = () => {
  const { data, act } = useBackend<any>();

  const depth = Number(data?.control_rods ?? 0);
  const targetDepth = Number(data?.control_rods_target ?? depth);
  const running = Boolean(data?.running ?? false);
  const scrammed = Boolean(data?.scrammed ?? false);
  const az5Expended = Boolean(data?.az5_expended ?? false);
  const maxRodDepth = Number(data?.max_control_rod ?? 100);

  const inletOpen = Boolean(data?.inlet_open ?? false);
  const inletRate = Number(data?.inlet_rate ?? 750);
  const inletMin = Number(data?.inlet_min ?? 0);
  const inletMax = Number(data?.inlet_max ?? 2000);
  const inletPressure = Number(data?.inlet_pressure ?? 0);
  const inletFlow = Number(data?.inlet_flow ?? 0);

  const outletOpen = Boolean(data?.outlet_open ?? false);
  const outletTargetPressure = Number(data?.outlet_target_pressure ?? 1500);
  const outletPressureMax = Number(data?.outlet_pressure_max ?? 5500);
  const outletPressure = Number(data?.outlet_pressure ?? 0);
  const outletCorePressure = Number(data?.outlet_core_pressure ?? 0);
  const outletFlow = Number(data?.outlet_flow ?? 0);
  const pressureCurrent = Number(data?.pressure_current ?? outletCorePressure);
  const pressureWarning = Number(data?.pressure_warning ?? 6000);
  const pressureCritical = Number(data?.pressure_critical ?? 7200);
  const coolantMoles = Number(data?.coolant_moles ?? 0);
  const coolantTemperature = Number(data?.coolant_temperature ?? 0);
  const coolantExchangeRatio = Number(data?.coolant_exchange_ratio ?? 0);
  const coolantCoreTempChange = Number(data?.coolant_core_temp_change ?? 0);
  const coolantTemperatureChange = Number(
    data?.coolant_temperature_change ?? 0,
  );

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

  const sendRodTarget = (value: number) => {
    if (!Number.isFinite(value)) {
      return;
    }

    act('set_rods', {
      depth: value,
    });
  };

  return (
    <Flex direction="column" gap={1}>
      <Section title="Control Rod Depth">
        <Box mb={0.5} color="label">
          Actual Position
        </Box>
        <ProgressBar
          value={depth}
          maxValue={maxRodDepth}
          ranges={{
            bad: [0, maxRodDepth * 0.3],
            yellow: [maxRodDepth * 0.3, maxRodDepth * 0.7],
            good: [maxRodDepth * 0.7, maxRodDepth],
          }}
        >
          {depth.toFixed(0)}%
        </ProgressBar>

        <Box mt={1} mb={0.5} color="label">
          Commanded Position
        </Box>
        <ProgressBar
          value={targetDepth}
          maxValue={maxRodDepth}
          ranges={{
            bad: [0, maxRodDepth * 0.3],
            yellow: [maxRodDepth * 0.3, maxRodDepth * 0.7],
            good: [maxRodDepth * 0.7, maxRodDepth],
          }}
        >
          {targetDepth.toFixed(0)}%
        </ProgressBar>

        <Flex justify="space-between" mt={0.5}>
          <Box color="label">0% — Fully Withdrawn</Box>
          <Box color="label">{maxRodDepth}% — Fully Inserted</Box>
        </Flex>

        <Box
          textAlign="center"
          mt={1}
          color={scrammed ? 'bad' : running ? 'good' : 'label'}
        >
          {scrammed ? 'SCRAMMED' : running ? 'RUNNING' : 'IDLE'}
        </Box>

        <Flex justify="space-between" mt={1}>
          <Button
            icon="arrow-up"
            content="Raise"
            onClick={() => act('rod_up')}
          />
          <NumberInput
            value={targetDepth}
            unit="%"
            width="82px"
            minValue={0}
            maxValue={maxRodDepth}
            step={5}
            onChange={sendRodTarget}
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
            color={az5Expended ? 'label' : 'bad'}
            bold
            disabled={az5Expended}
            content={az5Expended ? 'AZ-5 EXPENDED' : '☢AZ-5☢'}
            tooltip={
              az5Expended
                ? 'The destructive shutdown mechanism has already fired.'
                : 'Single-use emergency full rod insertion. This destroys the mechanism.'
            }
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
                  unit="mol/s"
                  width="90px"
                  minValue={inletMin}
                  maxValue={inletMax}
                  step={25}
                  onChange={sendInletRate}
                />
              </LabeledList.Item>

              <LabeledList.Item label="Inlet Pressure">
                <Box>{inletPressure.toFixed(2)} kPa</Box>
              </LabeledList.Item>

              <LabeledList.Item label="Inlet Flow">
                <Box>{inletFlow.toFixed(1)} mol/s</Box>
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

              <LabeledList.Item label="Core Pressure">
                <Box>{outletCorePressure.toFixed(2)} kPa</Box>
              </LabeledList.Item>

              <LabeledList.Item label="Outlet Flow">
                <Box>{outletFlow.toFixed(1)} mol/s</Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>

          <Section title="Coolant Inventory">
            <LabeledList>
              <LabeledList.Item label="Core Pressure">
                <ProgressBar
                  value={pressureCurrent}
                  maxValue={Math.max(pressureCritical, pressureCurrent, 1)}
                  ranges={{
                    good: [0, pressureWarning],
                    yellow: [pressureWarning, pressureCritical],
                    bad: [
                      pressureCritical,
                      Math.max(pressureCritical, pressureCurrent, 1),
                    ],
                  }}
                >
                  {pressureCurrent.toFixed(1)} kPa
                </ProgressBar>
              </LabeledList.Item>

              <LabeledList.Item label="Coolant Moles">
                <Box>{coolantMoles.toFixed(1)} mol</Box>
              </LabeledList.Item>

              <LabeledList.Item label="Coolant Temp">
                <Box>{coolantTemperature.toFixed(1)} K</Box>
              </LabeledList.Item>

              <LabeledList.Item label="Heat Exchange">
                <ProgressBar
                  value={coolantExchangeRatio}
                  maxValue={100}
                  ranges={{
                    bad: [0, 20],
                    yellow: [20, 55],
                    good: [55, 100],
                  }}
                >
                  {coolantExchangeRatio.toFixed(1)}%
                </ProgressBar>
              </LabeledList.Item>

              <LabeledList.Item label="Core Transfer">
                <Box color={coolantCoreTempChange >= 0 ? 'good' : 'bad'}>
                  {coolantCoreTempChange.toFixed(1)} K/tick
                </Box>
              </LabeledList.Item>

              <LabeledList.Item label="Coolant Transfer">
                <Box color={coolantTemperatureChange >= 0 ? 'bad' : 'good'}>
                  {coolantTemperatureChange.toFixed(1)} K/tick
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Flex>
      </Section>
    </Flex>
  );
};

export default RBMKControls;
