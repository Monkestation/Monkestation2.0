import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type SectorMessage = {
  message_code: string;
  installation_code: string;
  installation_name: string;
  installation_status: string;
  installation_trust_label: string;
  sender_name: string;
  sender_role: string;
  message_type: string;
  priority: string;
  title: string;
  body: string;
  issued_at: string;
  resolution_status: string;
  responded_by?: string;
  responded_at?: string;
  response?: string;
  allocation_cost: number;
  allocation_reward: number;
  allocation_change: number;
};

type SectorPaperwork = {
  paperwork_code: string;
  installation_code: string;
  installation_name: string;
  installation_status: string;
  installation_trust_label: string;
  sender_name: string;
  sender_role: string;
  type: string;
  priority: string;
  title: string;
  body: string;
  issued_at: string;
  status: string;
  submitted_by?: string;
  submitted_at?: string;
  allocation_reward: number;
  document_inserted: boolean;
  document_name?: string;
  stamp_verified: boolean;
};

type Data = {
  allocation: number;
  available_allocation: number;
  max_allocation: number;
  inbox: SectorMessage[];
  archive: SectorMessage[];
  archive_count: number;
  pending_count: number;
  paperwork_pending: boolean;
  unresolved_work_count: number;
  paperwork?: SectorPaperwork | null;
};

const statusColor = (status: string) => {
  switch (status) {
    case 'ONLINE':
    case 'ROUTINE OPERATIONS':
      return 'good';
    case 'MAINTENANCE':
    case 'UNDER REVIEW':
      return 'average';
    case 'COMMUNICATIONS DEGRADED':
    case 'NO CONTACT':
    case 'OFFLINE':
    case 'CRITICAL':
      return 'bad';
    default:
      return undefined;
  }
};

const relationshipColor = (relationship: string) => {
  switch (relationship) {
    case 'TRUSTED':
      return 'good';
    case 'COOPERATIVE':
      return 'blue';
    case 'PROFESSIONAL':
      return 'label';
    case 'GUARDED':
      return 'average';
    case 'STRAINED':
      return 'bad';
    default:
      return 'label';
  }
};

const resolutionColor = (status: string) => {
  switch (status) {
    case 'AUTHORIZED':
    case 'ACKNOWLEDGED':
      return 'good';
    case 'DENIED':
    case 'EXPIRED':
      return 'bad';
    default:
      return undefined;
  }
};

export const CCPostSectorComms = (props) => {
  const { data } = useBackend<Data>();
  const [tab, setTab] = useLocalState('tab', 'inbox');
  const {
    allocation = 0,
    available_allocation = 0,
    max_allocation = 0,
    inbox = [],
    archive = [],
    archive_count = 0,
    pending_count = 0,
    paperwork_pending = false,
    unresolved_work_count = 0,
    paperwork = null,
  } = data;

  return (
    <Window width={720} height={760} theme="ntos">
      <Window.Content scrollable>
        <Section title="Operational Allocation">
          <Stack>
            <Stack.Item grow>
              <Box bold fontSize="18px">
                {allocation} / {max_allocation} CU
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Box color="label">Available: {available_allocation} CU</Box>
            </Stack.Item>
          </Stack>
        </Section>

        {unresolved_work_count > 0 ? (
          <NoticeBox>
            UNRESOLVED SECTOR WORK: {pending_count} pending communication
            {pending_count === 1 ? '' : 's'}
            {paperwork_pending ? ' // 1 active administrative document' : ''}
          </NoticeBox>
        ) : (
          <NoticeBox>NO UNRESOLVED SECTOR WORK</NoticeBox>
        )}

        <Tabs>
          <Tabs.Tab
            icon="inbox"
            selected={tab === 'inbox'}
            onClick={() => setTab('inbox')}
          >
            Inbox ({inbox.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="box-archive"
            selected={tab === 'archive'}
            onClick={() => setTab('archive')}
          >
            Archive ({archive_count})
          </Tabs.Tab>
          <Tabs.Tab
            icon="file-signature"
            selected={tab === 'paperwork'}
            onClick={() => setTab('paperwork')}
          >
            Paperwork ({paperwork ? 1 : 0})
          </Tabs.Tab>
        </Tabs>

        {tab === 'inbox' && <Inbox messages={inbox} />}
        {tab === 'archive' && <Archive messages={archive} />}
        {tab === 'paperwork' && <PaperworkPanel paperwork={paperwork} />}
      </Window.Content>
    </Window>
  );
};

const Inbox = ({ messages }: { messages: SectorMessage[] }) => {
  if (!messages.length) {
    return <NoticeBox>No pending sector communications.</NoticeBox>;
  }

  return (
    <>
      {messages.map((message) => (
        <MessageCard key={message.message_code} message={message} archived={false} />
      ))}
    </>
  );
};

const Archive = ({ messages }: { messages: SectorMessage[] }) => {
  const { act } = useBackend<Data>();
  const [installationFilter, setInstallationFilter] = useLocalState(
    'archiveInstallationFilter',
    'ALL',
  );
  const [priorityFilter, setPriorityFilter] = useLocalState(
    'archivePriorityFilter',
    'ALL',
  );
  const [resolutionFilter, setResolutionFilter] = useLocalState(
    'archiveResolutionFilter',
    'ALL',
  );

  const installationCodes: string[] = [];

  messages.forEach((message) => {
    if (!installationCodes.includes(message.installation_code)) {
      installationCodes.push(message.installation_code);
    }
  });

  installationCodes.sort();

  const priorities = ['Routine', 'Advisory', 'Important', 'Priority'];
  const resolutions = ['ACKNOWLEDGED', 'AUTHORIZED', 'DENIED', 'EXPIRED'];

  const filteredMessages = messages.filter((message) => {
    if (
      installationFilter !== 'ALL' &&
      message.installation_code !== installationFilter
    ) {
      return false;
    }

    if (priorityFilter !== 'ALL' && message.priority !== priorityFilter) {
      return false;
    }

    if (
      resolutionFilter !== 'ALL' &&
      message.resolution_status !== resolutionFilter
    ) {
      return false;
    }

    return true;
  });

  const filtersActive =
    installationFilter !== 'ALL' ||
    priorityFilter !== 'ALL' ||
    resolutionFilter !== 'ALL';

  return (
    <>
      <Section title="Archive Filters">
        <Box bold mb={0.5}>
          Installation
        </Box>
        <Box mb={1}>
          <Button
            color={installationFilter === 'ALL' ? 'good' : undefined}
            onClick={() => setInstallationFilter('ALL')}
          >
            All
          </Button>
          {installationCodes.map((code) => (
            <Button
              key={`archive-installation-${code}`}
              color={installationFilter === code ? 'good' : undefined}
              onClick={() => setInstallationFilter(code)}
            >
              {code}
            </Button>
          ))}
        </Box>

        <Box bold mb={0.5}>
          Priority
        </Box>
        <Box mb={1}>
          <Button
            color={priorityFilter === 'ALL' ? 'good' : undefined}
            onClick={() => setPriorityFilter('ALL')}
          >
            All
          </Button>
          {priorities.map((priority) => (
            <Button
              key={`archive-priority-${priority}`}
              color={priorityFilter === priority ? 'good' : undefined}
              onClick={() => setPriorityFilter(priority)}
            >
              {priority}
            </Button>
          ))}
        </Box>

        <Box bold mb={0.5}>
          Resolution
        </Box>
        <Box>
          <Button
            color={resolutionFilter === 'ALL' ? 'good' : undefined}
            onClick={() => setResolutionFilter('ALL')}
          >
            All
          </Button>
          {resolutions.map((resolution) => (
            <Button
              key={`archive-resolution-${resolution}`}
              color={resolutionFilter === resolution ? 'good' : undefined}
              onClick={() => setResolutionFilter(resolution)}
            >
              {resolution}
            </Button>
          ))}
        </Box>
      </Section>

      <Section
        title={`Resolved Communications (${filteredMessages.length}/${messages.length})`}
        buttons={
          <>
            {filtersActive && (
              <Button
                icon="rotate-left"
                onClick={() => {
                  setInstallationFilter('ALL');
                  setPriorityFilter('ALL');
                  setResolutionFilter('ALL');
                }}
              >
                Reset Filters
              </Button>
            )}
            <Button
              icon="print"
              disabled={!messages.length}
              tooltip="Prints the complete archive, regardless of active screen filters."
              onClick={() => act('print_archive')}
            >
              Print Full Archive
            </Button>
            <Button.Confirm
              icon="trash"
              color="danger"
              disabled={!messages.length}
              confirmContent="Clear complete archive?"
              onClick={() => act('clear_archive')}
            >
              Clear Full Archive
            </Button.Confirm>
          </>
        }
      >
        {!messages.length ? (
          <NoticeBox>No resolved communications are currently archived.</NoticeBox>
        ) : !filteredMessages.length ? (
          <NoticeBox>No archived communications match the active filters.</NoticeBox>
        ) : (
          filteredMessages.map((message) => (
            <MessageCard key={message.message_code} message={message} archived />
          ))
        )}
      </Section>
    </>
  );
};

const PaperworkPanel = ({
  paperwork,
}: {
  paperwork?: SectorPaperwork | null;
}) => {
  const { act } = useBackend<Data>();

  if (!paperwork) {
    return (
      <NoticeBox>
        No administrative paperwork is currently awaiting Liaison review.
      </NoticeBox>
    );
  }

  const awaitingReview = paperwork.status === 'AWAITING LIAISON REVIEW';
  const awaitingReceipt =
    paperwork.status === 'TRANSMITTED - AWAITING RECEIPT';

  return (
    <Section
      title={`${paperwork.title} — ${paperwork.paperwork_code}`}
      buttons={
        awaitingReview ? (
          <>
            <Button
              icon="print"
              disabled={paperwork.document_inserted}
              tooltip={
                paperwork.document_inserted
                  ? 'Eject the inserted document before printing another copy.'
                  : 'Print another authenticated copy of the active document.'
              }
              onClick={() => act('reprint_paperwork')}
            >
              Reprint
            </Button>
            <Button
              icon="eject"
              disabled={!paperwork.document_inserted}
              onClick={() => act('eject_paperwork')}
            >
              Eject
            </Button>
            <Button
              icon="paper-plane"
              color="good"
              disabled={
                !paperwork.document_inserted || !paperwork.stamp_verified
              }
              tooltip={
                !paperwork.document_inserted
                  ? 'Insert the active administrative document first.'
                  : !paperwork.stamp_verified
                    ? 'An official Central Command stamp is required.'
                    : undefined
              }
              onClick={() => act('transmit_paperwork')}
            >
              Transmit
            </Button>
          </>
        ) : null
      }
    >
      <LabeledList>
        <LabeledList.Item label="Installation">
          {paperwork.installation_name} ({paperwork.installation_code})
        </LabeledList.Item>
        <LabeledList.Item label="Current Status">
          <Box color={statusColor(paperwork.installation_status)}>
            {paperwork.installation_status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Relationship Assessment">
          <Box
            color={relationshipColor(paperwork.installation_trust_label)}
            bold
          >
            {paperwork.installation_trust_label}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Sender">
          {paperwork.sender_role} {paperwork.sender_name}
        </LabeledList.Item>
        <LabeledList.Item label="Type">{paperwork.type}</LabeledList.Item>
        <LabeledList.Item label="Priority">
          {paperwork.priority}
        </LabeledList.Item>
        <LabeledList.Item label="Reference">
          {paperwork.paperwork_code}
        </LabeledList.Item>
        <LabeledList.Item label="Issued">
          {paperwork.issued_at}
        </LabeledList.Item>
        <LabeledList.Item label="Processing Status">
          <Box color={awaitingReceipt ? 'average' : undefined}>
            {paperwork.status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Completion Compensation">
          <Box color="good">+{paperwork.allocation_reward} CU</Box>
        </LabeledList.Item>
        {awaitingReview && (
          <>
            <LabeledList.Item label="Document Slot">
              {paperwork.document_inserted
                ? paperwork.document_name || 'Document inserted'
                : 'EMPTY'}
            </LabeledList.Item>
            <LabeledList.Item label="Stamp Verification">
              <Box color={paperwork.stamp_verified ? 'good' : 'average'}>
                {paperwork.stamp_verified
                  ? 'CENTCOM AUTHORIZED'
                  : 'CENTCOM STAMP REQUIRED'}
              </Box>
            </LabeledList.Item>
          </>
        )}
        {paperwork.submitted_by && (
          <LabeledList.Item label="Submitted By">
            {paperwork.submitted_by}
          </LabeledList.Item>
        )}
        {paperwork.submitted_at && (
          <LabeledList.Item label="Submitted At">
            {paperwork.submitted_at}
          </LabeledList.Item>
        )}
      </LabeledList>

      <Box mt={1.5}>{paperwork.body}</Box>

      {awaitingReview && (
        <Box mt={1.5} p={1} backgroundColor="rgba(255, 255, 255, 0.04)">
          <Box bold mb={0.5}>
            Required Action
          </Box>
          Review the printed document, apply an official Central Command
          authorization stamp, insert it into the Sector Communications
          Terminal, and transmit it back to the originating installation.
        </Box>
      )}

      {awaitingReceipt && (
        <NoticeBox mt={1.5}>
          Document transmitted. Awaiting authenticated receipt confirmation from{' '}
          {paperwork.installation_name}.
        </NoticeBox>
      )}
    </Section>
  );
};

const MessageCard = ({
  message,
  archived,
}: {
  message: SectorMessage;
  archived: boolean;
}) => {
  const { act, data } = useBackend<Data>();
  const { available_allocation = 0 } = data;

  const isRequest = message.message_type === 'REQUEST';
  const insufficientAllocation =
    isRequest && message.allocation_cost > available_allocation;

  return (
    <Section
      title={`${message.title} — ${message.message_code}`}
      buttons={
        archived ? (
          <Button
            icon="print"
            onClick={() =>
              act('print_message', { message_code: message.message_code })
            }
          >
            Print
          </Button>
        ) : isRequest ? (
          <>
            <Button
              icon="check"
              color="good"
              disabled={insufficientAllocation}
              tooltip={
                insufficientAllocation
                  ? `Requires ${message.allocation_cost} CU; only ${available_allocation} CU is available.`
                  : undefined
              }
              onClick={() =>
                act('authorize', { message_code: message.message_code })
              }
            >
              Authorize
            </Button>
            <Button
              icon="xmark"
              color="danger"
              onClick={() => act('deny', { message_code: message.message_code })}
            >
              Deny
            </Button>
          </>
        ) : (
          <Button
            icon="check"
            onClick={() =>
              act('acknowledge', { message_code: message.message_code })
            }
          >
            Acknowledge
          </Button>
        )
      }
    >
      <LabeledList>
        <LabeledList.Item label="Installation">
          {message.installation_name} ({message.installation_code})
        </LabeledList.Item>
        <LabeledList.Item label="Current Status">
          <Box color={statusColor(message.installation_status)}>
            {message.installation_status}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Relationship Assessment">
          <Box color={relationshipColor(message.installation_trust_label)} bold>
            {message.installation_trust_label}
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Sender">
          {message.sender_role} {message.sender_name}
        </LabeledList.Item>
        <LabeledList.Item label="Type">{message.message_type}</LabeledList.Item>
        <LabeledList.Item label="Priority">{message.priority}</LabeledList.Item>
        <LabeledList.Item label="Issued">{message.issued_at}</LabeledList.Item>

        {!!message.allocation_cost && (
          <LabeledList.Item label="Requested Allocation">
            <Box color="average">{message.allocation_cost} CU</Box>
          </LabeledList.Item>
        )}

        {!!message.allocation_reward && (
          <LabeledList.Item label="Offered Transfer">
            <Box color="good">+{message.allocation_reward} CU</Box>
          </LabeledList.Item>
        )}

        {archived && (
          <>
            <LabeledList.Item label="Resolution">
              <Box color={resolutionColor(message.resolution_status)}>
                {message.resolution_status}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Responded By">
              {message.responded_by || 'N/A'}
            </LabeledList.Item>
            <LabeledList.Item label="Responded At">
              {message.responded_at || 'N/A'}
            </LabeledList.Item>
            {!!message.allocation_change && (
              <LabeledList.Item label="Liaison CU Change">
                <Box color={message.allocation_change > 0 ? 'good' : 'bad'}>
                  {message.allocation_change > 0 ? '+' : ''}
                  {message.allocation_change} CU
                </Box>
              </LabeledList.Item>
            )}
          </>
        )}
      </LabeledList>

      <Box mt={1.5}>{message.body}</Box>

      {archived && message.response && (
        <Box mt={1.5} p={1} backgroundColor="rgba(255, 255, 255, 0.04)">
          <Box bold mb={0.5}>
            Recorded Response
          </Box>
          {message.response}
        </Box>
      )}
    </Section>
  );
};
