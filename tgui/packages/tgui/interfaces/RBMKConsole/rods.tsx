import { useBackend } from 'tgui/backend';
import { Section, Table, Button, LabeledList, Box } from 'tgui/components';

export const RBMKRods = () => {
  const { data, act } = useBackend<any>();
  const rods: Array<{
    type: string;
    color: string;
    depleted?: boolean;
    slot_kind: 'normal' | 'special';
    slot_index: number;
  }> = data.rods || [];

  const normal = rods.filter((r) => r.slot_kind === 'normal');
  const special = rods.filter((r) => r.slot_kind === 'special');

  return (
    <>
      <Section title="Rod Banks">
        <LabeledList>
          <LabeledList.Item label="Normal Bank">
            {normal.length}/{data.max_normal_slots ?? normal.length}
          </LabeledList.Item>
          <LabeledList.Item label="Special Bank">
            {special.length}/{data.max_special_slots ?? special.length}
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Installed Rods" scrollable>
        <Table>
          <Table.Row header>
            <Table.Cell collapsing>Bank</Table.Cell>
            <Table.Cell collapsing>#</Table.Cell>
            <Table.Cell>Type</Table.Cell>
            <Table.Cell collapsing>Color</Table.Cell>
            <Table.Cell collapsing>Status</Table.Cell>
            <Table.Cell collapsing>Action</Table.Cell>
          </Table.Row>

          {rods.map((r) => {
            const status =
              r.type === 'Empty' ? '-' : r.depleted ? 'Depleted' : 'Active';

            return (
              <Table.Row key={`${r.slot_kind}-${r.slot_index}`}>
                <Table.Cell capitalize>{r.slot_kind}</Table.Cell>
                <Table.Cell>{r.slot_index}</Table.Cell>
                <Table.Cell>{r.type || 'Empty'}</Table.Cell>
                <Table.Cell>
                  {r.color ? (
                    <Box inline bold color={r.color}>
                      ● {r.color}
                    </Box>
                  ) : (
                    '-'
                  )}
                </Table.Cell>
                <Table.Cell>{status}</Table.Cell>
                <Table.Cell>
                  {r.type !== 'Empty' && (
                    <Button
                      icon="eject"
                      color="bad"
                      content="Eject"
                      onClick={() =>
                        act('remove_rod', {
                          kind: r.slot_kind,
                          index: r.slot_index,
                        })
                      }
                    />
                  )}
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      </Section>
    </>
  );
};

export default RBMKRods;
