import { useBackend } from '../../backend';
import {
  Box,
  Collapsible,
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
  const maxRadiation = Math.max(
    Number(data?.max_radiation ?? 700),
    radiation,
    1,
  );

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
  const tempModerate = Number(data?.temp_moderate ?? 1500);
  const tempMaxSafe = Number(data?.temp_max_safe ?? 6000);
  const fluxWarning = Number(data?.flux_warning ?? 350);
  const fluxHigh = Number(data?.flux_high ?? 700);
  const fluxExtreme = Number(data?.flux_extreme ?? 1000);
  const rodTemperatureLimitBonus = Number(
    data?.rod_temperature_limit_bonus ?? 0,
  );
  const coolantExchangeMultiplier = Number(
    data?.coolant_exchange_multiplier ?? 1,
  );
  const fluxModifierMultiplier = Number(
    data?.flux_modifier_multiplier ?? 1,
  );

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
                good: [0, tempModerate],
                yellow: [tempModerate, tempMaxSafe],
                bad: [tempMaxSafe, maxTemp],
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

          <LabeledControls.Item label="Radiation">
            <RoundGauge
              size={2}
              value={radiation}
              minValue={0}
              maxValue={maxRadiation}
              format={(value) => value.toFixed(1)}
              ranges={{
                good: [0, maxRadiation * 0.2],
                yellow: [maxRadiation * 0.2, maxRadiation * 0.5],
                bad: [maxRadiation * 0.5, maxRadiation],
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
                good: [0, fluxWarning],
                yellow: [fluxWarning, fluxHigh],
                bad: [fluxHigh, Math.max(maxFlux, fluxExtreme)],
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

      <Collapsible title={`Neutronics & Feedback — ${voidFluxMultiplier.toFixed(2)}x`}>
        <LabeledList>
          <LabeledList.Item label="Base Flux">
            {baseFlux.toFixed(0)}
          </LabeledList.Item>
          <LabeledList.Item label="Void Contribution">
            +{voidFluxBonus.toFixed(0)} flux
          </LabeledList.Item>
          <LabeledList.Item label="Void Multiplier">
            {voidFluxMultiplier.toFixed(2)}x
          </LabeledList.Item>
          <LabeledList.Item label="Temperature Feedback">
            +{voidTemperatureComponent.toFixed(2)}
          </LabeledList.Item>
          <LabeledList.Item label="Low-pressure Feedback">
            +{voidPressureComponent.toFixed(2)}
          </LabeledList.Item>
          <LabeledList.Item label="Low-coolant Feedback">
            +{voidCoolantComponent.toFixed(2)}
          </LabeledList.Item>
        </LabeledList>
      </Collapsible>

      <Collapsible title={`Installed Rod Modifiers — Flux ${fluxModifierMultiplier.toFixed(2)}x`}>
        <LabeledList>
          <LabeledList.Item label="Flux Multiplier">
            {fluxModifierMultiplier.toFixed(2)}x
          </LabeledList.Item>
          <LabeledList.Item label="Coolant Exchange">
            {coolantExchangeMultiplier.toFixed(2)}x
          </LabeledList.Item>
          <LabeledList.Item label="Temperature Limit Bonus">
            +{rodTemperatureLimitBonus.toFixed(0)} K
          </LabeledList.Item>
        </LabeledList>
      </Collapsible>
    </Flex>
  );
};

export default RBMKOverview;
