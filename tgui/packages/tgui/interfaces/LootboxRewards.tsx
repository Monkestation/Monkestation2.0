import { useBackend } from '../backend';
import { Box, Divider, DmIcon, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  numberlowtokens: number;
  numbermedtokens: number;
  numberhightokens: number;
  loadoutitems: RewardItem[];
};

type RewardItem = {
  icon: string;
  iconstate: string;
  name: string;
};

const ItemDisplay = (props) => {
  const { name, icon, iconstate } = props;

  return (
    <Box
      textAlign="center"
      style={{ border: 'thin solid grey' }}
      width="75px"
      height="75px"
    >
      <DmIcon icon={icon} icon_state={iconstate} />
      <Box fontSize="10px" bold textColor="blue" italic textAlign="bottom">
        {name}
      </Box>
    </Box>
  );
};
export const LootboxRewards = (props) => {
  const { data } = useBackend<Data>();
  const {
    numberlowtokens,
    numbermedtokens,
    numberhightokens,
    loadoutitems = [],
  } = data;
  return (
    <Window title="Loot! Wowza!" width={480} height={250}>
      <Stack fill gc={0}>
        <Section title="Tokens" width="24%" p={0} m={0} height="100%">
          <Stack fill vertical>
            <Box textAlign="center" fontSize="14px" bold height="33%">
              Low
              <Divider hidden />
              {numberlowtokens}
              <Divider />
            </Box>
            <Box textAlign="center" fontSize="14px" bold height="33%">
              Medium
              <Divider hidden />
              {numbermedtokens}
              <Divider />
            </Box>
            <Box textAlign="center" fontSize="14px" bold height="33%">
              High
              <Divider hidden />
              {numberhightokens}
            </Box>
          </Stack>
        </Section>
        <Divider vertical />
        <Section
          title="Items"
          width="74%"
          p={0}
          m={0}
          height="100%"
          scrollable
          fill
        >
          <Stack draggable wrap scrollable={true} fill>
            {loadoutitems.map((tab) => (
              <Stack.Item key={tab.name}>
                <ItemDisplay
                  key={tab.name}
                  icon={tab.icon}
                  icon_state={tab.iconstate}
                  name={tab.name}
                />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack>
    </Window>
  );
};
