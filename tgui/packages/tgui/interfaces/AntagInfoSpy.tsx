import { useBackend } from '../backend';
import { Box, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Objective, ObjectivePrintout } from './common/Objectives';

type Data = {
  antag_name: string;
  uplink_location: string | null;
  objectives: Objective[];
};

export const AntagInfoSpy = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { antag_name, uplink_location, objectives } = data;
  return (
    <Window width={380} height={420} theme="ntos_darkmode">
      <Window.Content style={{ backgroundImage: 'none' }}>
        <Section title={`You are the ${antag_name || 'Spy'}.`}>
          <Stack vertical fill ml={1} mr={1}>
            <Stack.Item fontSize={1.2}>
              You have been equipped with a special uplink device disguised as{' '}
              {uplink_location || 'something'} that will allow you to steal from
              the station.
            </Stack.Item>
            <Stack.Item>
              <Stack.Item fontFamily="italics" color={'#20b142'}>
                <Box>Use it in hand</Box> to access your uplink, and{' '}
                <Box>right click</Box> on bounty targets to steal them.
              </Stack.Item>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              You may not be alone: There may be other spies on the station.
            </Stack.Item>
            <Stack.Item>
              Work together or work against them: The choice is yours, but{' '}
              <Stack.Item fontFamily="italics" color={'#e03c3c'}>
                you cannot share the rewards.
              </Stack.Item>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <ObjectivePrintout
                titleMessage={'Your mission, should you choose to accept it'}
                objectives={objectives}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
