import type { BooleanLike } from 'common/react';
import { Button, Section, DmIcon, Stack } from '../components';
import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';

type Data = {
  badge_name: string;
  badge_icon: string;
  badge_icon_state: string;
  badge_leader: BooleanLike;
  union_members: UnionData[];
};

type UnionData = {
  leader: BooleanLike;
  name: string;
};

export const NtosCargoUnion = () => {
  const { act, data } = useBackend<Data>();
  const {
    badge_name,
    badge_icon,
    badge_icon_state,
    badge_leader,
    union_members = [],
  } = data;
  return (
    <NtosWindow width={500} height={600}>
      <NtosWindow.Content scrollable>
        <Section
          title="Inserted Badge"
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
          title="Union Personnel"
          buttons={
            <Button
              icon="pencil"
              content="Add Member"
              onClick={() => act('add_member')}
            />
          }
        >
          {union_members.map((member) => (
            <Stack
              key={member.name}
              fill
              my={0.5}
              p={1}
              className="candystripe"
            >
              <Stack.Item grow={1}>{member.name}</Stack.Item>
              {!!member.leader && <Stack.Item grow={1}>LEADER</Stack.Item>}
              <Stack.Item textAlign="right">
                <Button.Confirm
                  confirmContent="Really "
                  onClick={() =>
                    act('remove_member', { member_name: member.name })
                  }
                  tooltip="Removes this member from the Union."
                >
                  Remove
                </Button.Confirm>
              </Stack.Item>
              <Stack.Item textAlign="right">
                <Button
                  onClick={() =>
                    act('print_badge', { member_name: member.name })
                  }
                  tooltip="Will print a new ID in their name, printer has a cooldown."
                >
                  Replace Badge
                </Button>
              </Stack.Item>
            </Stack>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
