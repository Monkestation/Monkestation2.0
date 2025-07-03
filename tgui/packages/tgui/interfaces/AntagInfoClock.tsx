import { useBackend } from '../backend';
import { Icon, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  antag_name: string;
  objectives: Objective[];
};

export const AntagInfoClock = (props) => {
  const {
    data: { antag_name, objectives },
  } = useBackend<Info>();
  return (
    <Window width={620} height={250} theme="clockwork">
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item fontSize="20px" color={'good'}>
              <Icon name={'cog'} rotation={0} spin />
              {' You are the ' + antag_name + '! '}
              <Icon name={'cog'} rotation={35} spin />
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout
                titleMessage={'To serve Rat&#39;var you must:'}
                objectives={objectives}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
