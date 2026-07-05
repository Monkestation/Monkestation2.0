import { useBackend } from '../../backend';
import { Box, LabeledList, ProgressBar, Section } from '../../components';

const formatNumber = (value: number, digits = 0) => {
  return Number(value || 0).toLocaleString(undefined, {
    maximumFractionDigits: digits,
  });
};

const formatPower = (value: number) => {
  const powerValue = Number(value || 0);

  if (powerValue >= 1000000) {
    return `${formatNumber(powerValue / 1000000, 2)} MW`;
  }

  if (powerValue >= 1000) {
    return `${formatNumber(powerValue / 1000, 2)} kW`;
  }

  return `${formatNumber(powerValue, 0)} W`;
};

const formatTemperature = (value: number) => {
  return `${formatNumber(value, 1)} K`;
};

const formatPressure = (value: number) => {
  return `${formatNumber(value, 1)} kPa`;
};

const getTurbineStatus = (turbine: any) => {
  if (turbine.broken) {
    return 'OFFLINE';
  }

  if (turbine.generating || turbine.running) {
    return 'ONLINE';
  }

  if (turbine.telemetry_stale) {
    return 'STALE';
  }

  return 'IDLE';
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'ONLINE':
      return 'good';
    case 'IDLE':
      return 'average';
    case 'STALE':
      return 'average';
    case 'OFFLINE':
      return 'bad';
    default:
      return 'average';
  }
};

const getIntegrityColor = (integrity: number) => {
  if (integrity >= 70) {
    return 'good';
  }

  if (integrity >= 30) {
    return 'average';
  }

  return 'bad';
};

const getTurbineKey = (turbine: any, index: number) => {
  if (turbine.ref) {
    return turbine.ref;
  }

  if (turbine.uid) {
    return turbine.uid;
  }

  if (turbine.id) {
    return turbine.id;
  }

  return `${turbine.name || 'turbine'}-${turbine.index || index + 1}-${index}`;
};

const getPressureDelta = (turbine: any) => {
  if (turbine.pressure_delta !== undefined && turbine.pressure_delta !== null) {
    return Number(turbine.pressure_delta || 0);
  }

  return Math.max(
    Number(turbine.inlet_pressure || 0) - Number(turbine.outlet_pressure || 0),
    0,
  );
};

const RBMKGenerators = () => {
  const { data } = useBackend<any>();

  const turbines = data?.turbines || [];
  const totalTurbinePower = Number(data?.total_turbine_power || 0);
  const averageTurbineIntegrity = Number(data?.average_turbine_integrity || 0);
  const turbineCount = Number(data?.turbine_count || turbines.length || 0);

  const onlineTurbines = turbines.filter((turbine: any) => {
    return getTurbineStatus(turbine) === 'ONLINE';
  }).length;

  const staleTurbines = turbines.filter((turbine: any) => {
    return getTurbineStatus(turbine) === 'STALE';
  }).length;

  return (
    <Section title="Generators">
      <Section title="Generator Summary">
        <LabeledList>
          <LabeledList.Item label="Turbines">
            {onlineTurbines} / {turbineCount} online
          </LabeledList.Item>

          {!!staleTurbines && (
            <LabeledList.Item label="Stale Telemetry">
              <Box color="average">{staleTurbines}</Box>
            </LabeledList.Item>
          )}

          <LabeledList.Item label="Total Generation">
            {formatPower(totalTurbinePower)}
          </LabeledList.Item>

          {!!turbineCount && (
            <LabeledList.Item label="Average Integrity">
              <ProgressBar
                value={averageTurbineIntegrity / 100}
                color={getIntegrityColor(averageTurbineIntegrity)}
              >
                {formatNumber(averageTurbineIntegrity, 1)}%
              </ProgressBar>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>

      {!turbines.length && (
        <Section title="Turbines">
          <Box color="average">
            No RBMK turbines detected near the linked reactor.
          </Box>
        </Section>
      )}

      {turbines.map((turbine: any, index: number) => {
        const integrity = Number(turbine.integrity || 0);
        const status = getTurbineStatus(turbine);
        const turbineIndex = Number(turbine.index || index + 1);
        const pressureDelta = getPressureDelta(turbine);
        const telemetryAge = Number(turbine.telemetry_age);

        return (
          <Section
            key={getTurbineKey(turbine, index)}
            title={`Turbine ${turbineIndex}`}
            buttons={
              <Box color={getStatusColor(status)} bold>
                {status}
              </Box>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Power Output">
                {formatPower(turbine.power_output)}
              </LabeledList.Item>

              <LabeledList.Item label="RPM">
                {formatNumber(turbine.rpm, 0)}
              </LabeledList.Item>

              <LabeledList.Item label="Flow Rate">
                {formatNumber(turbine.flow_moles, 2)} mol/tick
              </LabeledList.Item>

              <LabeledList.Item label="Pressure Delta">
                {formatPressure(pressureDelta)}
              </LabeledList.Item>

              <LabeledList.Item label="Coolant Temperature">
                {formatTemperature(turbine.inlet_temperature)} →{' '}
                {formatTemperature(turbine.outlet_temperature)}
              </LabeledList.Item>

              <LabeledList.Item label="Generator Integrity">
                <ProgressBar
                  value={integrity / 100}
                  color={getIntegrityColor(integrity)}
                >
                  {formatNumber(integrity, 1)}%
                </ProgressBar>
              </LabeledList.Item>

              <LabeledList.Item label="Telemetry Age">
                {Number.isFinite(telemetryAge)
                  ? `${formatNumber(telemetryAge, 1)} s`
                  : 'No signal'}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        );
      })}
    </Section>
  );
};

export default RBMKGenerators;
