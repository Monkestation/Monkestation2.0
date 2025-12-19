// THIS IS A MONKESTATION UI FILE

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  DmIcon,
  Dropdown,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import { Objective, ObjectivePrintout } from './common/Objectives';

type BorerInformation = {
  ability: AbilityInfo[];
};

type AbilityInfo = {
  ability_name: string;
  ability_explanation: string;
  ability_icon: string;
  ability_icon_state: string;
};

type Info = {
  objectives: Objective[];
};

export const AntagInfoBorer = (props: any) => {
  const [tab, setTab] = useLocalState('tab', 1);
  return (
    <Window width={620} height={580} theme="generic">
      <Window.Content>
        <Stack vertical fill>
          <Tabs fluid>
            <Tabs.Tab
              icon="list"
              lineHeight="23px"
              selected={tab === 1}
              onClick={() => setTab(1)}
            >
              Introduction
            </Tabs.Tab>
            <Tabs.Tab
              icon="dumbbell"
              lineHeight="23px"
              selected={tab === 2}
              onClick={() => setTab(2)}
            >
              Ability explanations
            </Tabs.Tab>
            <Tabs.Tab
              icon="warning"
              lineHeight="23px"
              selected={tab === 3}
              onClick={() => setTab(3)}
            >
              Borer side-effects
            </Tabs.Tab>
            <Tabs.Tab
              icon="info"
              lineHeight="23px"
              selected={tab === 4}
              onClick={() => setTab(4)}
            >
              Basic chemical information
            </Tabs.Tab>
          </Tabs>
          {tab === 1 && <MainPage />}
          {tab === 2 && <AbilitySection />}
          {tab === 3 && <DisadvantageInfo />}
          {tab === 4 && <BasicChemistry />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MainPage = () => {
  const {
    data: { objectives },
  } = useBackend<Info>();
  return (
    <Stack vertical fill>
      <Section>
        <Stack vertical>
          <Stack.Item textColor="red" fontSize="20px">
            You are a Cortical Borer, a creature that crawls into peoples ears
            to then settle in the brain.
          </Stack.Item>
          <Stack.Item my={0.5}>
            <ObjectivePrintout objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Section>
      <Section title="Essentials" fill scrollable>
        <Stack vertical>
          <Stack.Item color="red">Host and you</Stack.Item>
          <Stack.Item>
            You depend on a host for survival and reproduction, you slowly
            regenerate your health whilst inside of a host but whilst outside of
            one you can be squished by anyone stepping onto you, killing you.
          </Stack.Item>
          <Stack.Item>
            When speaking, you will directly communicate to your host, by adding
            &quot; ; &quot; to the start of your message you will instead speak
            to the hivemind of all the borers
          </Stack.Item>
          <Stack.Item color="red">Creating resources and their uses</Stack.Item>
          <Stack.Item>
            While inside of a host you will slowly generate internal chemicals,
            evolution points and chemical points.
          </Stack.Item>
          <Stack.Item color="red">Internal chemical points</Stack.Item>
          <Stack.Item>
            are used for using most of the abilities, their main use is in
            injecting chemicals into your host using the chemical injector
          </Stack.Item>
          <Stack.Item color="red">Evolution points</Stack.Item>
          <Stack.Item>
            are mostly used in the evolution tree and choosing your focus, both
            of those being essential to surviving and completing your objectives
          </Stack.Item>
          <Stack.Item color="red">Chemical evolution points </Stack.Item>
          <Stack.Item>
            are used in learning new chemicals from your possible list of
            learn-able chemicals, along with learning chemicals from the hosts
            blood for both their benefit and your objectives
          </Stack.Item>
        </Stack>
      </Section>
    </Stack>
  );
};

const AbilitySection = (props: any) => {
  const { act, data } = useBackend<BorerInformation>();
  const { ability } = data;
  if (!ability) {
    return <Section />;
  }

  const [selectedAbility, setSelectedAbility] = useLocalState(
    'ability',
    ability[0],
  );

  return (
    <Section
      fill
      title="Abilities"
      style={{ overflowY: 'auto' }}
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
      <Stack>
        <Stack.Item grow>
          <Stack vertical>
            <Dropdown
              displayText={selectedAbility.ability_name}
              selected={selectedAbility.ability_name}
              width="100%"
              options={ability.map((abilities) => abilities.ability_name)}
              onSelected={(abilityName: string) =>
                setSelectedAbility(
                  ability.find((p) => p.ability_name === abilityName) ||
                    ability[0],
                )
              }
            />
            {selectedAbility && (
              <DmIcon
                icon={selectedAbility.ability_icon}
                icon_state={selectedAbility.ability_icon_state}
                width={'128px'}
                height={'128px'}
              />
            )}
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow={1} fontSize="16px">
          {selectedAbility && selectedAbility.ability_explanation}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const DisadvantageInfo = () => {
  return (
    <Section
      fill
      title="How i didnt kill my host 101"
      style={{ overflowY: 'auto' }}
    >
      <Stack vertical fill>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              Whilst in a host you can provide many benefits, but also dangerous
              side-effects due to your sensitive brain manipulation. Here&apos;s
              how to prevent them
            </Stack.Item>
            <Stack.Item mx={1}>
              1. Whilst inside of a host we will passivelly make their health
              unable to be read due to our body obstructing the somatosensory
              cortex signals
            </Stack.Item>
            <Stack.Item>
              Prevention method - observe the hosts health carefully using
              &quot;Check Blood&quot;, heal any injuries and inform the host
              about any major wounds
            </Stack.Item>
            <Stack.Item mx={1}>
              2. Whilst inside of a host we will slowly deal toxin damage
              over-time up to 80 in total. This can be deadly when combined with
              any amount of brute/burn damage
            </Stack.Item>
            <Stack.Item>
              Prevention method - observe the hosts health carefully using
              &quot;Check Blood&quot;, inject toxin damage restoring chemicals
            </Stack.Item>
            <Stack.Item mx={1}>
              3. Whilst inside of a host most of our actions will deal brain
              damage including generating evolution and chemical evolution
              points, due to either sensetivelly manipulating the host&apos;s
              neurons or needing to &quot;aquire&quot; more space for growth
            </Stack.Item>
            <Stack.Item>
              Prevention method - observe the hosts health carefully using
              &quot;Check Blood&quot;, inject mannitol to cure brain damage,
              inject neurine for any brain traumas that might have been a result
              of our expansion
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const BasicChemistry = () => {
  return (
    <Section
      fill
      title="What does the eldritch essence do again?"
      style={{ overflowY: 'auto' }}
    >
      <Stack vertical fill>
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              Secreting chemicals has proven difficult for many borers, yet you
              have prepared carefully for your first expendition into the hosts
              body. Lets not mess it up by killing them.
            </Stack.Item>
            <Stack.Item>
              This is only the bare minimum of what we should get knowledgable
              about
            </Stack.Item>
            <Stack.Item color="red">Libital</Stack.Item>
            <Stack.Item>
              Quickly restores our hosts
              <Box inline textColor="red" ml={0.5} mr={0.5}>
                {' '}
                Brute{' '}
              </Box>
              damage at the cost of causing slight liver damage.
            </Stack.Item>
            <Stack.Item>Overdose: None</Stack.Item>
            <Stack.Item>Metabolism Rate: 0.05u/s</Stack.Item>
            <Stack.Item color="yellow">Lenturi</Stack.Item>
            <Stack.Item>
              Quickly restores our hosts
              <Box inline textColor="yellow" ml={0.5} mr={0.5}>
                {' '}
                Burn{' '}
              </Box>
              damage at the cost of causing slight stomach damage and slowing
              down our host as long as its in their system
            </Stack.Item>
            <Stack.Item>Overdose: None</Stack.Item>
            <Stack.Item>Metabolism Rate: 0.05u/s</Stack.Item>
            <Stack.Item color="green">Seiver</Stack.Item>
            <Stack.Item>
              Heals{' '}
              <Box inline textColor="green" ml={-0.1} mr={-0.1}>
                Toxin
              </Box>{' '}
              damage at the slight cost of heart damage
            </Stack.Item>
            <Stack.Item>Overdose: None</Stack.Item>
            <Stack.Item>Metabolism Rate: 0.05u/s</Stack.Item>
            <Stack.Item color="blue">Convermol</Stack.Item>
            <Stack.Item>
              Quickly restores our hosts
              <Box inline textColor="blue" ml={0.5} mr={0.5}>
                Oxygen
              </Box>
              damage at the cost of causing 1:5th the toxin damage to our host
            </Stack.Item>
            <Stack.Item>Overdose: 35 units</Stack.Item>
            <Stack.Item>Metabolism Rate: 0.05u/s</Stack.Item>
            <Stack.Item color="purple">
              Unknown Methamphetamine Isomer
            </Stack.Item>
            <Stack.Item>
              A specially advanced version of what our hosts call
              &quot;meth&quot;. It has all the benefits of meth without causing
              any brain damage to the host and has a higher overdose
            </Stack.Item>
            <Stack.Item>Overdose: 40 units</Stack.Item>
            <Stack.Item>Metabolism Rate: 0.075u/s</Stack.Item>
            <Stack.Item color="purple">Spaceacillin</Stack.Item>
            <Stack.Item>
              Helps our hosts immune system, making it quickly gain resistance
              to any pathogens inside of the host.
            </Stack.Item>
            <Stack.Item>
              While being effective it will most likelly not be enough to fully
              cure our host
            </Stack.Item>
            <Stack.Item>Overdose: None</Stack.Item>
            <Stack.Item>Metabolism Rate: 0.01u/s</Stack.Item>
            <Stack.Item color="green">Multiver</Stack.Item>
            <Stack.Item>
              Purges toxins and medicines inside of our host while healing
              <Box inline textColor="green" ml={0.5} mr={0.5}>
                Toxin
              </Box>
              damage, at the cost of slight lung damage.
            </Stack.Item>
            <Stack.Item>
              The more unique medicines the host has in their system, the more
              this chemical heals.
            </Stack.Item>
            <Stack.Item>
              At 2 unique medicines it no longer purges medicines
            </Stack.Item>
            <Stack.Item>Overdose: None</Stack.Item>
            <Stack.Item>Metabolism Rate: 0.05u/s</Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
