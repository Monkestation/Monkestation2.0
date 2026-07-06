import { useBackend } from '../../backend';
import {
  Box,
  Flex,
  LabeledControls,
  LabeledList,
  ProgressBar,
  RoundGauge,
  Section,
} from '../../components';

export const RBMKOverview = () => {
  const { data } = useBackend<any>();

  const temperature = Number(data?.temperature ?? 0);
  const baseMaxTemp = Number(data?.max_temp ?? 20000);
  const maxTemp = Math.max(baseMaxTemp, temperature);

  const radiation = Number(data?.radiation ?? 0);
  const backendMaxRadiation = Number(data?.max_radiation ?? 10000);
  const maxRadiation = Math.max(backendMaxRadiation, 10000);

  const flux = Number(data?.flux ?? 0);
  const maxFlux = Number(data?.max_flux ?? 900);
  const baseFlux = Number(data?.base_flux ?? 0);
  const voidFluxBonus = Number(data?.void_flux_bonus ?? 0);

  const voidCoefficient = Number(data?.void_coefficient ?? 0);
  const maxVoidCoefficient = Math.max(
    Number(data?.max_void_coefficient ?? 0.5),
    0.5,
  );
  const voidFluxMultiplier = Number(data?.void_flux_multiplier ?? 1);
  const voidTemperatureComponent = Number(
    data?.void_temperature_component ?? 0,
  );
  const voidPressureComponent = Number(data?.void_pressure_component ?? 0);
  const voidCoolantComponent = Number(data?.void_coolant_component ?? 0);

  const pressure = Number(data?.pressure_current ?? 0);
  const pressureWarning = Number(data?.pressure_warning ?? 950);
  const pressureCritical = Number(data?.pressure_critical ?? 1500);
  const pressureExtreme = Number(data?.pressure_extreme ?? 2000);
  const maxPressure = Math.max(pressureExtreme, pressure);

  const integrity = Number(data?.integrity ?? 0);
  const maxIntegrity = Math.max(1, Number(data?.max_integrity ?? 100));
  const integrityPercent = Math.max(
    0,
    Math.min(100, Math.round((integrity / maxIntegrity) * 100)),
  );
  const lastIntegrityDamage = Number(data?.last_integrity_damage ?? 0);

  return (
    <Flex direction="column" gap={1}>
      <Section title="Reactor Parameters">
        <LabeledControls justify="space-around" wrap>
          <LabeledControls.Item label="Temperature">
            <RoundGauge
              size={2}
              value={temperature}
              minValue={0}
              maxValue={maxTemp}
              format={(value) => `${value.toFixed(0)} K`}
              ranges={{
                good: [0, maxTemp * 0.3],
                yellow: [maxTemp * 0.3, maxTemp * 0.7],
                bad: [maxTemp * 0.7, maxTemp],
              }}
            />
          </LabeledControls.Item>

          <LabeledControls.Item label="Pressure">
            <RoundGauge
              size={2}
              value={pressure}
              minValue={0}
              maxValue={maxPressure}
              format={(value) => `${value.toFixed(1)} kPa`}
              ranges={{
                good: [0, pressureWarning],
                yellow: [pressureWarning, pressureCritical],
                bad: [pressureCritical, maxPressure],
              }}
            />
          </LabeledControls.Item>

          <LabeledControls.Item label="Void Coefficient">
            <RoundGauge
              size={2}
              value={voidCoefficient}
              minValue={0}
              maxValue={maxVoidCoefficient}
              format={(value) => value.toFixed(3)}
              ranges={{
                good: [0, maxVoidCoefficient * 0.35],
                yellow: [maxVoidCoefficient * 0.35, maxVoidCoefficient * 0.7],
                bad: [maxVoidCoefficient * 0.7, maxVoidCoefficient],
              }}
            />
          </LabeledControls.Item>

          <LabeledControls.Item label="Röntgen">
            <RoundGauge
              size={2}
              value={radiation}
              minValue={0}
              maxValue={maxRadiation}
              format={(value) => `${value.toFixed(1)} R`}
              ranges={{
                good: [0, maxRadiation * 0.4],
                yellow: [maxRadiation * 0.4, maxRadiation * 0.7],
                bad: [maxRadiation * 0.7, maxRadiation],
              }}
            />
          </LabeledControls.Item>

          <LabeledControls.Item label="Flux">
            <RoundGauge
              size={2}
              value={flux}
              minValue={0}
              maxValue={maxFlux}
              format={(value) => value.toFixed(0)}
              ranges={{
                good: [0, maxFlux * 0.5],
                yellow: [maxFlux * 0.5, maxFlux * 0.8],
                bad: [maxFlux * 0.8, maxFlux],
              }}
            />
          </LabeledControls.Item>
        </LabeledControls>
      </Section>

      <Section title="Reactor Integrity">
        <ProgressBar
          value={integrityPercent}
          maxValue={100}
          ranges={{
            good: [75, 100],
            yellow: [50, 75],
            average: [25, 50],
            bad: [10, 25],
            purple: [0, 10],
          }}
        >
          {integrityPercent}%
        </ProgressBar>
        <Box mt={0.5} color={lastIntegrityDamage > 0 ? 'bad' : 'label'}>
          Integrity loss: {lastIntegrityDamage.toFixed(2)}% / tick
        </Box>
      </Section>

      <Section title="Flux Feedback">
        <LabeledList>
          <LabeledList.Item label="Base Flux">
            {baseFlux.toFixed(0)}
          </LabeledList.Item>

          <LabeledList.Item label="Void Bonus">
            +{voidFluxBonus.toFixed(0)}
          </LabeledList.Item>

          <LabeledList.Item label="Void Multiplier">
            {voidFluxMultiplier.toFixed(2)}x
          </LabeledList.Item>

          <LabeledList.Item label="Void Sources">
            heat {voidTemperatureComponent.toFixed(2)} / pressure{' '}
            {voidPressureComponent.toFixed(2)} / coolant{' '}
            {voidCoolantComponent.toFixed(2)}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Flex>
  );
};

export default RBMKOverview;
