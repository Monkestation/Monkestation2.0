import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  antag_name: string;
  objectives: Objective[];
  brothers: string;
};

export const AntagInfoBrother = (props) => {
  const { data } = useBackend<Info>();
  const { antag_name, brothers, objectives } = data;
  return (
    <Window width={620} height={300}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are the {antag_name}!
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout objectives={objectives} />
            </Stack.Item>
            <Stack.Item>
              Your bond between you and your brother is nigh unbreakable. Not
              even death will do you part. Alt click a cloning console to hack
              it and clone your blood brother stealthily, leaving no records
              behind. This form of revival can bring back things like IPCs and
              bloodsuckers, if they have been converted to your team.
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
