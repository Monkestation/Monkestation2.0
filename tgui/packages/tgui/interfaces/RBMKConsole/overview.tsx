import { useBackend } from '../../backend';
import {
  Box,
  Collapsible,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
} from '../../components';

const Instrument = (props: {
  label: string;
  value: string;
  unit?: string;
  state: 'nominal' | 'warning' | 'danger';
}) => (
  <Flex.Item basis="31%" grow>
    <Box
      className={`RBMKConsole__Instrument RBMKConsole__Instrument--${props.state}`}
    >
      <Box className="RBMKConsole__InstrumentLabel">{props.label}</Box>
      <Box className="RBMKConsole__InstrumentValue">
        {props.value}
        {!!props.unit && (
          <Box as="span" className="RBMKConsole__InstrumentUnit">
            {props.unit}
          </Box>
        )}
      </Box>
      <Box className="RBMKConsole__InstrumentLamp" />
    </Box>
  </Flex.Item>
);

export const RBMKOverview = () => {
  const { data } = useBackend<any>();

  const temperature = Number(data?.temperature ?? 0);

  const radiation = Number(data?.radiation ?? 0);
  const maxRadiation = Math.max(Number(data?.max_radiation ?? 700), 1);

  const flux = Number(data?.flux ?? 0);
  const baseFlux = Number(data?.base_flux ?? 0);
  const voidFluxBonus = Number(data?.void_flux_bonus ?? 0);

  const voidCoefficient = Number(data?.void_coefficient ?? 0);
  const maxVoidCoefficient = Math.max(Number(data?.max_void_coefficient ?? 0.5), 0.5);
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
  const integrity = Number(data?.integrity ?? 0);
  const maxIntegrity = Math.max(1, Number(data?.max_integrity ?? 100));
  const integrityPercent = Math.max(
    0,
    Math.min(100, Math.round((integrity / maxIntegrity) * 100)),
  );
  const lastIntegrityDamage = Number(data?.last_integrity_damage ?? 0);

  return (
    <Flex direction="column" gap={1}>
      <Section title="Live Reactor Parameters" className="RBMKConsole__TelemetryPanel">
        <Flex wrap gap={0.75}>
          <Instrument
            label="Core Temperature"
            value={temperature.toFixed(0)}
            unit="K"
            state={temperature >= tempMaxSafe ? 'danger' : temperature >= tempModerate ? 'warning' : 'nominal'}
          />
          <Instrument
            label="Primary Pressure"
            value={pressure.toFixed(0)}
            unit="kPa"
            state={pressure >= pressureCritical ? 'danger' : pressure >= pressureWarning ? 'warning' : 'nominal'}
          />
          <Instrument
            label="Neutron Flux"
            value={flux.toFixed(0)}
            state={flux >= fluxHigh ? 'danger' : flux >= fluxWarning ? 'warning' : 'nominal'}
          />
          <Instrument
            label="Radiation"
            value={radiation.toFixed(1)}
            state={radiation >= maxRadiation * 0.5 ? 'danger' : radiation >= maxRadiation * 0.2 ? 'warning' : 'nominal'}
          />
          <Instrument
            label="Void Coefficient"
            value={voidCoefficient.toFixed(3)}
            state={voidCoefficient >= maxVoidCoefficient * 0.7 ? 'danger' : voidCoefficient >= maxVoidCoefficient * 0.35 ? 'warning' : 'nominal'}
          />
        </Flex>
      </Section>

      <Section title="Reactor Integrity" className="RBMKConsole__IntegrityPanel">
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
