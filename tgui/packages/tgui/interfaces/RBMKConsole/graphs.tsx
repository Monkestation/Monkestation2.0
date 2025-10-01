import { useBackend } from 'tgui/backend';
import {
  Section,
  Flex,
  Table,
  ProgressBar,
  Box,
} from 'tgui/components';
import { Chart } from 'tgui/components';

// Shape of one gas info entry
interface GasInfo {
  percent: number;
  heat_modifier?: number;
  heat_resistance?: number;
}

export const RBMKGraphs = () => {
  const { data } = useBackend<any>();

  // Expect:
  // data.gas_composition = { oxygen: { percent, heat_modifier, heat_resistance }, ... }
  // data.gas_history = { oxygen: [21, 22, 20, ...], plasma: [0, 0, 1, ...], ... }
  const gases: Record<string, GasInfo> = data?.gas_composition || {};
  const gasHistory: Record<string, number[]> = data?.gas_history || {};

  // SM-style color scheme
  const gasColors: Record<string, string> = {
    oxygen: '#33f',
    plasma: '#f3f',
    carbon_dioxide: '#888',
    nitrogen: '#a52a2a',
    tritium: '#0f0',
    hydrogen: '#0ff',
    bz: '#ffa500',
    nitrogen_oxide: '#f00',
  };

  // Only keep gases > 0%, sort largest first
  const activeGases = (Object.entries(gases) as [string, GasInfo][])
    .filter(([, info]) => info?.percent > 0)
    .sort((a, b) => b[1].percent - a[1].percent);

  // Build stacked bar segments
  const segments = activeGases.map(([gas, info]) => ({
    value: info.percent,
    color: gasColors[gas] || 'white',
  }));

  const formatName = (name: string) =>
    name.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());

  return (
    <Flex direction="column" gap={1}>
      {/* Stacked composition bar */}
      <Flex.Item>
        <Section title="Coolant Gas Composition">
          {activeGases.length > 0 ? (
            <ProgressBar value={100} maxValue={100} segments={segments}>
              {activeGases
                .map(
                  ([gas, info]) =>
                    `${formatName(gas)}: ${info.percent.toFixed(1)}%`,
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

      {/* Details table */}
      <Flex.Item>
        <Section title="Coolant Gas Effects">
          <Table>
            <Table.Row header>
              <Table.Cell>Gas</Table.Cell>
              <Table.Cell textAlign="right">%</Table.Cell>
              <Table.Cell textAlign="right">Heat Mod</Table.Cell>
              <Table.Cell textAlign="right">Heat Resist</Table.Cell>
            </Table.Row>
            {activeGases.map(([gas, info]) => (
              <Table.Row key={gas}>
                <Table.Cell color={gasColors[gas] || 'white'}>
                  {formatName(gas)}
                </Table.Cell>
                <Table.Cell textAlign="right">
                  {info.percent.toFixed(1)}%
                </Table.Cell>
                <Table.Cell textAlign="right">
                  {info.heat_modifier?.toFixed(2) ?? '0.00'}
                </Table.Cell>
                <Table.Cell textAlign="right">
                  {info.heat_resistance?.toFixed(2) ?? '0.00'}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Flex.Item>

      {/* History graphs */}
      <Flex.Item>
        <Section title="Gas Composition History" fill scrollable>
          {Object.entries(gasHistory).map(([gas, values]) => {
            if (!values || values.length === 0) return null;
            const points = values.map((v, i) => [i, v]);
            return (
              <Box key={gas} mb={2}>
                <Box color="label" mb={0.5}>
                  {formatName(gas)}
                </Box>
                <Chart.Line
                  data={points}
                  strokeColor={gasColors[gas] || '#fff'}
                  strokeWidth={2}
                  height="100px"
                />
              </Box>
            );
          })}
        </Section>
      </Flex.Item>
    </Flex>
  );
};

export default RBMKGraphs;
