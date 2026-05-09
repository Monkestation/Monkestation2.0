import { useBackend } from '../../backend';
import { Section, LabeledList, ProgressBar, Box } from '../../components';

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

const getTurbineStatus = (turbine: any) => {
  if (turbine.broken) {
    return 'BROKEN';
  }

  if (turbine.running) {
    return 'ONLINE';
  }

  return 'IDLE';
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

const getOvertempColor = (overtemp: number) => {
  if (overtemp > 1500) {
    return 'bad';
  }

  if (overtemp > 0) {
    return 'average';
  }

  return 'good';
};

const RBMKGenerators = () => {
  const { data } = useBackend<any>();

  const turbines = data?.turbines || [];
  const totalTurbinePower = Number(data?.total_turbine_power || 0);
  const averageTurbineIntegrity = Number(data?.average_turbine_integrity || 0);
  const turbineCount = Number(data?.turbine_count || 0);

  return (
    <Section title="Generators">
      <Section title="Generator Summary">
        <LabeledList>
          <LabeledList.Item label="Detected Turbines">
            {turbineCount}
          </LabeledList.Item>

          <LabeledList.Item label="Total Power Generation">
            {formatPower(totalTurbinePower)}
          </LabeledList.Item>

          <LabeledList.Item label="Average Generator Integrity">
            <ProgressBar
              value={averageTurbineIntegrity / 100}
              color={getIntegrityColor(averageTurbineIntegrity)}>
              {formatNumber(averageTurbineIntegrity, 1)}%
            </ProgressBar>
          </LabeledList.Item>
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
        const overtemp = Number(turbine.overtemp || 0);
        const status = getTurbineStatus(turbine);

        return (
          <Section
            key={index}
            title={`Turbine ${turbine.index || index + 1} - ${status}`}>
            <LabeledList>
              <LabeledList.Item label="Generator Integrity">
                <ProgressBar
                  value={integrity / 100}
                  color={getIntegrityColor(integrity)}>
                  {formatNumber(integrity, 1)}%
                </ProgressBar>
              </LabeledList.Item>

              <LabeledList.Item label="Power Generation">
                {formatPower(turbine.power_output)}
              </LabeledList.Item>

              <LabeledList.Item label="Turbine RPM">
                {formatNumber(turbine.rpm, 0)}
              </LabeledList.Item>

              <LabeledList.Item label="Gas Flow">
                {formatNumber(turbine.flow_moles, 2)} mol/tick
              </LabeledList.Item>

              <LabeledList.Item label="Inlet Temperature">
                {formatNumber(turbine.inlet_temperature, 1)} K
              </LabeledList.Item>

              <LabeledList.Item label="Outlet Temperature">
                {formatNumber(turbine.outlet_temperature, 1)} K
              </LabeledList.Item>

              <LabeledList.Item label="Temperature Drop">
                {formatNumber(turbine.temperature_drop, 1)} K
              </LabeledList.Item>

              <LabeledList.Item label="Inlet Pressure">
                {formatNumber(turbine.inlet_pressure, 1)} kPa
              </LabeledList.Item>

              <LabeledList.Item label="Outlet Pressure">
                {formatNumber(turbine.outlet_pressure, 1)} kPa
              </LabeledList.Item>

              <LabeledList.Item label="Heat Capacity">
                {formatNumber(turbine.heat_capacity, 1)}
              </LabeledList.Item>

              <LabeledList.Item label="Heat Extracted">
                {formatNumber(turbine.heat_extracted, 1)}
              </LabeledList.Item>

              <LabeledList.Item label="Overtemp Above 8000 K">
                <Box color={getOvertempColor(overtemp)}>
                  {formatNumber(overtemp, 1)} K
                </Box>
              </LabeledList.Item>

              <LabeledList.Item label="Integrity Damage">
                {formatNumber(turbine.last_damage, 2)}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        );
      })}
    </Section>
  );
};

export default RBMKGenerators;
