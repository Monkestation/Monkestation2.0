import { useBackend } from '../../backend';
import { Section, Flex, ProgressBar, Chart } from '../../components';
import { getGasFromPath } from '../../constants';

interface GasInfo {
  percent: number;
}

export const RBMKGraphs = () => {
  const { data } = useBackend<any>();

  const gases: Record<string, GasInfo> = data?.gas_composition || {};
  const gasHistory: Record<string, number[]> = data?.gas_history || {};

  const activeGases = Object.entries(gases)
    .filter(([, info]) => (info?.percent ?? 0) > 0)
    .sort((a, b) => b[1].percent - a[1].percent);

  const segments = activeGases.map(([gasPath, info]) => ({
    value: info.percent,
    color: getGasFromPath(gasPath)?.color || 'white',
  }));

  const datasets = Object.entries(gasHistory).map(([gasPath, values]) => ({
    label: getGasFromPath(gasPath)?.label || gasPath,
    data: values.map((value, index) => [index, value]),
    strokeColor: getGasFromPath(gasPath)?.color || '#fff',
    strokeWidth: 2,
  }));

  return (
    <Flex direction="column" gap={1}>
      <Flex.Item>
        <Section title="Coolant Gas Composition">
          {activeGases.length > 0 ? (
            <ProgressBar value={100} maxValue={100} segments={segments}>
              {activeGases
                .map(
                  ([gasPath, info]) =>
                    `${getGasFromPath(gasPath)?.label || gasPath}: ${info.percent.toFixed(1)}%`,
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
          <Chart.Line data={datasets} height="200px" />
        </Section>
      </Flex.Item>
    </Flex>
  );
};

export default RBMKGraphs;
