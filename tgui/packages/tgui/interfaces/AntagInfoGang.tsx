// THIS IS A MONKESTATION UI FILE

import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
};

type Info = {
  gang_name: string;
  objectives: Objective[];
};

const ObjectivePrintout = (props: any, context: any) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your current objectives:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoGang = (props: any, context: any) => {
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  return (
    <Window width={620} height={580} theme="syndicate">
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Introduction
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Lieutenants
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 3}
            onClick={() => setTab(3)}>
            Gang Bosses
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 4}
            onClick={() => setTab(4)}>
            Other info
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <MainPage />}
        {tab === 2 && <Lieutenants />}
        {tab === 3 && <GangBosses />}
        {tab === 4 && <OtherInfo />}
      </Window.Content>
    </Window>
  );
};

const MainPage = (props: any, context: any) => {
  const { data } = useBackend<Info>(context);
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="14rem">
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are a member of the {data.gang_name} Gang.
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item minHeight="35rem">
        <Section fill title="Essentials">
          <Stack vertical>
            <Stack.Item>
              <span className={'color-red'}>
                The basics of being a gangmember
              </span>
              <br />
              <span>
                Your gang has been hired by a Syndicate corporation to carry out
                their dirty work on the station for a bet they made. Whichever
                gang does the best will by taken on by The Syndicate as full
                time hires. The others will be disposed of by their employers
                due to making them lose their bet.
              </span>
              <br />
              <br />
              <span>
                Your main job as a gang member is to increase the threat level
                of your gang and follow the orders of your superiors. The main
                way to increase threat level is to claim areas by spraying them
                with the specially designed spraycans given to gangs. Claimed
                areas will also generate telecrystals that can be distributed by
                the gang boss and lieutenants.
              </span>
              <br />
              <br />
              <span>
                You can induct additional people into your gang via gang uplink
                implants which can be used to purchase additional gear with
                telecrystals, a list of notable items available to purchase can
                be found in the &quot;Other info&quot; section. Additional
                implants can be created in the gang fabrcator. Be warned that if
                your implant is ever removed you will lose your gang
                afilliation. People with mindshields are also immune to
                induction.
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const Lieutenants = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="42rem">
        <Section fill title="How to be a gang lieutenant">
          <Stack vertical>
            <Stack.Item>
              <span>
                As a gang lieutenant you act as second in command to your boss,
                you and your boss are also immune to deconversion. You also get
                a built in communicator that can be used to wirelessly
                communicate with anyone else on your gang with a communicator,
                additional communicators can be bought in your uplink for 4 TC
                each. You and your boss are also the only ones able to promote
                additional lieutenants or a new boss if the old one is
                incapacitated.
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const GangBosses = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="42rem">
        <Section fill title="How to lead your gang">
          <Stack vertical>
            <Stack.Item>
              <span>
                As a boss you act as the commander and chief of your gang,
                everyone within your gang must listen and obey you, you are also
                the only one able to allocate telecrystals gained from
                controlled areas.
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const OtherInfo = () => {
  return (
    <Stack vertical fill>
      <Stack.Item minHeight="45rem">
        <Section fill title="Other useful things to know">
          <Stack vertical>
            <Stack.Item>
              <span>
                The credit converter will slowly turn inserted credits into
                additional threat level.
              </span>
              <br />
              <br />
              <span>
                Gang turrets can be purchased and can be toggled between a
                lethal and non lethal mode.
              </span>
              <br />
              <br />
              <span>
                Resistant spraycans will give you 5 sprays worth of a resistant
                coating that when used can only be removed by other resistant
                sprays, dont think about it.
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
