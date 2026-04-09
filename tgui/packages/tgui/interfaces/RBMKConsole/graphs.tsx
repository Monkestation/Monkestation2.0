import { useBackend } from '../../backend';
import { Section, Flex, ProgressBar, Box } from '../../components';
import { getGasFromPath } from '../../constants';

interface GasInfo {
  percent: number;
}

export const RBMKGraphs = () => {
  const { data } = useBackend<any>();

  const gases: Record<string, GasInfo> = data?.gas_composition || {};

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
    </Flex>
  );
};

export default RBMKGraphs;
