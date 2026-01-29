import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { DmIcon, Flex, Icon, Stack, Tabs } from '../components';
import { Window } from '../layouts';

type Requirement = {
  stat: string;
  low: number;
  high: number;
};

type ResultIcon = {
  path: string;
  icon: string;
  icon_state: string;
};

type Plant = {
  name: string;
  desc: string;
  requirements: Requirement[];
  mutates_from?: string;
  required_reagents?: string;
  results: ResultIcon[];
};

type Data = {
  plants: Plant[];
};

export const BotanicalLexicon = () => {
  return (
    <Window
      title="Botanical Encyclopedia"
      theme="chicken_book"
      width={600}
      height={450}
    >
      <Window.Content>
        <Stack className="content">
          <Stack className="book">
            <div className="spine" />
            <Stack className="page">
              <Stack.Item className="TOC">Table of Contents</Stack.Item>
              <Stack.Item className="chicken_tab_list">
                <PlantTabs />
              </Stack.Item>
            </Stack>
            <Stack className="page">
              <PlantInfo />
            </Stack>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PlantInfo = () => {
  const {
    data: { plants = [] },
  } = useBackend<Data>();
  const [selectedPlant] = useLocalState('plant', plants[0]);
  return (
    <Flex className="chicken-info-container">
      <Flex.Item className="chicken-title">
        {toTitleCase(selectedPlant.name)}
      </Flex.Item>

      <Flex.Item className="chicken-icon-container">
        <Stack>
          {selectedPlant.results.map((result) => (
            <Stack.Item key={result.path}>
              <DmIcon
                icon={result.icon}
                icon_state={result.icon_state}
                fallback={<Icon mr={1} name="spinner" spin />}
                height={'96px'}
                width={'96px'}
              />
            </Stack.Item>
          ))}
        </Stack>
      </Flex.Item>

      <Flex.Item className="chicken-metric">
        {selectedPlant.mutates_from &&
          `Mutates From:${selectedPlant.mutates_from}`}
      </Flex.Item>

      <Flex.Item className="chicken-metric">
        {selectedPlant.desc && `Description:${selectedPlant.desc}`}
      </Flex.Item>

      {selectedPlant.requirements.map((stat) => (
        <Flex.Item className="chicken-metric" key={stat.stat}>
          {stat.stat} Range: {stat.low} to {stat.high}
        </Flex.Item>
      ))}

      <Flex.Item className="chicken-metric">
        {selectedPlant.required_reagents &&
          `Required Infusions: ${selectedPlant.required_reagents}`}
      </Flex.Item>
    </Flex>
  );
};

const PlantTabs = (props) => {
  const {
    data: { plants = [] },
  } = useBackend<Data>();
  const [selectedPlant, setSelectedPlant] = useLocalState('plant', plants[0]);
  return (
    <Tabs vertical overflowY="auto">
      {plants.map((plant, idx) => (
        <Tabs.Tab
          key={idx}
          selected={plant === selectedPlant}
          onClick={() => setSelectedPlant(plant)}
        >
          {plant.name}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};
