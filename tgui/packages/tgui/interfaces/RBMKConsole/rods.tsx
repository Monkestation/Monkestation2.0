import { useBackend } from '../../backend';
import { Section, Table, Button, LabeledList, Box } from '../../components';

export const RBMKRods = () => {
  const { data, act } = useBackend<any>();
  const rods: Array<{
    type: string;
    color: string;
    depleted?: boolean;
    slot_kind: 'normal' | 'special';
    slot_index: number;
  }> = data.rods || [];

  const maxNormal = Number(data?.max_normal_slots ?? 0);
  const maxSpecial = Number(data?.max_special_slots ?? 0);

  const normalInstalled = rods.filter((r) => r.slot_kind === 'normal' && r.type !== 'Empty').length;
  const specialInstalled = rods.filter((r) => r.slot_kind === 'special' && r.type !== 'Empty').length;

  return (
    <>
      {/* Bank overview */}
      <Section title="Rod Banks">
        <LabeledList>
          <LabeledList.Item label="Normal Bank">
            {normalInstalled}/{maxNormal}
          </LabeledList.Item>
          <LabeledList.Item label="Special Bank">
            {specialInstalled}/{maxSpecial}
          </LabeledList.Item>
        </LabeledList>
      </Section>

      {/* Rod details */}
      <Section title="Installed Rods" scrollable fill style={{ maxHeight: '300px' }}>
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
            let status = 'Empty';
            if (r.type !== 'Empty') {
              status = r.depleted ? 'Depleted' : 'Active';
            }

            return (
              <Table.Row key={`${r.slot_kind}-${r.slot_index}`}>
                <Table.Cell capitalize>{r.slot_kind}</Table.Cell>
                <Table.Cell>{r.slot_index}</Table.Cell>
                <Table.Cell>{r.type || 'Empty'}</Table.Cell>
                <Table.Cell>
                  {r.type !== 'Empty' ? (
                    <Box inline bold color={r.color}>
                      ●
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
