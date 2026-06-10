import { useBackend } from '../../backend';
import { Section, Table, Button, LabeledList, Box } from '../../components';

type RodSlotData = {
  name?: string;
  type?: string;
  rod_type?: string;
  color?: string;
  active?: boolean;
  depleted?: boolean;
  empty?: boolean;
  occupied?: boolean;
  fuel_amount?: number;
  slot_kind: 'normal' | 'special';
  slot_index: number;
};

export const RBMKRods = () => {
  const { data, act } = useBackend<any>();

  const rods: RodSlotData[] = data?.rods || [];

  const maxNormal = Number(data?.max_normal_slots ?? 0);
  const maxSpecial = Number(data?.max_special_slots ?? 0);

  const isRodOccupied = (rod: RodSlotData) => {
    if (typeof rod.occupied === 'boolean') {
      return rod.occupied;
    }

    if (typeof rod.empty === 'boolean') {
      return !rod.empty;
    }

    const rodName = rod.name ?? rod.type ?? 'Empty';
    return rodName !== 'Empty';
  };

  const getRodName = (rod: RodSlotData) => {
    return rod.name ?? rod.type ?? 'Empty';
  };

  const normalInstalled = rods.filter(
    (rod) => rod.slot_kind === 'normal' && isRodOccupied(rod),
  ).length;

  const specialInstalled = rods.filter(
    (rod) => rod.slot_kind === 'special' && isRodOccupied(rod),
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

      <Section title="Installed Rods">
        <Box style={{ maxHeight: '300px', overflowY: 'auto' }}>
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
              const occupied = isRodOccupied(rod);
              const rodName = getRodName(rod);
              const rodColor = rod.color ?? 'grey';

              let status = 'Empty';
              if (occupied) {
                status = rod.depleted ? 'Depleted' : 'Active';
              }

              return (
                <Table.Row key={`${rod.slot_kind}-${rod.slot_index}`}>
                  <Table.Cell>{rod.slot_kind}</Table.Cell>
                  <Table.Cell>{rod.slot_index}</Table.Cell>
                  <Table.Cell>{rodName}</Table.Cell>
                  <Table.Cell>
                    {occupied ? (
                      <Box inline bold color={rodColor}>
                        ●
                      </Box>
                    ) : (
                      '-'
                    )}
                  </Table.Cell>
                  <Table.Cell>{status}</Table.Cell>
                  <Table.Cell>
                    {occupied && (
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
        </Box>
      </Section>
    </>
  );
};

export default RBMKRods;
