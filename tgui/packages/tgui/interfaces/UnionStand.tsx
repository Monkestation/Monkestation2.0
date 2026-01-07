import type { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Dimmer, Button, Divider, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  union_active: BooleanLike;
  deadlocked: BooleanLike;
  admin_mode: BooleanLike;
  voting_name: string;
  voting_desc: string;
  votes_yes: number;
  votes_no: number;
  voting_time_left: string;
  voting: BooleanLike;
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

const ImplementationFreeze = () => {
  const { act, data } = useBackend<Data>();
  const { admin_mode, deadlocked } = data;
  return (
    !!admin_mode && (
      <Button.Confirm
        tooltip={
          deadlocked
            ? 'Unfreezes'
            : 'Freezes' +
              ' implementation timer of the current demand. Command can also do this action through the Communications console.'
        }
        onClick={() => act('freeze_timers')}
      >
        {deadlocked ? 'Unfreeze' : 'Freeze'} implementation
      </Button.Confirm>
    )
  );
};

const DeadlockNotice = () => {
  const { act, data } = useBackend<Data>();
  const { voting_name, deadlocked } = data;
  return (
    !!deadlocked && (
      <Section title="Deadlocked" textColor="yellow">
        <Box my={0.5}>
          {voting_name} is currently under Deadlock. No more Union activity may
          proceed until this has been dealt with.
        </Box>
        <Button.Confirm onClick={() => act('abandon_demand')}>
          Abandon Demand
        </Button.Confirm>
      </Section>
    )
  );
};

export const UnionStand = () => {
  const { act, data } = useBackend<Data>();
  const {
    union_active,
    admin_mode,
    deadlocked,
    voting_name,
    voting_desc,
    votes_yes,
    votes_no,
    voting_time_left,
    voting,
    locked_for,
    possible_demands = [],
    completed_demands = [],
  } = data;
  if (!union_active && !admin_mode) {
    return (
      <Window theme="UnionStand" title="Union Demands" width={350} height={170}>
        <Window.Content overflowY="auto">
          <Section>
            <Stack vertical fill>
              <Stack.Item textAlign="center" textColor="yellow">
                <Box fontSize="250%">Cargo Workers Union</Box>
              </Stack.Item>
              <Divider />
              <Stack.Item>
                <Box>
                  Thank you for your interest in the Cargo Workers Union (CWU).
                  We deeply appreciate your membership fees. More information is
                  soon to come.
                </Box>
              </Stack.Item>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window theme="UnionStand" title="Union Demands" width={400} height={500}>
      <Window.Content overflowY={locked_for !== null ? 'hidden' : 'auto'}>
        {!!admin_mode && (
          <Section title="Admin tools">
            <Box my={0.5}>
              There are admin tools all over the page (usually indicated by
              tooltips), these are just general buttons.
            </Box>
            <Button.Confirm
              color={union_active ? 'bad' : 'good'}
              onClick={() => act('toggle_union')}
            >
              {union_active ? 'Disable Union' : 'Enable Union'}
            </Button.Confirm>
            <ImplementationFreeze />
          </Section>
        )}
        <DeadlockNotice />
        {!locked_for && voting ? (
          <Section
            fill
            title="Voting"
            buttons={
              <Button
                color="transparent"
                tooltip={'Time left until voting closes.'}
                textAlign="right"
              >
                {voting_time_left}
              </Button>
            }
          >
            <Stack fill vertical>
              {!!admin_mode && (
                <Button
                  tooltip={
                    'Automatically ends the voting period and will instate if enough voted yes.'
                  }
                  onClick={() => act('end_vote')}
                >
                  End Voting (Auto-results)
                </Button>
              )}
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
            {locked_for !== null && (
              <Dimmer
                style={{
                  backgroundImage: 'warning',
                }}
              >
                <Section
                  position="relative"
                  backgroundColor="red"
                  title="Demands on Hold"
                  buttons={
                    !!admin_mode && (
                      <>
                        <Button.Confirm
                          tooltip={'This is available to you as an Admin.'}
                          onClick={() => act('reset_cooldown')}
                        >
                          Reset Cooldown
                        </Button.Confirm>
                        <ImplementationFreeze />
                      </>
                    )
                  }
                >
                  <Stack vertical>
                    <Stack.Item>
                      Union demands on cooldown for {locked_for}.
                    </Stack.Item>
                    {voting_name && (
                      <>
                        <Divider />
                        {deadlocked ? (
                          <DeadlockNotice />
                        ) : (
                          <Stack.Item>
                            {voting_name} going into effect...
                          </Stack.Item>
                        )}
                      </>
                    )}
                  </Stack>
                </Section>
              </Dimmer>
            )}
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
            <Section title="Completed Demands">
              <Stack vertical>
                {completed_demands.length ? (
                  <Stack.Item>
                    {completed_demands.map((demand) => (
                      <Section
                        title={demand.name}
                        key={demand.ref}
                        buttons={
                          !!admin_mode && (
                            <Button.Confirm
                              tooltip={
                                'Immediately reverts this demand. This is only available to you as an Admin.'
                              }
                              onClick={() =>
                                act('remove_demand', {
                                  selected_demand: demand.ref,
                                })
                              }
                            >
                              Remove Demand
                            </Button.Confirm>
                          )
                        }
                      >
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
