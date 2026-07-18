import { useBackend } from '../../backend';
import {
  Box,
  Chart,
  Collapsible,
  Flex,
  ProgressBar,
  Section,
} from '../../components';
import { getGasFromPath } from '../../constants';

interface GasInfo {
  percent: number;
}

export const RBMKGraphs = () => {
  const { data } = useBackend<any>();

  const gases: Record<string, GasInfo> = data?.gas_composition || {};
  const temperatureHistory: number[] = data?.reactor_temperature_history || [];
  const pressureHistory: number[] = data?.pressure || [];
  const temperatureData = temperatureHistory.map((value, index) => [index, value]);
  const pressureData = pressureHistory.map((value, index) => [index, value]);
  const maxTemperature = Math.max(
    Number(data?.temp_max_safe ?? 6000),
    ...temperatureHistory,
    1,
  );
  const maxPressure = Math.max(
    Number(data?.pressure_critical ?? 7200),
    ...pressureHistory,
    1,
  );

  const activeGases = Object.entries(gases)
    .filter(([, info]) => Number(info?.percent ?? 0) > 0)
    .sort((a, b) => Number(b[1]?.percent ?? 0) - Number(a[1]?.percent ?? 0));

  return (
    <Flex direction="column" gap={1}>
      <Section title="Core Temperature History">
        <Box position="relative" height="145px">
          {temperatureData.length > 1 ? (
            <Chart.Line
              fillPositionedParent
              data={temperatureData}
              rangeX={[0, temperatureData.length - 1]}
              rangeY={[0, maxTemperature]}
              strokeColor="rgba(255, 104, 72, 1)"
              fillColor="rgba(255, 104, 72, 0.2)"
            />
          ) : (
            <Box color="label">Collecting temperature samples...</Box>
          )}
        </Box>
      </Section>

      <Section title="Primary Coolant Pressure History">
        <Box position="relative" height="145px">
          {pressureData.length > 1 ? (
            <Chart.Line
              fillPositionedParent
              data={pressureData}
              rangeX={[0, pressureData.length - 1]}
              rangeY={[0, maxPressure]}
              strokeColor="rgba(74, 170, 255, 1)"
              fillColor="rgba(74, 170, 255, 0.2)"
            />
          ) : (
            <Box color="label">Collecting pressure samples...</Box>
          )}
        </Box>
      </Section>

      <Flex.Item>
        <Collapsible title="Coolant Gas Composition">
          {activeGases.length > 0 ? (
            <Flex direction="column" gap={0.5}>
              {activeGases.map(([gasPath, info]) => {
                const gasLabel = getGasFromPath(gasPath)?.label || gasPath;
                const gasPercent = Number(info?.percent ?? 0);

                return (
                  <Box key={gasPath} mb={0.5}>
                    <Box mb={0.25}>
                      {gasLabel}: {gasPercent.toFixed(1)}%
                    </Box>
                    <ProgressBar
                      value={gasPercent}
                      maxValue={100}
                      color={getGasFromPath(gasPath)?.color || 'white'}
                    />
                  </Box>
                );
              })}
            </Flex>
          ) : (
            <ProgressBar value={0} maxValue={100}>
              No coolant gases detected
            </ProgressBar>
          )}
        </Collapsible>
      </Flex.Item>
    </Flex>
  );
};

export default RBMKGraphs;
