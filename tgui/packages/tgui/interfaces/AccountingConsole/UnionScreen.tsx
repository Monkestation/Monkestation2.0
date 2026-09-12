import type { BooleanLike } from 'common/react';
import { useBackend } from '../../backend';
import { Button, DmIcon, Section, Stack, Table } from '../../components';

type Data = {
  badge_name: string;
  badge_icon: string;
  badge_icon_state: string;
  badge_leader: BooleanLike;
  union_members: UnionData[];
  on_cooldown: BooleanLike;
  seconds_left: string;
};

type UnionData = {
  leader: BooleanLike;
  name: string;
};

export const UnionScreen = () => {
  const { act, data } = useBackend<Data>();
  const {
    badge_name,
    badge_icon,
    badge_icon_state,
    badge_leader,
    union_members = [],
    on_cooldown,
    seconds_left,
  } = data;
  return (
    <>
      <Section
        title="Inserted Badge"
        height="28%"
        buttons={
          <>
            {badge_leader ? (
              <Button.Confirm
                icon="recycle"
                content="Recycle"
                disabled={!badge_name}
                onClick={() => act('recycle_badge')}
                tooltip="Recycle the badge, permanently destroying it."
              />
            ) : (
              <Button
                icon="recycle"
                content="Recycle"
                disabled={!badge_name}
                onClick={() => act('recycle_badge')}
                tooltip="Recycle the badge, permanently destroying it."
              />
            )}
            <Button
              icon="eject"
              content="Eject"
              disabled={!badge_name}
              onClick={() => act('eject_badge')}
            />
          </>
        }
      >
        {!badge_name && (
          <Stack vertical>
            <Stack.Item fontSize="140%" color="bad" bold textAlign="center">
              No Badge detected
            </Stack.Item>
            <Stack.Item textAlign="center">
              Please insert a badge to use this section.
            </Stack.Item>
          </Stack>
        )}
        <Stack>
          <Stack.Item>
            {!!badge_icon && (
              <DmIcon
                icon={badge_icon}
                icon_state={badge_icon_state}
                height={'24px'}
                width={'24px'}
              />
            )}
          </Stack.Item>
          <Stack.Item my={1}>{badge_name}</Stack.Item>
        </Stack>
      </Section>
      <Section
        my={-1}
        title="Union Personnel"
        height="72%"
        scrollable
        fill
        buttons={
          <Button icon="pencil" onClick={() => act('add_member')}>
            Add Member
          </Button>
        }
      >
        <Table>
          {union_members.map((member) => (
            <Table.Row key={member.name} my={0.5} p={1} className="candystripe">
              <Table.Cell p={0.5}>{member.name}</Table.Cell>
              <Table.Cell p={0.5}>{member.leader ? 'LEADER' : ''}</Table.Cell>
              <Table.Cell p={0.5} textAlign="right">
                <Button.Confirm
                  confirmContent="Really "
                  onClick={() =>
                    act('remove_member', { member_name: member.name })
                  }
                  tooltip="Removes this member from the Union."
                >
                  Remove
                </Button.Confirm>
              </Table.Cell>
              <Table.Cell p={0.5} textAlign="right">
                <Button
                  disabled={on_cooldown}
                  onClick={() =>
                    act('print_badge', { member_name: member.name })
                  }
                  tooltip={
                    on_cooldown
                      ? 'On cooldown for ' + seconds_left + '.'
                      : 'Will print a new ID in their name, printer has a cooldown.'
                  }
                >
                  Replace Badge
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </>
  );
};
