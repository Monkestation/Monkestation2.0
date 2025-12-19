import { Section, Stack, Button } from '../components';
import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';

type Data = {
  union_members: string[];
};

export const NtosCargoUnion = (props) => {
  const { act, data } = useBackend<Data>();
  const { union_members = [] } = data;
  return (
    <NtosWindow width={500} height={600}>
      <NtosWindow.Content scrollable>
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
            <Stack key={member} fill my={0.5} p={1} className="candystripe">
              <Stack.Item grow={1}>{member}</Stack.Item>
              <Stack.Item textAlign="right">
                <Button.Confirm
                  confirmContent="Really "
                  onClick={() => act('remove_member', { member_name: member })}
                  tooltip="Removes this member from the Union."
                >
                  Remove
                </Button.Confirm>
              </Stack.Item>
              <Stack.Item textAlign="right">
                <Button
                  onClick={() => act('print_badge', { member_name: member })}
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
