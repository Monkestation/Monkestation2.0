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
  }> = data?.rods || [];

  const maxNormal = Number(data?.max_normal_slots ?? 0);
  const maxSpecial = Number(data?.max_special_slots ?? 0);

  const normalInstalled = rods.filter(
    (rod) => rod.slot_kind === 'normal' && rod.type !== 'Empty',
  ).length;

  const specialInstalled = rods.filter(
    (rod) => rod.slot_kind === 'special' && rod.type !== 'Empty',
  ).length;

  return (
    <>
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

          {rods.map((rod) => {
            let status = 'Empty';
            if (rod.type !== 'Empty') {
              status = rod.depleted ? 'Depleted' : 'Active';
            }

            return (
              <Table.Row key={`${rod.slot_kind}-${rod.slot_index}`}>
                <Table.Cell>{rod.slot_kind}</Table.Cell>
                <Table.Cell>{rod.slot_index}</Table.Cell>
                <Table.Cell>{rod.type}</Table.Cell>
                <Table.Cell>
                  {rod.type !== 'Empty' ? (
                    <Box inline bold color={rod.color}>
                      ●
                    </Box>
                  ) : (
                    '-'
                  )}
                </Table.Cell>
                <Table.Cell>{status}</Table.Cell>
                <Table.Cell>
                  {rod.type !== 'Empty' && (
                    <Button
                      icon="eject"
                      color="bad"
                      content="Eject"
                      onClick={() =>
                        act('remove_rod', {
                          kind: rod.slot_kind,
                          index: rod.slot_index,
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
