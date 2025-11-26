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

  const [selectedContainersType, setContainersType] = useLocalState(
    'beakerPanel_beakersType',
    {},
  );

  const handleContainerTypeChange = (index: number, data) => {
    const newMap = {
      ...selectedContainersType,
      [index]: data,
    };
    setContainersType(newMap);
  };

  const [reagentsMap, setReagentsMap] = useLocalState(
    'beakerPanel_reagents',
    {},
  );

  const [searchTerms, setSearchTerms] = useLocalState(
    'beakerPanel_searchTerms',
    {},
  );

  const [grenadeData, setGrenadeData] = useLocalState(
    'beakerPanel_grenadedata',
    { grenadeType: 'Normal', grenadeTimer: 1 },
  );

  const [selectedReagents, setSelectedReagents] = useLocalState(
    'beakerPanel_selectedReagents',
    {},
  );

  const handleSearchChange = (containerNum: number, searchTerm: string) => {
    const newSearchTerms = {
      ...searchTerms,
      [containerNum]: searchTerm,
    };
    setSearchTerms(newSearchTerms);
  };

  const handleReagentSelect = (containerNum: number, reagent) => {
    const newSelectedReagents = {
      ...selectedReagents,
      [containerNum]: reagent,
    };
    setSelectedReagents(newSelectedReagents);
  };

  const addReagentToContainer = (containerNum: number, volume: number) => {
    const selectedReagent = selectedReagents[containerNum];
    if (!selectedReagent) return;

    const currentReagents = reagentsMap[containerNum] || [];
    const newReagents = [
      ...currentReagents,
      {
        id: selectedReagent.id,
        amount: volume,
      },
    ];

    const newReagentsMap = {
      ...reagentsMap,
      [containerNum]: newReagents,
    };
    setReagentsMap(newReagentsMap);

    const newSelectedReagents = {
      ...selectedReagents,
      [containerNum]: null,
    };
    setSelectedReagents(newSelectedReagents);
  };

  const removeReagentfromContainer = (
    containerNum: number,
    reagent: number,
  ) => {
    const currentReagents = reagentsMap[containerNum] || [];
    const newReagents = currentReagents.filter((_, i) => i !== reagent);
    if (!newReagents) return;
    reagentsMap[containerNum] = newReagents;
    setReagentsMap(reagentsMap);
  };

  const updateReagentVolume = (
    containerNum: number,
    reagent: number,
    volume: number,
  ) => {
    const currentReagents = reagentsMap[containerNum];
    if (!currentReagents) {
      return;
    } else {
      const newReagentsMap = { ...reagentsMap };
      currentReagents[reagent].amount = volume;
      newReagentsMap[containerNum] = currentReagents;
      setReagentsMap(newReagentsMap);
    }
  };

  const spawnGrenade = () => {
    const grenadepayload = grenadeData || [];
    const containerspayload = selectedContainersType || [];
    const reagentspayload = reagentsMap || [];
    act('spawngrenade', {
      grenadedata: JSON.stringify(grenadepayload),
      containers: JSON.stringify(containerspayload),
      reagents: JSON.stringify(reagentspayload),
    });
  };

  const spawnContainer = (containerNum) => {
    const containerpayload = selectedContainersType[containerNum] || [];
    const reagentspayload = reagentsMap[containerNum] || [];
    act('spawncontainer', {
      container: JSON.stringify(containerpayload),
      reagents: JSON.stringify(reagentspayload),
    });
  };

  const renderContainerSection = (containerNum: number) => {
    const safeReagentSearch = searchTerms[containerNum] || '';
    const filteredReagents = reagents.filter(
      (reagent) =>
        reagent.name &&
        typeof reagent.name === 'string' &&
        typeof safeReagentSearch === 'string' &&
        reagent.name.toLowerCase().includes(safeReagentSearch.toLowerCase()),
    );

    const safeContainerReagents = Array.isArray(reagentsMap[containerNum])
      ? reagentsMap[containerNum]
      : [];

    return (
      <Section title={`Container ${containerNum}`}>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Container Type">
              <Dropdown
                width="300px"
                options={containers.map((container) => ({
                  displayText: (
                    <>
                      {`Path: ${container.id}`}
                      <br />
                      {`Container Name: ${container.name} Volume: ${container.volume}`}
                    </>
                  ),
                  value: container.id,
                }))}
                selected={selectedContainersType[containerNum]?.id}
                onSelected={(value) => {
                  const selectedContainer = containers.find(
                    (container) => container.id === value,
                  );
                  handleContainerTypeChange(containerNum, selectedContainer);
                }}
              />
              Container Selected:{' '}
              {selectedContainersType[containerNum]?.name || 'None'}
              <br />
              Volume:{' '}
              {selectedContainersType[containerNum]?.volume
                ? `${selectedContainersType[containerNum].volume}u`
                : 'None'}
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
          {safeContainerReagents.map((reagent, index: number) => {
            const currentreagentData = reagents.find(
              (r) => r.id === reagent.id,
            );
            return (
              <Flex key={index} align="center" mb={1}>
                <Flex.Item grow>
                  {currentreagentData?.name || 'Unknown Reagent ' + reagent.id}
                </Flex.Item>
                <Flex.Item>
                  <NumberInput
                    width="80px"
                    value={reagent.amount}
                    minValue={0}
                    step={1}
                    stepPixelSize={10}
                    onChange={(e, value) => {
                      if (value === 0) {
                        removeReagentfromContainer(containerNum, index);
                      } else {
                        updateReagentVolume(containerNum, index, value);
                      }
                    }}
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    icon="trash"
                    color="bad"
                    onClick={() =>
                      removeReagentfromContainer(containerNum, index)
                    }
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
                  backgroundColor: 1 ? '#2a2a2a' : '#1a1a1a',
                }}
              >
                {selectedReagents[containerNum]?.name || 'No reagent selected'}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="plus"
                onClick={() => addReagentToContainer(containerNum, 1)}
                disabled={!selectedReagents[containerNum]}
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
            onChange={(e, value) => handleSearchChange(containerNum, value)}
            mb={1}
          />
          <Section fill scrollable height="200px">
            {filteredReagents.map((reagent, index) => (
              <Button
                key={index}
                fluid
                mb={1}
                color={reagent.dangerous === 'TRUE' ? 'bad' : 'default'}
                onClick={() => handleReagentSelect(containerNum, reagent)}
                selected={selectedReagents[containerNum]?.id === reagent.id}
              >
                {reagent.name}
                {reagent.dangerous === 'TRUE' && ' (Dangerous)'}
              </Button>
            ))}
          </Section>
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
                    <LabeledList.Item label="Grenade Type">
                      <Dropdown
                        width="150px"
                        options={['Normal']}
                        selected={grenadeData.grenadeType}
                        value={grenadeData.grenadeType}
                        onSelected={(value) =>
                          setGrenadeData({
                            ...grenadeData,
                            grenadeType: value, // Update grenade type in state
                          })
                        }
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Timer (seconds)">
                      <NumberInput
                        width="75px"
                        placeholder="Enter seconds"
                        minValue={1}
                        value={grenadeData.grenadeTimer}
                        onChange={(e, value) =>
                          setGrenadeData({
                            ...grenadeData,
                            grenadeTimer: value,
                          })
                        }
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
