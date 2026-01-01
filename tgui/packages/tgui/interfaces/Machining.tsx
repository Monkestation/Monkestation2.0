import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Section,
  Stack,
  Tabs,
  Divider,
  Box,
  Button,
  Dimmer,
  Icon,
  Input,
  NoticeBox,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

const TAB_LIST = [
  { key: 'generalparts', label: 'General Parts' },
  { key: 'typeparts', label: 'Type Parts' },
  { key: 'specificparts', label: 'Specific Parts' },
  { key: 'assembly', label: 'Assembly' },
];

type Atoms = {
  [key: number]: number;
};

type Recipe = {
  ref: String;
  result: Number;
  category: String;
  name: String;
  desc: String;
  machinery_type: String;
  reqs: Atoms;
  machining_skill_required: Number;
};

type Data = {
  auto_build: BooleanLike;
  auto_dispense: BooleanLike;
  busy: BooleanLike;
  craftable: BooleanLike;
  user_machining_skill: BooleanLike;
  recipes: Recipe[];
  atom_data: String[];
};

export const Machining = (props) => {
  const [activeTab, setActiveTab] = useLocalState(
    'machiningTab',
    TAB_LIST[0].key,
  );
  const [searchText, setSearchText] = useLocalState('machiningSearch', '');

  const { act, data } = useBackend<Data>();
  const { busy, craftable, recipes, auto_dispense, auto_build } = data;

  return (
    <Window width={900} height={700}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width={'200px'}>
            <Input
              autoFocus
              placeholder={'Search in ' + recipes.length + ' designs...'}
              value={searchText}
              onInput={(e, value) => {
                setSearchText(value);
              }}
              mb={2}
              fluid
            />
            <Section fill>
              <Tabs vertical>
                {TAB_LIST.map((tab) => (
                  <Tabs.Tab
                    key={tab.key}
                    selected={activeTab === tab.key}
                    onClick={() => setActiveTab(tab.key)}
                  >
                    {tab.label}
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Box>
                <Dividers title={'Upgrades'} />
                <Tooltip
                  position="bottom"
                  content="Upgrade your machines as your skills increase to gain a wider selection of recipes."
                >
                  <NoticeBox position="relative" info>
                    Current User Skill Level:{' '}
                    {data.user_machining_skill ?? 'Unknown'}
                  </NoticeBox>
                </Tooltip>
                <Button.Checkbox
                  fluid
                  content="Auto Dispense (T3)"
                  checked={auto_dispense}
                  tooltip="Requires T3 Manipulators to be enabled"
                  onClick={() => act('toggle_dispense')}
                />
                <Button.Checkbox
                  fluid
                  content="Auto Build (T4)"
                  checked={auto_build}
                  tooltip="Requires T4 Manipulators to be enabled"
                  onClick={() => act('toggle_build')}
                />
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item grow my={'16px'}>
            <Box
              scrollable
              fill
              height={'100%'}
              pr={1}
              pt={1}
              mr={-1}
              style={{ 'overflow-y': 'auto' }}
            >
              <MainRecipeScreen tab={activeTab} searchText={searchText} />
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
      {busy ? (
        <Dimmer
          style={{
            'font-size': '2em',
            'text-align': 'center',
          }}
        >
          <Icon
            name={craftable ? 'check' : 'hourglass'}
            spin={craftable ? false : true}
          />
          {craftable
            ? ' Ready to produce!'
            : ' Awaiting materials for recipe...'}
          <Stack justify="center" align="center" my={2}>
            <Button
              my={0.3}
              lineHeight={2.5}
              align="center"
              content="Produce"
              disabled={!craftable || auto_dispense}
              color="green"
              icon="circle-notch"
              iconSpin={craftable ? 1 : 0}
              onClick={() => act('produce')}
            />
            <Button
              my={0.3}
              lineHeight={2.5}
              align="center"
              content="Abort"
              color="red"
              icon="wrench"
              onClick={() => act('abort')}
            />
          </Stack>
        </Dimmer>
      ) : null}
    </Window>
  );
};

const MainRecipeScreen = (props) => {
  const { act, data } = useBackend<Data>();
  const { tab, searchText } = props;
  const { recipes, atom_data, busy } = data;
  if (!recipes || !recipes.length) {
    return <Section>No recipes available for this tab.</Section>;
  }

  // Filter recipes by category (tab) / searchbar
  let filteredRecipes;

  if (searchText) {
    filteredRecipes = recipes.filter((recipe) =>
      recipe.name.toLowerCase().includes(searchText.toLowerCase()),
    );
  } else {
    filteredRecipes = recipes.filter((recipe) => recipe.category === tab);
  }

  if (!filteredRecipes.length) {
    return <Section>No recipes in this category.</Section>;
  }

  return (
    <>
      {filteredRecipes.map((recipe, index) => (
        <Section key={index} title={recipe.name}>
          <Stack>
            <Stack.Item>
              <Box
                width={'32px'}
                height={'32px'}
                style={{
                  transform: 'scale(2)',
                }}
                m={'16px'}
                className={`machining32x32 a${recipe.result}`}
              />
            </Stack.Item>
            <Stack.Item ml={'16px'} grow>
              {recipe.desc}
            </Stack.Item>
            <Button
              my={0.3}
              lineHeight={2.5}
              align="center"
              content="Make"
              disabled={!recipe.req_required}
              color="green"
              icon={busy ? 'circle-notch' : 'hammer'}
              iconSpin={busy ? 1 : 0}
              tooltip={
                recipe.machining_skill_required
                  ? `Requires machining skill level ${recipe.machining_skill_required} to construct.`
                  : 'No skill required.'
              }
              onClick={() =>
                act('make', {
                  recipe: recipe.ref,
                })
              }
            />
          </Stack>
          <Dividers title={'Materials'} />
          <Stack vertical>
            {recipe.reqs &&
              Object.keys(recipe.reqs).map((atom_id) => {
                const atomIndex = Number(atom_id) - 1;
                const atomInfo = atom_data?.[atomIndex];
                return (
                  <Stack.Item key={atom_id}>
                    <Stack>
                      <Stack.Item>
                        <Box
                          width={'32px'}
                          height={'32px'}
                          className={`machining32x32 a${atom_id}`}
                          mr={1}
                        />
                      </Stack.Item>
                      <Stack.Item grow>
                        {atomInfo}
                        {recipe.reqs[atom_id] > 1
                          ? ` x${recipe.reqs[atom_id]}`
                          : ''}
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                );
              })}
          </Stack>
        </Section>
      ))}
    </>
  );
};

const Dividers = ({ title }) => {
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item color={'gray'}>{title}</Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  ) as any;
};
