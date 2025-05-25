import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

export const BeakerPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { reagents = [], containers = [] } = data;

  // Get default container (prefer beakers)
  const getDefaultContainer = () => {
    if (!containers || !containers.length) return '';

    const beaker = containers.find(
      (c) =>
        c &&
        c.name &&
        typeof c.name === 'string' &&
        c.name.toLowerCase().includes('beaker'),
    );
    if (beaker) return beaker.name;

    const firstValid = containers.find(
      (c) => c && c.name && typeof c.name === 'string',
    );
    return firstValid ? firstValid.name : '';
  };

  // Main panel state with unique keys to prevent conflicts
  const [container1Type, setContainer1Type] = useLocalState(
    context,
    'beakerPanel_container1Type',
    getDefaultContainer(),
  );
  const [container2Type, setContainer2Type] = useLocalState(
    context,
    'beakerPanel_container2Type',
    getDefaultContainer(),
  );
  const [container1Reagents, setContainer1Reagents] = useLocalState(
    context,
    'beakerPanel_container1Reagents',
    [],
  );
  const [container2Reagents, setContainer2Reagents] = useLocalState(
    context,
    'beakerPanel_container2Reagents',
    [],
  );
  const [grenadeType, setGrenadeType] = useLocalState(
    context,
    'beakerPanel_grenadeType',
    'normal',
  );
  const [grenadeTimer, setGrenadeTimer] = useLocalState(
    context,
    'beakerPanel_grenadeTimer',
    30,
  );

  // Container 1 specific state
  const [container1_newReagentVolume, setContainer1_newReagentVolume] =
    useLocalState(context, 'beakerPanel_c1_newVolume', 40);
  const [container1_selectedReagent, setContainer1_selectedReagent] =
    useLocalState(context, 'beakerPanel_c1_selected', '');
  const [container1_reagentSearch, setContainer1_reagentSearch] = useLocalState(
    context,
    'beakerPanel_c1_search',
    '',
  );

  // Container 2 specific state
  const [container2_newReagentVolume, setContainer2_newReagentVolume] =
    useLocalState(context, 'beakerPanel_c2_newVolume', 40);
  const [container2_selectedReagent, setContainer2_selectedReagent] =
    useLocalState(context, 'beakerPanel_c2_selected', '');
  const [container2_reagentSearch, setContainer2_reagentSearch] = useLocalState(
    context,
    'beakerPanel_c2_search',
    '',
  );

  // Show loading if no data
  if (!reagents.length && !containers.length) {
    return (
      <Window title="Beaker Panel" width={1100} height={720}>
        <Window.Content>
          <Box>Loading reagents and containers...</Box>
        </Window.Content>
      </Window>
    );
  }

  // Debug: log what we're receiving
  if (!containerOptions) {
    console.log('Containers data:', containers);
    console.log('Reagents data:', reagents);
  }

  const containerOptions = containers.map((container) => ({
    value: container.name,
    text: `${container.name} (${container.volume}u)`,
  }));

  const addReagent = (containerNum, reagentId, volume) => {
    const newReagent = {
      reagent: reagentId,
      volume: volume,
    };

    if (containerNum === 1) {
      setContainer1Reagents([...container1Reagents, newReagent]);
    } else {
      setContainer2Reagents([...container2Reagents, newReagent]);
    }
  };

  const removeReagent = (containerNum, index) => {
    if (containerNum === 1) {
      setContainer1Reagents(container1Reagents.filter((_, i) => i !== index));
    } else {
      setContainer2Reagents(container2Reagents.filter((_, i) => i !== index));
    }
  };

  const updateReagentVolume = (containerNum, index, volume) => {
    if (containerNum === 1) {
      setContainer1Reagents(
        container1Reagents.map((reagent, i) =>
          i === index ? { ...reagent, volume } : reagent,
        ),
      );
    } else {
      setContainer2Reagents(
        container2Reagents.map((reagent, i) =>
          i === index ? { ...reagent, volume } : reagent,
        ),
      );
    }
  };

  const spawnContainer = (containerNum) => {
    const containerName = containerNum === 1 ? container1Type : container2Type;
    const container = containers.find((c) => c.name === containerName);
    const containerReagents =
      containerNum === 1 ? container1Reagents : container2Reagents;

    // Convert reagent names back to IDs for backend
    const reagentsWithIds = containerReagents.map((reagent) => {
      const reagentData = reagents.find((r) => r.name === reagent.reagent);
      return {
        reagent: reagentData ? reagentData.id : reagent.reagent,
        volume: reagent.volume,
      };
    });

    const containerData = {
      container: container ? container.id : containerName,
      reagents: reagentsWithIds,
    };

    act('spawncontainer', {
      container: JSON.stringify(containerData),
    });
  };

  const spawnGrenade = () => {
    const container1 = containers.find((c) => c.name === container1Type);
    const container2 = containers.find((c) => c.name === container2Type);

    // Convert reagent names back to IDs for backend
    const container1ReagentsWithIds = container1Reagents.map((reagent) => {
      const reagentData = reagents.find((r) => r.name === reagent.reagent);
      return {
        reagent: reagentData ? reagentData.id : reagent.reagent,
        volume: reagent.volume,
      };
    });

    const container2ReagentsWithIds = container2Reagents.map((reagent) => {
      const reagentData = reagents.find((r) => r.name === reagent.reagent);
      return {
        reagent: reagentData ? reagentData.id : reagent.reagent,
        volume: reagent.volume,
      };
    });

    const containersData = [
      {
        container: container1 ? container1.id : container1Type,
        reagents: container1ReagentsWithIds,
      },
      {
        container: container2 ? container2.id : container2Type,
        reagents: container2ReagentsWithIds,
      },
    ];

    const grenadeData = {
      'grenade-timer': grenadeTimer,
    };

    act('spawngrenade', {
      containers: JSON.stringify(containersData),
      grenadetype: grenadeType,
      grenadedata: JSON.stringify(grenadeData),
    });
  };

  // Render container section inline to avoid component state conflicts
  const renderContainerSection = (containerNum) => {
    const isContainer1 = containerNum === 1;
    const containerType = isContainer1 ? container1Type : container2Type;
    const setContainerType = isContainer1
      ? setContainer1Type
      : setContainer2Type;
    const containerReagents = isContainer1
      ? container1Reagents
      : container2Reagents;

    // Get the right state variables for this container
    const newReagentVolume = isContainer1
      ? container1_newReagentVolume
      : container2_newReagentVolume;
    const setNewReagentVolume = isContainer1
      ? setContainer1_newReagentVolume
      : setContainer2_newReagentVolume;
    const selectedReagent = isContainer1
      ? container1_selectedReagent
      : container2_selectedReagent;
    const setSelectedReagent = isContainer1
      ? setContainer1_selectedReagent
      : setContainer2_selectedReagent;
    const reagentSearch = isContainer1
      ? container1_reagentSearch
      : container2_reagentSearch;
    const setReagentSearch = isContainer1
      ? setContainer1_reagentSearch
      : setContainer2_reagentSearch;

    // Safe reagent search with type checking
    const safeReagentSearch = reagentSearch || '';
    const filteredReagents = reagents.filter(
      (reagent) =>
        reagent.name &&
        typeof reagent.name === 'string' &&
        typeof safeReagentSearch === 'string' &&
        reagent.name.toLowerCase().includes(safeReagentSearch.toLowerCase()),
    );

    // Ensure containerReagents is always an array
    const safeContainerReagents = Array.isArray(containerReagents)
      ? containerReagents
      : [];

    return (
      <Section title={`Container ${containerNum}`}>
        <Stack vertical>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Container Type">
                <Dropdown
                  width="300px"
                  options={containerOptions}
                  selected={containerType}
                  onSelected={(value) => setContainerType(value)}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>

          <Stack.Item>
            <Button icon="cog" onClick={() => spawnContainer(containerNum)}>
              Spawn Container
            </Button>
          </Stack.Item>

          <Stack.Item>
            <Box bold>Reagents:</Box>
            {safeContainerReagents.map((reagent, index) => {
              const reagentData = reagents.find(
                (r) => r.name === reagent.reagent,
              );
              return (
                <Flex key={index} align="center" mb={1}>
                  <Flex.Item grow>
                    {reagentData?.name || reagent.reagent || 'Unknown Reagent'}
                  </Flex.Item>
                  <Flex.Item>
                    <NumberInput
                      width="80px"
                      value={reagent.volume}
                      minValue={0}
                      step={1}
                      stepPixelSize={10}
                      onChange={(e, value) =>
                        updateReagentVolume(containerNum, index, value)
                      }
                    />
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      icon="trash"
                      color="bad"
                      onClick={() => removeReagent(containerNum, index)}
                    >
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
                    backgroundColor: selectedReagent ? '#2a2a2a' : '#1a1a1a',
                  }}
                >
                  {selectedReagent || 'No reagent selected'}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <NumberInput
                  width="80px"
                  value={newReagentVolume}
                  minValue={1}
                  step={1}
                  stepPixelSize={10}
                  onChange={(e, value) => setNewReagentVolume(value)}
                />
              </Flex.Item>
              <Flex.Item>
                <Button
                  icon="plus"
                  onClick={() => {
                    if (selectedReagent) {
                      addReagent(
                        containerNum,
                        selectedReagent,
                        newReagentVolume,
                      );
                      setSelectedReagent(''); // Clear selection after adding
                    }
                  }}
                  disabled={!selectedReagent}
                >
                  Add
                </Button>
              </Flex.Item>
            </Flex>
          </Stack.Item>

          <Stack.Item>
            <Box bold>Search Reagent:</Box>
            <Input
              placeholder="Search reagents..."
              value={safeReagentSearch}
              onInput={(e, value) => setReagentSearch(value)}
              mb={1}
            />
            <Section fill scrollable height="200px">
              {filteredReagents.map((reagent) => (
                <Button
                  key={reagent.id}
                  fluid
                  selected={selectedReagent === reagent.name}
                  onClick={() => setSelectedReagent(reagent.name)}
                  mb={1}
                >
                  {reagent.name}
                </Button>
              ))}
              {filteredReagents.length === 0 && (
                <Box p={1} color="gray">
                  No reagents found matching "{safeReagentSearch}"
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Section>
    );
  };

  return (
    <Window title="Beaker Panel" width={1100} height={720}>
      <Window.Content>
        <Stack vertical>
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
                    <LabeledList.Item label="Grenade Type">
                      <Dropdown
                        options={[{ value: 'normal', text: 'Normal' }]}
                        selected={grenadeType}
                        onSelected={(value) => setGrenadeType(value)}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Timer (seconds)">
                      <NumberInput
                        value={grenadeTimer}
                        minValue={1}
                        maxValue={300}
                        step={1}
                        stepPixelSize={10}
                        onChange={(e, value) => setGrenadeTimer(value)}
                      />
                    </LabeledList.Item>
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
