import { useBackend } from '../../backend';
import { Section, Flex, ProgressBar } from '../../components';
import { Chart } from '../../components';
import { getGasFromPath } from '../../constants';

interface GasInfo {
  percent: number;
  heat_modifier?: number;
  heat_resistance?: number;
}

export const RBMKGraphs = () => {
  const { data } = useBackend<any>();

  const gases: Record<string, GasInfo> = data?.gas_composition || {};
  const gasHistory: Record<string, number[]> = data?.gas_history || {};

  // Filter out gases with 0%
  const activeGases = Object.entries(gases)
    .filter(([, info]) => info?.percent > 0)
    .sort((a, b) => b[1].percent - a[1].percent);

  // Build stacked bar segments
  const segments = activeGases.map(([gas, info]) => ({
    value: info.percent,
    color: getGasFromPath(gas)?.color || 'white',
  }));

  // Build multi-line dataset for gas history
  const datasets = Object.entries(gasHistory).map(([gas, values]) => {
    const points = values.map((v, i) => [i, v]);
    return {
      label: getGasFromPath(gas)?.label || gas,
      data: points,
      strokeColor: getGasFromPath(gas)?.color || '#fff',
      strokeWidth: 2,
    };
  });

  return (
    <Flex direction="column" gap={1}>
      <Flex.Item>
        <Section title="Coolant Gas Composition">
          {activeGases.length > 0 ? (
            <ProgressBar value={100} maxValue={100} segments={segments}>
              {activeGases
                .map(
                  ([gas, info]) =>
                    `${getGasFromPath(gas)?.label || gas}: ${info.percent.toFixed(1)}%`,
                )
                .join(' | ')}
            </ProgressBar>
          ) : (
            <ProgressBar value={0} maxValue={100}>
              No coolant gases detected
            </ProgressBar>
          )}
        </Section>
      </Flex.Item>

      <Flex.Item grow>
        <Section title="Gas Composition History" fill>
          <Chart.Line
            data={datasets}
            height="200px"
            legend
          />
        </Section>
      </Flex.Item>
    </Flex>
  );
};

export default RBMKGraphs;
