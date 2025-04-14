import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Icon,
  Flex,
  DmIcon,
  Dimmer,
} from '../components';
import { Window } from '../layouts';
import { Objective } from './common/Objectives';

type HunterWeapon = {
  id: string;
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
};

type Info = {
  weapon_claimed: BooleanLike;
  rabbits_spotted: number;
  rabbits_remaining: number;
  all_completed: BooleanLike;
  apocalypse: BooleanLike;
  objectives: Objective[];
  weapons: HunterWeapon[];
};

const HunterObjectives = (props) => {
  const {
    act,
    data: { objectives = [], all_completed, rabbits_remaining, apocalypse },
  } = useBackend<Info>();
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Section fill title="Objectives">
          {objectives.map((objective) => (
            <Box key={objective.explanation}>
              <Stack align="baseline">
                <Stack.Item grow bold>
                  {objective.explanation}
                </Stack.Item>
              </Stack>
              <Icon
                name={objective.complete ? 'check' : 'times'}
                color={objective.complete ? 'good' : 'bad'}
              />
            </Box>
          ))}
          <Box>
            <Button
              fluid
              textAlign="center"
              align="center"
              width={50}
              content={'Commence Apocalypse'}
              fontSize="200%"
              disabled={!all_completed || rabbits_remaining > 0 || apocalypse}
              onClick={() => act('reckoning')}
            />
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const HuntersGuide = () => {
  const {
    data: { rabbits_spotted },
  } = useBackend<Info>();

  return (
    <Section fill title="Hunter's Guide">
      <Stack vertical fill>
        <Stack.Item>
          <span>
            Look for the white rabbits! Use their eyes to upgrade your
            hunter&#39;s weapon, the red queen&#39;s card will guide you!{' '}
            <span className={'color-red'}>
              {' '}
              YOU HAVE FOUND {rabbits_spotted}{' '}
              {rabbits_spotted === 1 ? 'RABBIT' : 'RABBITS'}{' '}
            </span>
            Only once the contract is fullfilled and the rabbits are found will
            you be able to bring upon the
            <span className={'color-red'}> APOCALYPSE </span>!
          </span>
          <br />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const HunterWeaponSelection = (props: { weapon: HunterWeapon }) => {
  const {
    act,
    data: { weapon_claimed },
  } = useBackend<Info>();
  const { weapon } = props;
  return (
    <Box className="candystripe" p={1} pb={2}>
      <Flex justify="space-between" align="center">
        <Flex.Item pr={1}>
          <DmIcon
            icon={weapon.icon}
            icon_state={weapon.icon_state}
            verticalAlign="middle"
          />
        </Flex.Item>
        <Flex.Item grow>
          <Flex direction="column">
            <Flex.Item bold>{weapon.name}</Flex.Item>
            <Flex.Item>{weapon.desc}</Flex.Item>
          </Flex>
        </Flex.Item>
        <Flex.Item pl={0.5}>
          <Button
            height="3rem"
            verticalAlignContent="middle"
            bold
            disabled={weapon_claimed}
            onClick={() =>
              act('select', {
                weapon: weapon.id,
              })
            }
          >
            Claim
          </Button>
        </Flex.Item>
      </Flex>
    </Box>
  );
};

export const AntagInfoMonsterHunter = (props) => {
  const {
    data: { weapons = [], weapon_claimed },
  } = useBackend<Info>();
  return (
    <Window width={650} height={600} theme="spookyconsole">
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <HuntersGuide />
          </Stack.Item>
          <Stack.Item>
            <Box>
              <HunterObjectives />
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Section title="Pick your Hunter tool">
              {!!weapon_claimed && (
                <Dimmer fontSize="18px" align="center">
                  <Box bold textColor="red">
                    You have already claimed a weapon.
                  </Box>
                </Dimmer>
              )}
              {weapons.map((weapon) => (
                <HunterWeaponSelection key={weapon.id} weapon={weapon} />
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
