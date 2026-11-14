import { CCPostHeader, CCPostPersonnelPortrait, CCPostServerUnavailable } from './CCPostTheme';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Layout, Window } from '../layouts';

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
  assigned_to?: string;
  review_started?: boolean;
  review_verified?: boolean;
  review_verification_summary?: string;
  review_clarification_pending?: boolean;
  review_clarification_received?: boolean;
  review_clarification_reply?: string;
  review_expeditable?: boolean;
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
  assigned_to?: string;
  submitted_by?: string;
  submitted_at?: string;
  allocation_reward: number;
  document_inserted: boolean;
  document_name?: string;
  stamp_verified: boolean;
};

type Data = {
  pda_notifications?: boolean | number;
  read_only?: boolean;
  authenticated?: boolean;
  admin_server_online?: boolean | number;
  admin_server_status?: string;
  identity_portrait?: string | null;
  identity_detected?: boolean;
  session_owner?: string;
  network_queue?: SectorMessage[];
  network_pending_count?: number;
  allocation: number;
  available_allocation: number;
  max_allocation: number;
  inbox: SectorMessage[];
  archive: SectorMessage[];
  archive_count: number;
  pending_count: number;
  paperwork_pending: boolean;
  paperwork?: SectorPaperwork | null;
  broadcast_cost: number;
  broadcast_cooldown_seconds: number;
  workload_overview?: { name: string; load: number }[];
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

export const CCPostSectorComms = () => {
  const { data, act } = useBackend<Data>();
  const [tab, setTab] = useLocalState('tab', 'inbox');
  const [helpOpen, setHelpOpen] = useLocalState('ccpostCommsHelp', false);
  const {
    read_only = false,
    authenticated = false,
    admin_server_online = false,
    admin_server_status = 'SERVER MISSING',
    identity_portrait = null,
    identity_detected = false,
    session_owner = '',
    network_queue = [],
    allocation = 0,
    available_allocation = 0,
    max_allocation = 0,
    inbox = [],
    archive = [],
    archive_count = 0,
    paperwork = null,
    broadcast_cost = 25,
    broadcast_cooldown_seconds = 0,
    workload_overview = [],
  } = data;

  if (!authenticated) {
    return (
      <Window title="Central Command Sector Communications | Sign In" width={570} height={480} theme="ntos">
        <Window.Content className="ccpost-theme ccpost-theme--comms ccpost-admin-v2">
          <CCPostHeader title="Sector Communications" division="CENTRAL COMMAND" />
          <Layout.Content scrollable className="CCPostAdminBody">
          {!admin_server_online && <CCPostServerUnavailable status={admin_server_status} />}
          <div className="CCPostIdentityStrip"><CCPostPersonnelPortrait portrait={identity_portrait} label="OFFICIAL ID RECORD" /><div><strong>{identity_detected ? 'Registered Liaison Identified' : 'Identification Required'}</strong><div>Encrypted correspondence access is linked to the registered employee.</div></div></div>
          <div className="CCPostLogin">
          <Stack vertical fill>
            <Stack.Item>
              <Section title="Personnel Authentication">
                <LabeledList>
                  <LabeledList.Item label="Personnel record">{identity_detected ? 'HR roster record detected' : 'Not detected'}</LabeledList.Item>
                  <LabeledList.Item label="Current workstation">{session_owner || 'Not signed in'}</LabeledList.Item>
                </LabeledList>
                {!identity_detected && <NoticeBox>No authorized Central Command Liaison ID detected. Hold or equip your registered ID to authenticate.</NoticeBox>}
                <Button icon="sign-in-alt" color="good" fluid mt={1.5} disabled={!identity_detected || read_only || !admin_server_online} onClick={() => act('login')}>Sign In</Button>
              </Section>
            </Stack.Item>
          </Stack>
          </div>
        
          </Layout.Content>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={720} height={760} theme="ntos">
      <Window.Content className="ccpost-theme ccpost-theme--comms ccpost-admin-v2">
          <CCPostHeader title="Sector Communications" division="CENTRAL COMMAND" />
          <div className="CCPostAdminNav"><Tabs>
          <Tabs.Tab
            icon="inbox"
            selected={tab === 'inbox'}
            onClick={() => setTab('inbox')}
          >
            My Inbox ({inbox.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="box-archive"
            selected={tab === 'archive'}
            onClick={() => setTab('archive')}
          >
            Archive ({archive_count})
          </Tabs.Tab>
          <Tabs.Tab icon="sitemap" selected={tab === 'network'} onClick={() => setTab('network')}>
            Network Queue ({network_queue.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="file-signature"
            selected={tab === 'paperwork'}
            onClick={() => setTab('paperwork')}
          >
            Paperwork ({paperwork ? 1 : 0})
          </Tabs.Tab>
        </Tabs></div>
          <Layout.Content scrollable className="CCPostAdminBody">
          {!admin_server_online && <CCPostServerUnavailable status={admin_server_status} />}
        {Boolean(read_only) && (<NoticeBox>OBSERVER MODE: Read-only. All terminal actions are restricted to authorized Central Command personnel.</NoticeBox>)}
        <Section
          title="Correspondence Workspace"
          buttons={
            <>
              <Button icon="question-circle" onClick={() => setHelpOpen(!helpOpen)}>
                {helpOpen ? 'Close Manual' : 'Operating Manual'}
              </Button>
              {!read_only && <Button icon="bell" selected={Boolean(data.pda_notifications)} onClick={() => act('toggle_pda_notifications')}>PDA Alerts: {data.pda_notifications ? 'ON' : 'OFF'}</Button>}
                {!read_only && <Button icon="sign-out-alt" color="average" onClick={() => act('logout')}>Sign Out</Button>}
            </>
          }
        >
          <Box color="label" mb={1}>Signed in as {session_owner}. Personal correspondence follows your authenticated personnel record.</Box>
          <Box>
            Installation conditions, incidents, telemetry, and administrative
            records can be reviewed on the Remote Oversight Network displays
            throughout the outpost. Consult these before approving assistance.
          </Box>
          {helpOpen && (
            <Box mt={1}>
              <Box bold>SECTOR CORRESPONDENCE OPERATING MANUAL</Box>
              <Box mt={1}>
                This encrypted exchange carries official requests and status
                correspondence from registered NanoTrasen sector facilities.
                Review each incoming message and the associated Remote Oversight
                records before issuing an authorization or denial. Such
                decisions may affect local continuity and future cooperation. Use existing records first, avoid duplicate inquiries, and keep nonessential requests away from personnel responding to emergencies.
              </Box>
              <Box mt={1}>
                The Archive retains processed transmissions and issued responses.
                Where an authenticated document is requested, print the supplied
                paperwork, apply the physical Central Command stamp, return it
                to this terminal, and transmit the completed record. Allocation
                credit is released only after confirmed receipt.
              </Box>
              <Box mt={1}>
                Station-wide priority announcements are controlled broadcasts
                subject to Operational Allocation charges and transmission
                cooldowns. The Logistics Terminal manages allocation; the
                Tasking Terminal records official assignments.
              </Box>
              <Box mt={1} color="label">
                CORRESPONDENCE IS RESTRICTED TO AUTHORIZED PERSONNEL. Do not
                disclose sector traffic or authentication material externally.
              </Box>
            </Box>
          )}
        </Section>
        <div className="CCPostMetricRow">
          <div className="CCPostMetric"><div className="CCPostMetric__value">{inbox.length}</div><div className="CCPostMetric__label">MY CORRESPONDENCE</div></div>
          <div className="CCPostMetric"><div className="CCPostMetric__value">{paperwork ? 1 : 0}</div><div className="CCPostMetric__label">MY DOCUMENTS</div></div>
          <div className="CCPostMetric"><div className="CCPostMetric__value">{network_queue.length}</div><div className="CCPostMetric__label">UNCLAIMED</div></div>
        </div>
        <details className="CCPostUtilityDisclosure"><summary>Station-wide announcements &amp; allocation</summary>
        <Section
          title="Station-Wide Announcements"
          buttons={
            <Button.Confirm
              icon="bullhorn"
              color="average"
              disabled={available_allocation < broadcast_cost || broadcast_cooldown_seconds > 0}
              confirmContent={`Spend ${broadcast_cost} CU on a station-wide announcement?`}
              onClick={() => act('broadcast_announcement')}
            >
              Compose Announcement
            </Button.Confirm>
          }
        >
          <Box>
            Authorized Liaisons can broadcast an outpost-attributed priority
            announcement to the station for {broadcast_cost} CU, with a shared
            five-minute cooldown and a 250-character message limit.
          </Box>
          {broadcast_cooldown_seconds > 0 && (
            <Box color="average" mt={1}>
              Broadcast cooling down ({broadcast_cooldown_seconds}s at last refresh).
            </Box>
          )}
        </Section>
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
        </Section></details>

        {tab === 'inbox' && <Inbox messages={inbox} />}
        {tab === 'archive' && <Archive messages={archive} />}
        {tab === 'network' && (
          <Section title="Unclaimed Correspondence">
            <Box mb={1} color="label">Only unassigned network correspondence appears here. Colleagues' active inboxes and documents remain private.</Box>
            {!network_queue.length ? <NoticeBox>No outstanding correspondence outside your inbox.</NoticeBox> :
              network_queue.map((message) => (
                <Section key={message.message_code} title={`${message.title} | ${message.message_code}`}>
                  <LabeledList>
                    <LabeledList.Item label="Assigned to">{message.assigned_to || 'Unassigned'}</LabeledList.Item>
                    <LabeledList.Item label="Priority">{message.priority}</LabeledList.Item>
                    <LabeledList.Item label="Installation">{message.installation_name}</LabeledList.Item>
                  </LabeledList>
                </Section>
              ))}
          </Section>
        )}
        {tab === 'network' && (
          <Section title="Online Liaison Workload">
            <Box color="label" mb={1}>Combined Tasking and Communications workload points. Individual correspondence and paperwork remain private.</Box>
            {!workload_overview.length ? <Box color="label">No authenticated Liaisons online.</Box> : (
              <LabeledList>
                {workload_overview.map((entry) => (
                  <LabeledList.Item key={entry.name} label={entry.name}>
                    {entry.load} workload points
                  </LabeledList.Item>
                ))}
              </LabeledList>
            )}
          </Section>
        )}
        {tab === 'paperwork' && <PaperworkPanel paperwork={paperwork} />}
      
          </Layout.Content>
        </Window.Content>
    </Window>
  );
};

const Inbox = ({ messages }: { messages: SectorMessage[] }) => {
  const [selectedCode, setSelectedCode] = useLocalState('ccpostCommsSelectedMessage', '');
  if (!messages.length) {
    return <NoticeBox>No pending sector communications.</NoticeBox>;
  }
  const current = messages.find((message) => message.message_code === selectedCode) || messages[0];
  return (
    <div className="CCPostMailboxLayout">
      <div className="CCPostMailboxList">
        {messages.map((message) => (
          <Button
            key={message.message_code}
            selected={current.message_code === message.message_code}
            icon={message.message_type === 'REQUEST' ? 'circle-exclamation' : 'envelope'}
            onClick={() => setSelectedCode(message.message_code)}
            tooltip={`${message.installation_name} | ${message.priority}`}
          >
            {message.title} ({message.message_code})
          </Button>
        ))}
      </div>
      <div className="CCPostMailboxReader">
        <MessageCard key={current.message_code} message={current} archived={false} />
      </div>
    </div>
  );
};

const Archive = ({ messages }: { messages: SectorMessage[] }) => {
  const { act } = useBackend<Data>();
  const [archiveSearch, setArchiveSearch] = useLocalState('ccpostArchiveSearch', '');
  const [moreFilters, setMoreFilters] = useLocalState('ccpostArchiveMoreFilters', false);
  const [expandedCodes, setExpandedCodes] = useLocalState<string[]>('ccpostArchiveExpandedCodes', []);
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
    if (archiveSearch.trim() && !`${message.title} ${message.body} ${message.message_code} ${message.installation_name} ${message.installation_code} ${message.sender_name} ${message.resolution_status}`.toLowerCase().includes(archiveSearch.trim().toLowerCase())) {
      return false;
    }
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
    !!archiveSearch.trim() ||
    installationFilter !== 'ALL' ||
    priorityFilter !== 'ALL' ||
    resolutionFilter !== 'ALL';

  return (
    <>
      <div className="CCPostOversightFilters">
        <Input placeholder="Search archive" value={archiveSearch} onChange={setArchiveSearch} width="210px" />
        {['ALL', ...priorities].map((priority) => (
          <Button key={priority} selected={priorityFilter === priority} onClick={() => setPriorityFilter(priority)}>{priority === 'ALL' ? 'All priorities' : priority}</Button>
        ))}
        <Button icon="filter" selected={moreFilters} onClick={() => setMoreFilters(!moreFilters)}>{moreFilters ? 'Hide Filters' : 'More Filters'}</Button>
      </div>
      {moreFilters && (
        <Section title="Additional Archive Filters">
          <Box bold color="label">Installation</Box>
          <div className="CCPostOversightFilters">{['ALL', ...installationCodes].map((code) => <Button key={code} selected={installationFilter === code} onClick={() => setInstallationFilter(code)}>{code === 'ALL' ? 'All installations' : code}</Button>)}</div>
          <Box bold color="label">Resolution</Box>
          <div className="CCPostOversightFilters">{['ALL', ...resolutions].map((resolution) => <Button key={resolution} selected={resolutionFilter === resolution} onClick={() => setResolutionFilter(resolution)}>{resolution === 'ALL' ? 'All resolutions' : resolution}</Button>)}</div>
        </Section>
      )}

      <Section
        title={`Resolved Communications (${filteredMessages.length}/${messages.length})`}
        buttons={
          <>
            {filtersActive && (
              <Button
                icon="rotate-left"
                onClick={() => {
                  setArchiveSearch('');
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
          filteredMessages.map((message) => {
            const expanded = expandedCodes.includes(message.message_code);
            return (
              <div key={message.message_code} className="CCPostArchiveEntry">
                <button
                  type="button"
                  className={`CCPostArchiveEntry__summary ${expanded ? 'CCPostArchiveEntry__summary--open' : ''}`}
                  aria-expanded={expanded}
                  onClick={() => setExpandedCodes(expanded
                    ? expandedCodes.filter((code) => code !== message.message_code)
                    : [...expandedCodes, message.message_code])}
                >
                  <span className="CCPostArchiveEntry__title">{message.title}</span>
                  <span>{message.message_code} · {message.installation_name}</span>
                  <span>{message.resolution_status} · {message.issued_at}</span>
                  <span className="CCPostArchiveEntry__expand">{expanded ? 'Collapse ▲' : 'Expand ▼'}</span>
                </button>
                {expanded && <MessageCard message={message} archived />}
              </div>
            );
          })
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
              tooltip={!paperwork.document_inserted ? 'Insert a stamped document before ejecting.' : 'Return the inserted document.'}
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
        <LabeledList.Item label="Assigned To">{paperwork.assigned_to || 'Unassigned'}</LabeledList.Item>
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

      <Box mt={1.5} className="CCPostDocumentCard">
        <Box bold mb={1}>To: Liaison {paperwork.assigned_to || 'Unassigned'}</Box>
        <Box color="label" mb={1}>From: {paperwork.sender_role} {paperwork.sender_name}</Box>
        <Box>{paperwork.body}</Box>
      </Box>

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
  const reviewRequired = isRequest && !message.review_expeditable;
  const reviewReady = !reviewRequired || (!!message.review_started && !!message.review_verified);

  return (
    <Section
      title={`${message.title} — ${message.message_code}`}
      buttons={archived ? (
        <Button icon="print" onClick={() => act('print_message', { message_code: message.message_code })}>
          Print Record
        </Button>
      ) : undefined}
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
        <LabeledList.Item label="Assigned To">{message.assigned_to || 'Unassigned'}</LabeledList.Item>

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

      <Box mt={1.5} className="CCPostDocumentCard">
        <Box bold mb={1}>To: Liaison {message.assigned_to || 'Unassigned'}</Box>
        <Box color="label" mb={1}>From: {message.sender_role} {message.sender_name}</Box>
        <Box>{message.body}</Box>
      </Box>
      {!archived && (
        <div className="CCPostCaseReview">
          <Box bold mb={1}>Correspondence Decision</Box>
          {isRequest && Boolean(message.review_started) && (
            <div className="CCPostReviewDossier">
              <div className="CCPostReviewDossier__heading">CASE DOSSIER / {message.message_code}</div>
              <div className="CCPostReviewDossier__item">Requested allocation <strong>{message.allocation_cost} CU</strong></div>
              <div className="CCPostReviewDossier__item">Regional status <strong>{message.installation_status}</strong></div>
              <div className="CCPostReviewDossier__item">Relationship <strong>{message.installation_trust_label}</strong></div>
              <div className="CCPostReviewDossier__item">Network cross-check <strong>{message.review_verified ? 'COMPLETED' : 'PENDING'}</strong></div>
              {!!message.review_verification_summary && <Box mt={1} className="CCPostReviewFinding">{message.review_verification_summary}</Box>}
              {Boolean(message.review_clarification_pending) && <NoticeBox mt={1}>Clarification transmitted. Awaiting a reply from the installation.</NoticeBox>}
              {!!message.review_clarification_reply && <Box mt={1} className="CCPostReviewFinding"><Box bold>Installation Clarification</Box>{message.review_clarification_reply}</Box>}
              <div className="CCPostReviewTools">
                <Button icon="clipboard-check" selected={Boolean(message.review_verified)} disabled={Boolean(message.review_verified)} onClick={() => act('verify_review', { message_code: message.message_code })}>
                  {message.review_verified ? 'Records Checked' : 'Verify Records'}
                </Button>
                <Button icon="comment-dots" disabled={Boolean(message.review_clarification_pending) || Boolean(message.review_clarification_received)} onClick={() => act('request_clarification', { message_code: message.message_code })}>
                  {message.review_clarification_pending ? 'Awaiting Reply' : message.review_clarification_received ? 'Reply Received' : 'Request Clarification'}
                </Button>
              </div>
            </div>
          )}
          <div className="CCPostCaseActions">
            {isRequest && !message.review_started && (
              <Button icon="folder-open" color="average" onClick={() => act('begin_review', { message_code: message.message_code })}>
                Begin Review
              </Button>
            )}
            {isRequest && Boolean(message.review_started) && <Box color="label" inline>Under Review</Box>}
            {isRequest ? (
              <>
                <Button icon="check" color="good" disabled={insufficientAllocation || !reviewReady}
                  tooltip={insufficientAllocation ? `Requires ${message.allocation_cost} CU; ${available_allocation} CU available.` : !reviewReady ? 'Open the case and verify the network records before authorizing.' : undefined}
                  onClick={() => act('authorize', { message_code: message.message_code })}>
                  Authorize
                </Button>
                <Button icon="xmark" color="danger" onClick={() => act('deny', { message_code: message.message_code })}>
                  Deny
                </Button>
              </>
            ) : (
              <Button icon="check" color="good" onClick={() => act('acknowledge', { message_code: message.message_code })}>Acknowledge</Button>
            )}
          </div>
          {isRequest && !message.review_started && (
            <Box color="label" mt={1}>Open the file to review current sector records and request clarification before making an administrative decision.</Box>
          )}
          {isRequest && Boolean(message.review_expeditable) && (
            <Box color="label" mt={1}>Priority requests permit immediate authorization when urgent conditions prevent a complete review.</Box>
          )}
        </div>
      )}

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
