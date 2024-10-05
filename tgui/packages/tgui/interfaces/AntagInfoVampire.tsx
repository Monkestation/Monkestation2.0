import { resolveAsset } from '../assets';
import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import { ObjectivePrintout, Objective } from './common/Objectives';

type Info = {
  objectives: Objective[];
};

type VampireInfo = {
  clan: ClanInfo;
  in_clan: BooleanLike;
  ability: AbilityInfo[];
};

type ClanInfo = {
  clan_name: string;
  clan_desc: string;
  clan_icon: string;
};

type AbilityInfo = {
  ability_name: string;
  ability_desc: string;
  ability_icon: string;
};

export const AntagInfoVampire = (props: any) => {
  const [tab, setTab] = useLocalState('tab', 1);
  return (
    <Window width={620} height={530} theme="spookyconsole">
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}
          >
            Introduction
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}
          >
            Clan & Abilities
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <VampireIntro />}
        {tab === 2 && <VampireClan />}
      </Window.Content>
    </Window>
  );
};

const VampireIntro = () => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack vertical fill overflowY="auto" overflowX="hidden">
      <Stack.Item>
        <Section fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are a vampire, an undead blood-seeking monster living
              aboard the station.
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout
                objectives={objectives}
                titleMessage="Your family lord has given you these goals"
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Strengths and Weaknesses">
          <Stack vertical>
            <Stack.Item>
              <span>
                You slowly recover from injuries and depend on the lifeforce
                of living sapients to sustain yourself. Don&apos;t abstain from
                indulging in blood for too long, or else you&apos;ll
              </span>
              <span className={'color-red'}> turn to dust!</span>
              <br /><br />
              <span>
                Your appearance and lack of blood or genes are your defining traits.
                Masquerade can be used to disguise yourself as a mortal, at a cost.
              </span>
              <br /><br />
              <span>
                Avoid being detected by the masses, or else the crew
                may obtain countermeasures such as garlic or silver.
                You can strategically convert others to your cause
                to sew disarray into the upper ranks. Just make sure
                to keep your thralls in check until they mature.
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Items">
          <Stack vertical>
            <Stack.Item>
              You can rest in a <b>coffin</b> to recover from more gruesome injuries.
              <br />
              If you lack adequate protection, <b>starlight</b> will burn you to death.
            </Stack.Item>
            <Stack.Item>
              <Section textAlign="center" textColor="red" fontSize="20px">
                Other vampires are not necessarily your allies, but your
                survival may depend on cooperation. Betray them at your own
                discretion and peril, for it holds no inherent benefits.
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const VampireClan = (props: any) => {
  const { act, data } = useBackend<VampireInfo>();
  const { clan, in_clan } = data;

  if (!in_clan) {
    return (
      <Section>
        <Box mt={5} bold textColor="red" textAlign="center" fontSize="40px">
          You are not in a clan.
        </Box>
        <Box mt={3}>
          <Button
            fluid
            icon="users"
            content="Join Clan"
            textAlign="center"
            fontSize="30px"
            lineHeight={2}
            onClick={() => act('join_clan')}
          />
        </Box>
      </Section>
    );
  }

  return (
    <Stack vertical fill overflowY="auto">
      <Stack.Item>
        <Section>
          <Box
            as="img"
            height="20rem"
            opacity={0.25}
            src={resolveAsset(`vampire.${clan.clan_icon}.png`)}
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
              position: 'absolute',
            }}
          />
          <Stack.Item fontSize="20px" textAlign="center">
            You are part of the {clan.clan_name}
          </Stack.Item>
          <Stack.Item fontSize="16px">
            {clan.clan_desc}
          </Stack.Item>
        </Section>
        <AbilitySection />
      </Stack.Item>
    </Stack>
  );
};

const AbilitySection = (props: any) => {
  const { act, data } = useBackend<VampireInfo>();
  const { ability } = data;
  if (!ability) {
    return <Section minHeight="220px" />;
  }

  const [selectedAbility, setSelectedAbility] = useLocalState('ability', ability[0]);

  return (
    <Section
      title="Abilities"
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={
            'Select an ability using the dropdown menu for an in-depth explanation.'
          }
        />
      }
    >
      <Stack fill>
        <Stack.Item minWidth="20%">
          <Dropdown
            displayText={selectedAbility.ability_name}
            selected={selectedAbility.ability_name}
            width="100%"
            options={ability.map((abilities) => abilities.ability_name)}
            onSelected={(abilityName: string) =>
              setSelectedAbility(
                ability.find((p) => p.ability_name === abilityName) || ability[0],
              )
            }
          />
          {/*selectedAbility && selectedAbility.ability_icon && (
            <Box
              position="absolute"
              height="12rem"
              as="img"
              src={resolveAsset(`vampire.${selectedAbility.ability_icon}.png`)}
            />
          )*/}
          <Divider Vertical />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow fontSize="16px">
          {selectedAbility && selectedAbility.ability_desc}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
