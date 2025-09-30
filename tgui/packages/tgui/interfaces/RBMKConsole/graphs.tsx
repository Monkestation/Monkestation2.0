import { useBackend } from 'tgui/backend';
import { Section, Flex, Table, ProgressBar } from 'tgui/components';

// Define the shape of a gas info entry
interface GasInfo {
  percent: number;
  heat_modifier?: number;
  heat_resistance?: number;
}

export const RBMKGraphs = () => {
  const { data } = useBackend<any>();

  // Expect: data.gas_composition = { oxygen: { percent, heat_modifier, heat_resistance }, ... }
  const gases: Record<string, GasInfo> = data?.gas_composition || {};

  // SM-style color scheme
  const gasColors: Record<string, string> = {
    oxygen: 'blue',
    plasma: 'purple',
    carbon_dioxide: 'gray',
    nitrogen: 'brown',
    tritium: 'green',
    hydrogen: 'cyan',
    bz: 'orange',
    nitrogen_oxide: 'red',
  };

  // Only keep gases that exist and > 0%, sorted largest first
  const activeGases = (Object.entries(gases) as [string, GasInfo][])
    .filter(([, info]) => info?.percent > 0)
    .sort((a, b) => b[1].percent - a[1].percent);

  return (
    <Flex direction="column" gap={1}>
      {/* Stacked composition bar */}
      <Flex.Item>
        <Section title="Coolant Gas Composition">
          <ProgressBar
            value={100}
            maxValue={100}
            ranges={Object.fromEntries(
              activeGases.map(([gas, info]) => [
                gasColors[gas] || 'white',
                [0, info.percent],
              ]),
            )}
          >
            {activeGases.length > 0
              ? activeGases
                  .map(
                    ([gas, info]) => `${gas}: ${info.percent.toFixed(1)}%`,
                  )
                  .join(' | ')
              : 'No coolant gases detected'}
          </ProgressBar>
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
                <Table.Cell color={gasColors[gas] || 'white'}>{gas}</Table.Cell>
                <Table.Cell textAlign="right">
                  {info.percent.toFixed(1)}%
                </Table.Cell>
                <Table.Cell textAlign="right">
                  {info.heat_modifier?.toFixed(2) ?? '0'}
                </Table.Cell>
                <Table.Cell textAlign="right">
                  {info.heat_resistance?.toFixed(2) ?? '0'}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Flex.Item>
    </Flex>
  );
};

export default RBMKGraphs;
