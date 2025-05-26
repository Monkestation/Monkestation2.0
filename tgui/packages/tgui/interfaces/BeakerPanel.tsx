import { useBackend } from '../backend';
import {
  Box,
  Button,
  //  Dropdown,
  Flex,
  //  Input,
  LabeledList,
  //  NumberInput,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

export const BeakerPanel = (props) => {
  const { act, data } = useBackend();

  const spawnGrenade = () => {
    act('spawngrenade', {});
  };

  const spawnContainer = (containerNum) => {
    act('spawncontainer');
  };

  const removeReagent = (containerNum, index) => {};

  // Render container section inline to avoid component state conflicts
  const renderContainerSection = (containerNum) => {
    const containerReagents = null;
    // Ensure containerReagents is always an array
    const safeContainerReagents = Array.isArray(containerReagents)
      ? containerReagents
      : [];

    return (
      <Section title={`Container ${containerNum}`}>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Container Type" />
          </LabeledList>
          <Button icon="cog" onClick={() => spawnContainer(containerNum)}>
            Spawn Container
          </Button>
        </Stack.Item>

        <Stack.Item>
          <Box bold>Reagents:</Box>
          <Flex key={1} align="center" mb={1}>
            <Flex.Item>
              <Button
                icon="trash"
                color="bad"
                onClick={() => removeReagent(containerNum, 1)}
              >
                Remove
              </Button>
            </Flex.Item>
          </Flex>
        </Stack.Item>

        <Stack.Item>
          <Flex align="center">
            <Flex.Item>
              <Button icon="plus" onClick={() => {}}>
                Add
              </Button>
            </Flex.Item>
          </Flex>
        </Stack.Item>
      </Section>
    );
  };

  return (
    <Window title="Beaker Panel" width={1100} height={720}>
      <Window.Content>
        <Stack vertical scrollable>
          <Stack.Item>
            <Section title="Grenade Controls">
              <Stack>
                <Stack.Item>
                  <Button icon="bomb" onClick={spawnGrenade}>
                    Spawn Grenade
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <LabeledList.Item label="Grenade Type" />
                    <LabeledList.Item label="Timer (seconds)" />
                  </LabeledList>
                </Stack.Item>
              </Stack>
              <Box mt={1} color="gray">
                <em>
                  Note: beakers recommended, other containers may have issues
                </em>
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Flex>
              <Flex.Item width="48%">{renderContainerSection(1)}</Flex.Item>
              <Flex.Item width="4%" />
              <Flex.Item width="48%">{renderContainerSection(2)}</Flex.Item>
            </Flex>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
