import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  voting_name: string;
  voting_desc: string;
  votes_yes: number;
  votes_no: number;
  time_left: string;
  locked_for: string;
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
    voting_name,
    voting_desc,
    votes_yes,
    votes_no,
    time_left,
    locked_for,
    possible_demands = [],
    completed_demands = [],
  } = data;
  return (
    <Window theme="neutral" title="Union Demands" width={400} height={500}>
      <Window.Content overflowY="auto">
        {voting_name ? (
          <Section
            fill
            title="Voting"
            buttons={
              <Button
                color="transparent"
                tooltip={'Time left until voting closes.'}
                textAlign="right"
              >
                {time_left}
              </Button>
            }
          >
            <Stack fill vertical>
              <Stack.Item fontSize="150%" textAlign="center">
                {voting_name}
              </Stack.Item>
              <Stack.Item>{voting_desc}</Stack.Item>
              <Button
                fontSize="150%"
                color="good"
                onClick={() => act('vote_yes')}
              >
                Vote Yes ({votes_yes} votes)
              </Button>
              <Button
                fontSize="150%"
                color="bad"
                onClick={() => act('vote_no')}
              >
                Vote No ({votes_no} votes)
              </Button>
            </Stack>
          </Section>
        ) : (
          <>
            {!locked_for ? (
              <Section>Union demands on cooldown for {}</Section>
            ) : (
              <Section
                title="Available Union Demands"
                buttons={
                  <Button
                    icon="question"
                    tooltip={
                      'Select something from the list of available demands, and it will be put to a vote on whether the Union will demand it from the Station. A simple majority must vote yes rather than no in order to go through, abstains are not counted.'
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
                                selected_demand: demand.ref,
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
                          {demand.cost}cr per cycle.
                        </Stack.Item>
                      </Section>
                    ))}
                  </Stack.Item>
                </Stack>
              </Section>
            )}
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
