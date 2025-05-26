import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  //  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type BeakerPanelData = {
  containers: {
    id: string;
    name: string;
    volume: number;
  }[];
  reagents: {
    id: string;
    name: string;
    dangerous: string;
  }[];
  chemstring: string;
};

export const BeakerPanel = (props) => {
  const { act, data } = useBackend<BeakerPanelData>();
  const { reagents, containers, chemstring } = data;

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
            <LabeledList.Item label="Container Type">
              <Dropdown
                width="300px"
                options={containers.map((container) => ({
                  displayText: container.name + ' Volume: ' + container.volume,
                  value: container.name,
                }))}
              />
            </LabeledList.Item>
          </LabeledList>
          <Button icon="cog" onClick={() => spawnContainer(containerNum)}>
            Spawn Container
          </Button>
          <Button icon="cog" onClick={() => null}>
            Import
          </Button>
          <Button icon="cog" onClick={() => null}>
            Export
          </Button>
        </Stack.Item>

        <Stack.Item>
          <Box bold>Reagents:</Box>
          {safeContainerReagents.map((reagent, index) => {
            const reagentData = reagents.find((r) => r.name === '');
            return (
              <Flex key={index} align="center" mb={1}>
                <Flex.Item grow>{'Unknown Reagent'}</Flex.Item>
                <Flex.Item>
                  <NumberInput
                    width="80px"
                    value={1}
                    minValue={0}
                    step={1}
                    stepPixelSize={10}
                    onChange={(e, value) => 0}
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button icon="trash" color="bad" onClick={() => 0}>
                    Remove
                  </Button>
                </Flex.Item>
              </Flex>
            );
          })}
        </Stack.Item>

        <Stack.Item>
          <Flex align="center">
            <Flex.Item grow>
              <Box
                p={1}
                style={{
                  border: '1px solid #ccc',
                  minHeight: '25px',
                  backgroundColor: 1 ? '#2a2a2a' : '#1a1a1a',
                }}
              >
                {'No reagent selected'}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button icon="plus" onClick={() => {}}>
                Add
              </Button>
            </Flex.Item>
          </Flex>
        </Stack.Item>

        <Stack.Item>
          <Box bold>Search Reagent:</Box>
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
