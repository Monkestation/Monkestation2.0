import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  key: string;
  objectives: Objective[];
};

export const AntagInfoBloodling = (props) => {
  return (
    <Window width={540} height={540}>
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow={4}>
            <AbilitiesSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IntroductionSection = (props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Section
      fill
      title="Intro"
      scrollable={!!objectives && objectives.length > 4}
    >
      <Stack vertical fill>
        <Stack.Item fontSize="25px">You are the Bloodling</Stack.Item>
        &ensp;You are a horrific mass of flesh who has snuck aboard the station
        in your flesh puppet. Now you must burst out of this restricted form,
        harvest biomass and grow until you can swallow the very station.
        <Stack.Item>
          <ObjectivePrintout objectives={objectives} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = (props) => {
  const { data } = useBackend<Info>();
  const { key } = data;
  return (
    <Section fill title="Abilities">
      <Stack fill>
        <Stack.Item basis={0} grow>
          <Stack fill vertical>
            <Stack.Item basis={0} textColor="label" grow>
              You use your own biomass for abilities, and if your biomass is
              ever depleted you will perish. Biomass is your very being and any
              harm will remove it, but as long as any biomass remains you will
              not cease to function.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item basis={0} textColor="label" grow>
              You must grow through your 5 stages of development and reach the
              pinnacle where upon you can ascend. But be ware for you can fall
              backwards in past form shall your biomass lower.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
