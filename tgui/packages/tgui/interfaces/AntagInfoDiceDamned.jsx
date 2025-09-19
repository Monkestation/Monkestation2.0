import { useBackend } from '../backend';
import { Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

export const AntagInfoDiceDamned = (props) => {
  const { act, data } = useBackend();
  const { master_name } = data;
  return (
    <Window width={400} height={400} theme="abductor">
      <Window.Content backgroundColor="#9d0032">
        <Icon
          size={20}
          name="ghost"
          color="#660020"
          position="absolute"
          top="20%"
          left="28%"
        />
        <Section fill>
          <Stack vertical fill textAlign="center">
            <Stack.Item fontSize="20px">
              Your soul has been captured!
            </Stack.Item>
            <Stack.Item fontSize="30px">
              You are imprisoned, bound within the die by which you were smote.
            </Stack.Item>
            <Stack.Item fontSize="20px">
              It hurts.
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
