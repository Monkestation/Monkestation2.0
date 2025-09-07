import { useBackend, useLocalState } from '../backend';
import { Box, Button, DmIcon, Flex, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { Objective, ObjectivePrintout } from './common/Objectives';

type BloodsuckerInformation = {
  clan?: ClanInfo;
  powers: PowerInfo[];
};

type ClanInfo = {
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
};

type PowerInfo = {
  name: string;
  explanation: string;
  icon: string;
  icon_state: string;
};

type Info = {
  objectives: Objective[];
};

export const AntagInfoBloodsucker = (props: any) => {
  const [tab, setTab] = useLocalState('tab', 1);
  return (
    <Window width={620} height={700} theme="spookyconsole">
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
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
                Clan & Powers
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 1 && <BloodsuckerIntro />}
            {tab === 2 && <BloodsuckerClan />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BloodsuckerIntro = () => {
  const {
    data: { objectives },
  } = useBackend<Info>();
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px" textAlign="center">
              You are a <b>Bloodsucker</b>, an undead blood-seeking monster
              living aboard Space Station 13
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout objectives={objectives} />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Strengths and Weaknesses">
          <Stack vertical>
            <Stack.Item>
              <span>
                You regenerate your health slowly, you&#39;re weak to fire, and
                you depend on blood to survive. Don&#39;t allow your blood to
                run too low, or you&#39;ll enter a
              </span>
              <span className={'color-red'}> Frenzy</span>!<br />
              <span>
                Beware of your Humanity level! The more Humanity you lose, the
                easier it is to fall into a{' '}
                <span className={'color-red'}> Frenzy</span>!
              </span>
              <br />
              <span>
                Avoid using your Feed ability while near others, or else you
                will risk <i>breaking the Masquerade</i>!
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Items">
          <Stack vertical>
            <Stack.Item>
              Rest in a <b>Coffin</b> to claim it, and that area, as your lair.
              <br />
              Examine your new structures to see how they function!
              <br />
              Medical and Genetic Analyzers can sell you out, your Masquerade
              ability will hide your identity to prevent this.
              <br />
            </Stack.Item>
            <Stack.Item>
              <Section textAlign="center" textColor="red" fontSize="20px">
                Other Bloodsuckers are not necessarily your friends, but your
                survival may depend on cooperation. Betray them at your own
                discretion and peril.
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const BloodsuckerClan = (props: any) => {
  const { act, data } = useBackend<BloodsuckerInformation>();
  const { clan } = data;

  if (!clan) {
    return (
      <Section minHeight="220px">
        <Box mt={5} bold textAlign="center" fontSize="40px">
          You are not in a Clan.
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
    <Stack vertical>
      <Stack.Item>
        <Section>
          <Stack vertical>
            <Stack.Item textAlign="center">
              <DmIcon
                icon={clan.icon}
                icon_state={clan.icon_state}
                width="64px"
                height="64px"
                verticalAlign="middle"
              />
              <Box inline fontSize="20px" textAlign="center">
                You are part of the <b>{clan.name}</b>
              </Box>
              <DmIcon
                icon={clan.icon}
                icon_state={clan.icon_state}
                width="64px"
                height="64px"
                verticalAlign="middle"
              />
            </Stack.Item>
            <Stack.Item fontSize="16px">{clan.desc}</Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <PowerSection />
      </Stack.Item>
    </Stack>
  );
};

const PowerSection = (props: any) => {
  const { data } = useBackend<BloodsuckerInformation>();
  const { powers } = data;

  const [powerTab, setPowerTab] = useLocalState('power', powers[0].name);

  const selectedPower =
    powers.find((power) => power.name === powerTab) || powers[0];

  return (
    <Section title="Powers">
      <Flex>
        <Flex.Item>
          <Tabs vertical overflowY="auto">
            {powers.map((power) => (
              <Tabs.Tab
                key={power.name}
                leftSlot={
                  <DmIcon
                    icon={power.icon}
                    icon_state={power.icon_state}
                    verticalAlign="middle"
                  />
                }
                selected={powerTab === power.name}
                onClick={() => setPowerTab(power.name)}
              >
                {power.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
        <Flex.Item ml="1rem" grow={1} basis={0} fontSize="14px">
          <Box
            dangerouslySetInnerHTML={{
              __html: selectedPower.explanation,
            }}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};
