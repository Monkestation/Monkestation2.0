import { useBackend } from '../../backend';
import { Section, Flex, ProgressBar, LabeledList, Box } from '../../components';
import { getGasFromPath } from '../../constants';

interface GasInfo {
  percent: number;
}

export const RBMKGraphs = () => {
  const { data } = useBackend<any>();

  const gases: Record<string, GasInfo> = data?.gas_composition || {};
  const gasHistory: Record<string, number[]> = data?.gas_history || {};

  const activeGases = Object.entries(gases)
    .filter(([, info]) => Number(info?.percent ?? 0) > 0)
    .sort((a, b) => Number(b[1]?.percent ?? 0) - Number(a[1]?.percent ?? 0));

  return (
    <Flex direction="column" gap={1}>
      <Flex.Item>
        <Section title="Coolant Gas Composition">
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
        </Section>
      </Flex.Item>

      <Flex.Item grow>
        <Section title="Gas Composition History" fill>
          {activeGases.length > 0 ? (
            <LabeledList>
              {activeGases.map(([gasPath]) => {
                const gasLabel = getGasFromPath(gasPath)?.label || gasPath;
                const values = gasHistory[gasPath] || [];
                const recentValues = values.slice(-10);
                const latestValue =
                  recentValues.length > 0
                    ? Number(recentValues[recentValues.length - 1] ?? 0)
                    : 0;

                return (
                  <LabeledList.Item
                    key={gasPath}
                    label={gasLabel}>
                    <Box>
                      Current: {latestValue.toFixed(1)}%
                      {recentValues.length > 0
                        ? ` | Recent: ${recentValues
                            .map((value) => Number(value).toFixed(1))
                            .join(', ')}`
                        : ' | No history yet'}
                    </Box>
                  </LabeledList.Item>
                );
              })}
            </LabeledList>
          ) : (
            <Box color="label">No gas history available yet.</Box>
          )}
        </Section>
      </Flex.Item>
    </Flex>
  );
};

export default RBMKGraphs;
