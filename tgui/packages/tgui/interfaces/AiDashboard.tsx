import { Fragment, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Input,
  LabeledControls,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Data = {
  current_cpu: number;
  used_cpu: number;
  max_cpu: number;
  integrity: number;
  location_name: string;
  location_coords: string;
  temperature: number;
};

export const AiDashboard = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    current_cpu,
    used_cpu,
    max_cpu,
    integrity,
    location_name,
    location_coords,
    temperature,
  } = data;

  const [tab, setTab] = useState(1);

  const amount_of_cpu = current_cpu ? current_cpu * max_cpu : 0;

  return (
    <Window width={650} height={600} title="Dashboard">
      <Window.Content scrollable>
        <Section
          title={'Status'}
          buttons={
            <Button
              onClick={() => act('toggle_contribute_cpu')}
              color={data.contribute_spare_cpu ? 'good' : 'bad'}
              icon={data.contribute_spare_cpu ? 'toggle-on' : 'toggle-off'}
            >
              {!data.contribute_spare_cpu ? 'NOT ' : null}Contributing Spare CPU
              to Research
            </Button>
          }
        >
          <LabeledControls>
            <LabeledControls.Item label="System Integrity">
              <ProgressBar
                ranges={{
                  good: [50, 100],
                  average: [25, 50],
                  bad: [0, 25],
                }}
                value={(integrity + 100) * 0.5}
                maxValue={100}
              >
                {(integrity + 100) * 0.5}%
              </ProgressBar>
            </LabeledControls.Item>
            <LabeledControls.Item label="Current Uplink Location">
              <Box bold color="average">
                {location_name}
                <Box>({location_coords})</Box>
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label="Uplink Temperature">
              <ProgressBar
                ranges={{
                  good: [-Infinity, 250],
                  average: [250, 750],
                  bad: [750, Infinity],
                }}
                value={temperature}
                maxValue={750}
              >
                {temperature}K
              </ProgressBar>
            </LabeledControls.Item>
          </LabeledControls>
          <Divider />
          <LabeledControls>
            <LabeledControls.Item label="Utilized CPU Power">
              <ProgressBar
                ranges={{
                  good: [used_cpu * 0.7, Infinity],
                  average: [used_cpu * 0.3, used_cpu * 0.7],
                  bad: [0, used_cpu * 0.3],
                }}
                value={data.used_cpu * amount_of_cpu}
                maxValue={amount_of_cpu}
              >
                {used_cpu ? used_cpu * 100 : 0}% (
                {used_cpu ? used_cpu * amount_of_cpu : 0}/{amount_of_cpu} THz)
              </ProgressBar>
            </LabeledControls.Item>
            <LabeledControls.Item label="Utilized RAM Capacity">
              <ProgressBar
                ranges={{
                  good: [data.current_ram * 0.7, Infinity],
                  average: [data.current_ram * 0.3, data.current_ram * 0.7],
                  bad: [0, data.current_ram * 0.3],
                }}
                value={data.used_ram}
                maxValue={data.current_ram}
              >
                {data.used_ram ? data.used_ram : 0}/{data.current_ram} TB
              </ProgressBar>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Divider />
        <Tabs>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Available Projects
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            Completed Projects
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
            Ability Charging
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
            Cloud Resources
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <AvailableProjects />}
        {tab === 2 && <CompletedProjects />}
        {tab === 3 && <AbilityCharging />}
        {tab === 4 && <NetworkingResources />}
      </Window.Content>
    </Window>
  );
};

type AvailableProjectsData = {
  categories: string[];
  available_projects: AvailableProjectData[];
  used_cpu: number;
};

type AvailableProjectData = {
  name: string;
  available: BooleanLike;
  category: string;
  assigned_cpu: number;
  research_cost: number;
  ram_required: number;
  research_requirements: string;
  description: string;
  research_progress: number;
};

const AvailableProjects = (props) => {
  const { act, data } = useBackend<AvailableProjectsData>();
  const { categories, available_projects, used_cpu } = data;

  const [search, setSearch] = useState('');
  const [selectedCategory, setCategory] = useState(categories[0]);

  const remaining_cpu = (1 - used_cpu) * 100;

  return (
    <Section
      title="Available Projects"
      buttons={
        <Input
          fluid
          value={search}
          placeholder="Search.."
          onChange={(value) => setSearch(value)}
        />
      }
    >
      <Tabs>
        {categories.map((category, index) => (
          <Tabs.Tab
            key={index}
            selected={!search ? selectedCategory === category : undefined}
            onClick={() => setCategory(category)}
          >
            {category}
          </Tabs.Tab>
        ))}
      </Tabs>
      {available_projects
        .filter((project) => {
          if (search) {
            const searchableString = String(project.name).toLowerCase();
            return searchableString.match(new RegExp(search, 'i'));
          }
          return project.category === selectedCategory;
        })
        .map((project, index) => (
          <Section
            key={index}
            title={
              <Box inline color={project.available ? 'lightgreen' : 'bad'}>
                {project.name} |{' '}
                {project.available ? 'Available' : 'Unavailable'}
              </Box>
            }
            buttons={
              <Fragment>
                <Box inline bold>
                  Assigned CPU:&nbsp;
                </Box>
                <NumberInput
                  unit="%"
                  value={project.assigned_cpu * 100}
                  minValue={0}
                  maxValue={remaining_cpu + project.assigned_cpu * 100}
                  onChange={(value) =>
                    act('allocate_cpu', {
                      project_name: project.name,
                      amount: Math.round((value / 100) * 100) / 100,
                    })
                  }
                />
                <Button
                  icon="arrow-up"
                  disabled={used_cpu === 1}
                  onClick={() =>
                    act('max_cpu', {
                      project_name: project.name,
                    })
                  }
                >
                  Max
                </Button>
              </Fragment>
            }
          >
            <Box inline bold>
              Research Cost:&nbsp;
            </Box>
            <Box inline>{project.research_cost} THz</Box>
            <br />
            <Box inline bold>
              RAM Requirement:&nbsp;
            </Box>
            <Box inline>{project.ram_required} TB</Box>
            <br />
            <Box inline bold>
              Research Requirements:&nbsp;
            </Box>
            <Box inline>{project.research_requirements}</Box>
            <Box mb={1}>{project.description}</Box>
            <ProgressBar
              value={project.research_progress / project.research_cost}
            >
              {Math.round(
                (project.research_progress / project.research_cost) * 100 * 100,
              ) / 100}
              % ({Math.round(project.research_progress * 100) / 100}/
              {project.research_cost} THz)
            </ProgressBar>
          </Section>
        ))}
    </Section>
  );
};

type CompletedProjectsData = {
  categories: string[];
  completed_projects: CompletedProject[];
};

type CompletedProject = {
  name: string;
  description: string;
  running: BooleanLike;
  can_be_run: BooleanLike;
  category: string;
  ram_required: number;
};

const CompletedProjects = (props) => {
  const { act, data } = useBackend<CompletedProjectsData>();
  const { categories, completed_projects } = data;

  const [searchCompleted, setSearchCompleted] = useState('');
  const [activeProjectsOnly, setActiveProjectsOnly] = useState(true);
  const [selectedCategory, setCategory] = useState(data.categories[0]);

  return (
    <Section
      title="Completed Projects"
      buttons={
        <Fragment>
          <Button.Checkbox
            checked={activeProjectsOnly}
            onClick={() => setActiveProjectsOnly(!activeProjectsOnly)}
          >
            Runnable Projects Only
          </Button.Checkbox>
          <Input
            value={searchCompleted}
            placeholder="Search.."
            onChange={(value) => setSearchCompleted(value)}
          />
        </Fragment>
      }
    >
      <Tabs>
        {categories.map((category, index) => (
          <Tabs.Tab
            key={index}
            selected={
              !searchCompleted ? selectedCategory === category : undefined
            }
            onClick={() => setCategory(category)}
          >
            {category}
          </Tabs.Tab>
        ))}
      </Tabs>
      {completed_projects
        .filter((project) => {
          if (searchCompleted) {
            const searchableString = String(project.name).toLowerCase();
            return searchableString.match(new RegExp(searchCompleted, 'i'));
          }
          if (activeProjectsOnly && !project.can_be_run) {
            return false;
          }
          return project.category === selectedCategory;
        })
        .map((project, index) => (
          <Section
            key={index}
            title={
              <Box
                inline
                color={
                  project.can_be_run
                    ? project.running
                      ? 'lightgreen'
                      : 'bad'
                    : 'lightgreen'
                }
              >
                {' '}
                {project.name} |{' '}
                {project.can_be_run
                  ? project.running
                    ? 'Running'
                    : 'Not Running'
                  : 'Passive'}
              </Box>
            }
            buttons={
              !!project.can_be_run && (
                <Button
                  icon={project.running ? 'stop' : 'play'}
                  color={project.running ? 'bad' : 'good'}
                  onClick={() =>
                    act(project.running ? 'stop_project' : 'run_project', {
                      project_name: project.name,
                    })
                  }
                >
                  {project.running ? 'Stop' : 'Run'}
                </Button>
              )
            }
          >
            {!!project.can_be_run && (
              <Box bold>RAM Requirement: {project.ram_required} TB</Box>
            )}
            <Box mb={1}>{project.description}</Box>
          </Section>
        ))}
    </Section>
  );
};

type AbilityChargingData = {
  chargeable_abilities: ChargeableAbility[];
};

type ChargeableAbility = {
  uses: number;
  max_uses: number;
  name: string;
  assigned_cpu: number;
  project_name: string;
  progress: number;
  cost: number;
};

const AbilityCharging = (props) => {
  const { act, data } = useBackend<AbilityChargingData>();
  const { chargeable_abilities } = data;
  const remaining_cpu = (1 - data.used_cpu) * 100;

  return (
    <Section title="Ability Charging">
      {chargeable_abilities
        .filter((ability) => {
          return ability.uses < ability.max_uses;
        })
        .map((ability, index) => (
          <Section
            key={index}
            title={
              <Box inline>
                {ability.name} | Uses Remaining: {ability.uses}/
                {ability.max_uses}
              </Box>
            }
            buttons={
              <Fragment>
                <Box inline bold>
                  Assigned CPU:&nbsp;
                </Box>
                <NumberInput
                  unit="%"
                  value={ability.assigned_cpu * 100}
                  minValue={0}
                  maxValue={remaining_cpu + ability.assigned_cpu * 100}
                  onChange={(value) =>
                    act('allocate_recharge_cpu', {
                      project_name: ability.project_name,
                      amount: Math.round((value / 100) * 100) / 100,
                    })
                  }
                />
              </Fragment>
            }
          >
            <ProgressBar value={ability.progress / ability.cost}>
              {Math.round((ability.progress / ability.cost) * 100 * 100) / 100}%
              ({Math.round(ability.progress * 100) / 100}/{ability.cost} THz)
            </ProgressBar>
          </Section>
        ))}
    </Section>
  );
};

const NetworkingResources = (props) => {
  const { act, data } = useBackend();

  const amount_of_cpu = data.current_cpu ? data.current_cpu * data.max_cpu : 0;
  const tooltipDisabled = data.human_only
    ? 'Locked by organics. Please request their assistance.'
    : '';

  return (
    <Section title="Computing Resources">
      <Section
        title="Networked Resources"
        buttons={
          <Button
            icon="trash"
            onClick={() => act('clear_ai_resources')}
            disabled={data.human_only}
            tooltip={tooltipDisabled}
          >
            Clear AI Resources
          </Button>
        }
      >
        CPU Capacity:
        <Stack>
          <ProgressBar minValue={0} value={data.current_cpu} maxValue={1}>
            {amount_of_cpu} THz
          </ProgressBar>
        </Stack>
        RAM Capacity:
        <Stack>
          <ProgressBar
            minValue={0}
            value={data.current_ram}
            maxValue={data.max_ram}
          >
            {data.current_ram} TB
          </ProgressBar>
        </Stack>
      </Section>
    </Section>
  );
};
