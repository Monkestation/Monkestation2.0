import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  voting: string;
  votes_yes: number;
  votes_no: number;
  time_left: string;
  possible_demands: DemandsData[];
  completed_demands: DemandsData[];
};

type DemandsData = {
  name: string;
  desc: string;
  cost: number;
  ref: string;
};

export const UnionStand = () => {
  const { act, data } = useBackend<Data>();
  const {
    voting,
    votes_yes,
    votes_no,
    time_left,
    possible_demands = [],
    completed_demands = [],
  } = data;
  return (
    <Window theme="neutral" title="Union Demands" width={400} height={500}>
      <Window.Content>
        {voting ? (
          <Section fill title="Voting">
            <Stack fill>
              <Stack.Item>voting on {voting}</Stack.Item>
            </Stack>
          </Section>
        ) : (
          <>
            <Section
              title="Available Union Demands"
              buttons={
                <Button
                  icon="question"
                  tooltip={
                    'Select something from the list of available demands, and it will be put to a vote on whether the Union will demand it from the Station.'
                  }
                />
              }
            >
              <Stack>
                <Stack.Item>
                  {possible_demands.map((demand) => (
                    <Section
                      title={demand.name}
                      key={demand.ref}
                      buttons={
                        <Button.Confirm
                          onClick={() =>
                            act('trigger_vote', {
                              ref: demand.ref,
                            })
                          }
                        >
                          Demand
                        </Button.Confirm>
                      }
                    >
                      <Stack.Item>{demand.desc}</Stack.Item>
                      <Stack.Item fontSize="110%" ml={-0.5}>
                        <Button
                          compact
                          color="transparent"
                          tooltip={
                            'This will be charged every pay cycle to the Union and Command budgets.'
                          }
                          style={{ textDecoration: 'underline' }}
                        >
                          Cost:
                        </Button>
                        {demand.cost}cr per pay cycle.
                      </Stack.Item>
                    </Section>
                  ))}
                </Stack.Item>
              </Stack>
            </Section>
            <Section title="Completed Demands">
              <Stack>
                {completed_demands.length ? (
                  <Stack.Item>
                    {completed_demands.map((demand) => (
                      <Section title={demand.name} key={demand.ref}>
                        <Stack.Item>{demand.desc}</Stack.Item>
                      </Section>
                    ))}
                  </Stack.Item>
                ) : (
                  <Box>
                    No completed demands, select one from the list above!
                  </Box>
                )}
              </Stack>
            </Section>
          </>
        )}
      </Window.Content>
    </Window>
  );
};
