import '../styles/interfaces/AntagInfoMonsterHunter.scss';
import type { BooleanLike } from 'common/react';
import { useState } from 'react';
import { useBackend } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  DmIcon,
  Flex,
  Icon,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import type { Objective } from './common/Objectives';

type HunterWeapon = {
  id: string;
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
};

type JournalEntry = {
  ref: string;
  name: string;
  text: string;
  abilities: string[];
  icon: string;
};

type Info = {
  weapon_claimed: BooleanLike;
  rabbits_spotted: number;
  rabbits_remaining: number;
  all_completed: BooleanLike;
  apocalypse: BooleanLike;
  objectives: Objective[];
  weapons: HunterWeapon[];
  journal: JournalEntry[];
  sightings: Record<string, string>;
};

enum Tab {
  Hunt,
  Journal,
  Guide,
}

const HunterObjectives = (props) => {
  const {
    act,
    data: { objectives = [], all_completed, rabbits_remaining, apocalypse },
  } = useBackend<Info>();
  return (
    <Section title="Objectives">
      <Stack vertical align="center">
        <Stack.Item>
          {objectives.map((objective) => (
            <Box key={objective.explanation}>
              <Stack align="baseline">
                <Stack.Item>
                  <Icon
                    name={objective.complete ? 'check' : 'times'}
                    color={objective.complete ? 'good' : 'bad'}
                    size={2}
                    verticalAlign="middle"
                  />
                </Stack.Item>
                <Stack.Item grow bold>
                  {objective.explanation}
                </Stack.Item>
              </Stack>
            </Box>
          ))}
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            textAlign="center"
            align="middle"
            content={'Commence Apocalypse'}
            fontSize="200%"
            disabled={!all_completed || rabbits_remaining > 0 || apocalypse}
            onClick={() => act('reckoning')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Rabbits = () => {
  const {
    data: { rabbits_spotted, rabbits_remaining },
  } = useBackend<Info>();
  return (
    <Box className="AntagInfoMonsterHunter__rabbits">
      {[...Array(rabbits_spotted + rabbits_remaining)].map((_, index) => (
        <DmIcon
          key={index}
          className={
            index < rabbits_spotted
              ? 'AntagInfoMonsterHunter__rabbit'
              : 'AntagInfoMonsterHunter__rabbit AntagInfoMonsterHunter__rabbit--hidden'
          }
          icon="icons/mob/rabbit.dmi"
          icon_state="white_rabbit"
          width="64px"
          height="64px"
        />
      ))}
    </Box>
  );
};

const RiftProgress = () => {
  const {
    data: { rabbits_spotted, rabbits_remaining },
  } = useBackend<Info>();
  const total_rabbits = rabbits_remaining + rabbits_spotted;
  return (
    <Section title="Rifts">
      <Stack vertical textAlign="center">
        <Stack.Item>
          <Rabbits />
        </Stack.Item>
        <Stack.Item className="AntagInfoMonsterHunter__count">
          {rabbits_remaining < 1 ? (
            <Box inline bold textColor="red">
              YOU HAVE OPENED ALL THE RIFTS.
            </Box>
          ) : (
            <Box inline>
              {'You have opened '}
              <Box inline bold textColor="green">
                {rabbits_spotted}
              </Box>
              {' out of '}
              <Box inline bold textColor="red">
                {total_rabbits}
              </Box>
              {' rifts.'}
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const HuntersJournal = () => {
  const {
    data: { journal = [], sightings = {} },
  } = useBackend<Info>();
  if (!journal.length) {
    return (
      <Section title="Hunter's Journal">
        <Box className="AntagInfoMonsterHunter__empty">
          No prey named yet. Open a rift to name one.
        </Box>
      </Section>
    );
  }
  return (
    <Section title="Hunter's Journal">
      {journal.map((entry) => {
        const seen_in = sightings[entry.ref];
        return (
          <Box key={entry.ref} className="AntagInfoMonsterHunter__entry">
            <Box className="AntagInfoMonsterHunter__prey">
              <Icon
                name={entry.icon}
                className="AntagInfoMonsterHunter__kind"
              />
              {entry.name}
            </Box>
            <BlockQuote className="AntagInfoMonsterHunter__quote">
              {entry.text}
            </BlockQuote>
            {(!!seen_in || entry.abilities.length > 0) && (
              <LabeledList>
                {!!seen_in && (
                  <LabeledList.Item label="Seen in">{seen_in}</LabeledList.Item>
                )}
                {entry.abilities.length > 0 && (
                  <LabeledList.Item label="Abilities">
                    {entry.abilities.map((ability) => (
                      <Box key={ability}>{ability}</Box>
                    ))}
                  </LabeledList.Item>
                )}
              </LabeledList>
            )}
          </Box>
        );
      })}
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

const WeaponPicker = () => {
  const {
    data: { weapons = [] },
  } = useBackend<Info>();
  return (
    <Section title="Pick your Hunter tool">
      {weapons.map((weapon) => (
        <HunterWeaponSelection key={weapon.id} weapon={weapon} />
      ))}
    </Section>
  );
};

const HuntersGuide = () => {
  const {
    data: { rabbits_spotted, rabbits_remaining },
  } = useBackend<Info>();
  return (
    <>
      <Section title="Your Duty">
        <Box className="AntagInfoMonsterHunter__yapping">
          <p>
            You are my pawn, and a pawn has exactly one road. First, a weapon:
            claim one at the bottom of the <b>Hunt</b> tab. It will come up
            through a rabbit hole. Should you lose it, <b>Mind Your Things</b>{' '}
            fetches it back. Do try not to lose it.
          </p>
          <p>
            There are <b>{rabbits_spotted + rabbits_remaining} rifts</b> under
            my floors. Use the <b>Red Queen card</b> in your hand and it will
            tell you how warm you are, and how many floors up or down. When you
            find one, strike it with your weapon and hold perfectly still until
            it <b>opens</b>. It takes a while. People will watch you do it. Let
            them.
          </p>
          <p>
            Every rift names one of your prey in the <b>Journal</b>, puts a{' '}
            <b>rabbit eye</b> in your hand, and lets my white rabbits loose on
            the station.
          </p>
          <p>
            When your prey is dead and every rift is open, stand on the station
            and press <b>Commence Apocalypse</b> on the <b>Hunt</b> tab. Then
            you shall be crowned. What happens to everyone else is not your
            concern.
          </p>
        </Box>
      </Section>
      <Section title="Gifts">
        <Box className="AntagInfoMonsterHunter__yapping">
          <p>
            Good pawns are rewarded. Your first rift gives you the{' '}
            <b>Damned Rabbit Mask</b>. Wear it, and you may visit Wonderland
            with <b>To Wonderland</b>, or slip through the walls as a{' '}
            <b>Paradox Rabbit</b>.
          </p>
          <p>
            The second gives you the <b>Hunter&apos;s Revolver</b>, and the
            knack of making <b>bloodsilver bullets</b> out of your own blood.
            The third gives you <b>Follow Suit</b>, which dresses you in a
            proper uniform at last.
          </p>
        </Box>
      </Section>
      <Section title="Your Helpers">
        <Box className="AntagInfoMonsterHunter__yapping">
          <p>
            My white rabbits stop and stare whenever they see your prey. Let
            them stare for a little while, and you will be told where it is. Do
            not kick them. If you would rather not wait, <b>Hunter Vision</b>{' '}
            shows you any prey nearby as a white rabbit, though only for a
            moment.
          </p>
          <p>
            Set your weapon on the <b>forge in Wonderland</b>, then offer the
            forge a rabbit eye. Three eyes, three improvements. A fourth would
            be greedy.
          </p>
        </Box>
      </Section>
      <Section title="Manners for Monsters">
        <Box className="AntagInfoMonsterHunter__yapping">
          <p>
            Only you may fire my revolver. A <b>bloodsilver</b> bullet barely
            scratches, but for a short while your prey cannot heal and cannot
            vanish.
          </p>
          <p>
            Bloodsuckers want a stake. You know how to make <b>hardened</b> and{' '}
            <b>silver stakes</b>. Stake one while it is dead or in torpor, and
            it stays that way.
          </p>
          <p>
            Changelings get up again, which is rude. Bring back a{' '}
            <b>jack in the bomb</b> from Wonderland and set it at their feet.
            Nothing will be left to get up. It goes off a few moments after you
            prime it, so do not dawdle. You cannot prime it in Wonderland, and
            anyone but you who tries will have it go off in their hands.
          </p>
        </Box>
      </Section>
    </>
  );
};

export const AntagInfoMonsterHunter = (props) => {
  const {
    data: { weapon_claimed, journal = [] },
  } = useBackend<Info>();
  const [tab, setTab] = useState(Tab.Hunt);
  return (
    <Window width={650} height={700} theme="wonderland">
      <Window.Content className="AntagInfoMonsterHunter">
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid className="AntagInfoMonsterHunter__tabs">
              <Tabs.Tab
                icon="crosshairs"
                selected={tab === Tab.Hunt}
                onClick={() => setTab(Tab.Hunt)}
              >
                Hunt
              </Tabs.Tab>
              <Tabs.Tab
                icon="book-open"
                selected={tab === Tab.Journal}
                onClick={() => setTab(Tab.Journal)}
                rightSlot={journal.length > 0 && journal.length}
              >
                Journal
              </Tabs.Tab>
              <Tabs.Tab
                icon="scroll"
                selected={tab === Tab.Guide}
                onClick={() => setTab(Tab.Guide)}
              >
                Guide
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow className="AntagInfoMonsterHunter__page">
            {tab === Tab.Hunt && (
              <>
                <Section>
                  <Box className="AntagInfoMonsterHunter__yapping">
                    There was never a contract. I do not make them. Monsters
                    have crept onto my board, and you will take them off it, one
                    by one. Then you will open the last rift, and Wonderland
                    will come up through the floors to meet the station. It has
                    been waiting a very long time. Do sit up straight when it
                    arrives.
                  </Box>
                </Section>
                <RiftProgress />
                <HunterObjectives />
                {!weapon_claimed && <WeaponPicker />}
              </>
            )}
            {tab === Tab.Journal && <HuntersJournal />}
            {tab === Tab.Guide && <HuntersGuide />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
