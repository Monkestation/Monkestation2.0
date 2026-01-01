import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';

type TokenRequest = {
  id: string;
  requester_ckey: string;
  requester_ref: string;
  type: string;
  details: string;
  tier: string;
  is_donor: boolean;
  time_submitted: number;
  time_remaining: number;
  time_remaining_text: string;
};

type RoundStats = {
  round_time: string;
  round_time_raw: number;
  storyteller_name: string;
  active_players: number;
  head_crew: number;
  sec_crew: number;
  eng_crew: number;
  med_crew: number;
  antag_count: number;
  antag_cap: number;
};

type TokenManagerData = {
  pending_requests: TokenRequest[];
  accepted_count: number;
  rejected_count: number;
  timed_out_count: number;
  total_processed: number;
  round_stats: RoundStats;
};

const getTierColor = (tier: string): string => {
  switch (tier) {
    case 'high':
      return 'red';
    case 'medium':
      return 'orange';
    case 'low':
      return 'green';
    default:
      return 'gray';
  }
};

const getTierLabel = (tier: string): string => {
  switch (tier) {
    case 'high':
      return 'High Threat';
    case 'medium':
      return 'Medium Threat';
    case 'low':
      return 'Low Threat';
    default:
      return tier;
  }
};

export const TokenManager = (props) => {
  const { act, data } = useBackend<TokenManagerData>();
  const {
    pending_requests = [],
    accepted_count = 0,
    rejected_count = 0,
    timed_out_count = 0,
    total_processed = 0,
    round_stats,
  } = data;

  return (
    <Window title="Token Manager" width={700} height={550}>
      <Window.Content scrollable>
        <Stack vertical fill>
          {/* Round Statistics Section */}
          <Stack.Item>
            <RoundStatisticsPanel roundStats={round_stats} />
          </Stack.Item>

          {/* Token Statistics Section */}
          <Stack.Item>
            <Section title="Token Statistics">
              <Stack>
                <Stack.Item grow>
                  <LabeledList>
                    <LabeledList.Item label="Accepted" color="green">
                      {accepted_count}
                    </LabeledList.Item>
                    <LabeledList.Item label="Rejected" color="red">
                      {rejected_count}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item grow>
                  <LabeledList>
                    <LabeledList.Item label="Timed Out" color="orange">
                      {timed_out_count}
                    </LabeledList.Item>
                    <LabeledList.Item label="Total Processed">
                      {total_processed}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="sync"
                    tooltip="Refresh data"
                    onClick={() => act('refresh')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          {/* Pending Requests Section */}
          <Stack.Item grow>
            <Section
              title={`Pending Requests (${pending_requests.length})`}
              fill
              scrollable
            >
              {pending_requests.length === 0 ? (
                <NoticeBox info>No pending token requests.</NoticeBox>
              ) : (
                <Table>
                  <Table.Row header>
                    <Table.Cell>Player</Table.Cell>
                    <Table.Cell>Request</Table.Cell>
                    <Table.Cell>Tier</Table.Cell>
                    <Table.Cell>Time Left</Table.Cell>
                    <Table.Cell>Actions</Table.Cell>
                  </Table.Row>
                  {pending_requests.map((request) => (
                    <TokenRequestRow key={request.id} request={request} />
                  ))}
                </Table>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RoundStatisticsPanel = (props: { roundStats: RoundStats }) => {
  const { roundStats } = props;

  if (!roundStats) {
    return (
      <Section title="Round Statistics">
        <NoticeBox>Loading round statistics...</NoticeBox>
      </Section>
    );
  }

  const {
    round_time,
    storyteller_name,
    active_players,
    head_crew,
    sec_crew,
    eng_crew,
    med_crew,
    antag_count,
    antag_cap,
  } = roundStats;

  // Calculate antag capacity percentage
  const antagCapPercent = antag_cap > 0 ? (antag_count / antag_cap) * 100 : 0;

  return (
    <Section title="Round Statistics">
      <Stack>
        {/* Left Column - Time & Storyteller */}
        <Stack.Item grow basis={0}>
          <LabeledList>
            <LabeledList.Item label="Round Time">
              <Icon name="clock" mr={1} />
              {round_time}
            </LabeledList.Item>
            <LabeledList.Item label="Storyteller">
              <Icon name="book-dead" mr={1} />
              {storyteller_name}
            </LabeledList.Item>
            <LabeledList.Item label="Active Players">
              <Icon name="users" mr={1} />
              {active_players}
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>

        {/* Middle Column - Antag Points */}
        <Stack.Item grow basis={0}>
          <LabeledList>
            <LabeledList.Item label="Antag Points">
              <ProgressBar
                value={antagCapPercent}
                maxValue={100}
                ranges={{
                  good: [0, 50],
                  average: [50, 80],
                  bad: [80, 100],
                }}
              >
                {antag_count} / {antag_cap}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>

        {/* Right Column - Department Counts */}
        <Stack.Item grow basis={0}>
          <CrewCounts
            head={head_crew}
            sec={sec_crew}
            eng={eng_crew}
            med={med_crew}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const CrewCounts = (props: {
  head: number;
  sec: number;
  eng: number;
  med: number;
}) => {
  const { head, sec, eng, med } = props;

  const departments = [
    { name: 'Head', count: head, icon: 'star', color: 'blue' },
    { name: 'Sec', count: sec, icon: 'shield-alt', color: 'red' },
    { name: 'Eng', count: eng, icon: 'wrench', color: 'yellow' },
    { name: 'Med', count: med, icon: 'medkit', color: 'teal' },
  ];

  return (
    <Box>
      <Box bold mb={1}>
        <Icon name="id-card" mr={1} />
        Crew Counts
      </Box>
      <Stack wrap>
        {departments.map((dept) => (
          <Stack.Item key={dept.name} basis="50%" mb={0.5}>
            <Box inline color={dept.color}>
              <Icon name={dept.icon} mr={1} />
              {dept.name}:
            </Box>{' '}
            <Box inline bold>
              {dept.count}
            </Box>
          </Stack.Item>
        ))}
      </Stack>
    </Box>
  );
};

const TokenRequestRow = (props: { request: TokenRequest }) => {
  const { act } = useBackend<TokenManagerData>();
  const { request } = props;

  // Less than 1 minute (600 deciseconds)
  const isUrgent = request.time_remaining < 600;
  const tierColor = getTierColor(request.tier);

  return (
    <Table.Row className={isUrgent ? 'Table__row--urgent' : ''}>
      <Table.Cell>
        <Button
          icon="user"
          tooltip="View player panel"
          onClick={() => act('view_player', { id: request.id })}
        >
          {request.requester_ckey}
        </Button>
        {!!request.is_donor && (
          <Icon name="star" color="gold" ml={1} title="Donor Token" />
        )}
      </Table.Cell>
      <Table.Cell>
        <Box bold>{request.details}</Box>
      </Table.Cell>
      <Table.Cell>
        <Box color={tierColor} bold>
          {getTierLabel(request.tier)}
        </Box>
      </Table.Cell>
      <Table.Cell>
        <Box color={isUrgent ? 'red' : 'white'} bold={isUrgent}>
          {isUrgent && <Icon name="exclamation-triangle" mr={1} />}
          {request.time_remaining_text}
        </Box>
      </Table.Cell>
      <Table.Cell>
        <Stack>
          <Stack.Item>
            <Button
              icon="check"
              color="green"
              tooltip="Approve this request"
              onClick={() => act('approve', { id: request.id })}
            >
              Approve
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="times"
              color="red"
              tooltip="Reject this request"
              onClick={() => act('reject', { id: request.id })}
            >
              Reject
            </Button>
          </Stack.Item>
        </Stack>
      </Table.Cell>
    </Table.Row>
  );
};
