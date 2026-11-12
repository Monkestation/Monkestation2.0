import { CCPostHeader, CCPostPersonnelPortrait, CCPostServerUnavailable } from './CCPostTheme';
import { marked } from 'marked';
import { sanitizeText } from '../sanitize';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Chart,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Layout, Window } from '../layouts';

type ArchivedPaperEntry = {
  raw_text: string;
  font?: string;
  color?: string;
  bold?: boolean;
  advanced_html?: boolean;
};

type ArchivedPaperField = {
  field_index: number | string;
  field_data: ArchivedPaperEntry;
  is_signature?: boolean;
};

type ArchivedPaper = {
  raw_text_input: ArchivedPaperEntry[];
  raw_field_input: ArchivedPaperField[];
};

type DepartmentAssessment = {
  department_id: string;
  department_name: string;
  required: boolean | number;
  participated: boolean | number;
  rating?: string | null;
  assessed_by?: string;
  adjusted_amount?: number | null;
  credited?: number;
  grant_status?: string;
  radio_status?: string;
};

type TaskingAuditEvent = {
  action: string;
  actor: string;
  at: string;
  detail?: string;
};

type TaskingOrder = {
  order_code: string;
  category: string;
  subject: string;
  priority: string;
  instruction: string;
  status: string;
  issued_at: string;
  acknowledged_by?: string;
  acknowledged_at?: string;
  completed_by?: string;
  completed_at?: string;
  assigned_to?: string;
  assigned_terminal?: string;
  audit_events?: TaskingAuditEvent[];
  submission_type?: string;
  target_installation_code?: string;
  submitted_report_name?: string;
  standby_report_retained?: boolean;
  submitted_report_text?: string;
  submitted_report_markup?: string;
  archived_paper?: ArchivedPaper | null;
  report_stamp_verified?: boolean;
  source_order_code?: string;
  assigned_contact?: string;
  contact_unavailable?: boolean | number;
  contact_reassignable?: boolean | number;
  assigned_role?: string;
  deferral_count?: number;
  deferral_paused?: boolean;
  deferral_reason?: string;
  deferred_by?: string;
  resume_in_seconds?: number;
  expires_in_seconds?: number;
  cooperation_available?: boolean;
  assessments_complete?: boolean | number;
  department_assessments?: DepartmentAssessment[];
};

type SubmittedReport = {
  name: string;
  has_text: boolean | number;
  has_centcom_stamp: boolean | number;
  record_installation_code?: string | null;
  validation_message?: string | null;
  valid: boolean | number;
};

type ReassignableTask = {
  owner_key: string;
  order_code: string;
  subject: string;
  assigned_to: string;
  priority: string;
  origin?: string;
  expires_in_seconds?: number;
};

type TaskingServerRequest = {
  subject: string;
  priority: string;
  expires_in_seconds: number;
};

type TaskingTelemetrySample = {
  time: string;
  queue: number;
  dispatched: number;
  online: number;
};

type TaskingServerLiaison = {
  name: string;
  assignment: string;
  held: number;
};

type Data = {
  is_server?: boolean;
  server_online?: boolean;
  server_status?: string;
  server_faulted?: boolean | number;
  server_recalibrating?: boolean | number;
  server_recalibration_seconds?: number;
  server_can_recalibrate?: boolean | number;
  server_history?: TaskingTelemetrySample[];
  server_total_dispatches?: number;
  server_total_faults?: number;
  server_initializing?: boolean;
  server_calibrating?: boolean;
  server_panel_open?: boolean;
  server_intrusion_active?: boolean | number;
  server_intrusion_seconds?: number;
  server_intrusion_history?: string[];
  server_data_compromised?: boolean | number;
  server_storage_inserted?: boolean | number;
  server_storage_status?: string;
  server_can_export?: boolean | number;
  server_can_eject?: boolean | number;
  server_is_gorlex?: boolean | number;
  server_liaison_authorized?: boolean | number;
  server_queue_capacity?: number;
  server_queue_size?: number;
  server_dispatch_seconds?: number;
  server_intake_seconds?: number;
  server_routine_queue_size?: number;
  intake_seconds?: number;
  queued_routine_requests?: number;
  server_queue?: TaskingServerRequest[];
  server_liaisons?: TaskingServerLiaison[];
  server_log?: string[];
  authenticated?: boolean;
  admin_server_online?: boolean | number;
  admin_server_status?: string;
  identity_portrait?: string | null;
  identity_detected?: boolean;
  identity_issue?: string;
  session_owner?: string;
  network_terminals?: number;
  network_inboxes?: number;
  network_active_tasks?: number;
  network_completed?: number;
  claimable_tasks?: ReassignableTask[];
  my_reassignment_offers?: ReassignableTask[];
  available_reassignment_offers?: ReassignableTask[];
  routine_cooldown_seconds?: number;
  current_order: TaskingOrder | null;
  standby_order?: TaskingOrder | null;
  can_switch_investigation?: boolean;
  history: TaskingOrder[];
  deferred_orders: TaskingOrder[];
  max_deferred_orders?: number;
  on_hold_orders: TaskingOrder[];
  queued_incidents: { subject: string; priority: string; reason: string }[];
  read_only?: boolean;
  queued_events: number;
  queued_priorities?: Record<string, number>;
  queued_events_ready: number;
  queued_followups: number;
  pending_followups?: { subject: string; source_order_code: string; ready_in_seconds: number }[];
  dispatch_seconds?: number;
  dispatch_pending?: boolean | number;
  dispatch_machine_available?: boolean | number;
  submitted_report: SubmittedReport | null;
};

// Color only the monetary outcome. The remainder of the interface retains
// NTOS styling, and zero-credit outcomes are not presented as successes.
const departmentGrantColors: Record<string, string> = {
  'Very Dissatisfied': '#A62B2B',
  Dissatisfied: '#A3641D',
  Neutral: '#806322',
  Satisfied: '#27653D',
  'Very Satisfied': '#17566E',
};

export const CCPostTasking = () => {
  const { act, data } = useBackend<Data>();
  const [documentsOpen, setDocumentsOpen] = useLocalState('ccpostTaskDocuments', false);
  const [helpOpen, setHelpOpen] = useLocalState('ccpostTaskHelp', false);
  const [serverTab, setServerTab] = useLocalState('ccpostServerTab', 'overview');
  const [tab, setTab] = useLocalState('ccpostTaskMainTab', 'active');
  const [deferOpen, setDeferOpen] = useLocalState('ccpostTaskDefer', false);
  const [expandedReportCode, setExpandedReportCode] = useLocalState(
    'ccpostTaskExpandedReportCode',
    '',
  );

  const {
    current_order,
    standby_order = null,
    can_switch_investigation = false,
    history = [],
    deferred_orders = [],
    max_deferred_orders = 2,
    on_hold_orders = [],
    queued_incidents = [],
    read_only = false,
    queued_events = 0,
    queued_priorities = {},
    queued_events_ready = 0,
    queued_followups = 0,
    pending_followups = [],
    dispatch_seconds = 0,
    intake_seconds = 0,
    queued_routine_requests = 0,
    dispatch_pending = false,
    dispatch_machine_available = true,
    submitted_report,
    authenticated = false,
    admin_server_online = false,
    admin_server_status = 'SERVER MISSING',
    identity_portrait = null,
    identity_detected = false,
    identity_issue = '',
    session_owner = '',
    network_terminals = 0,
    network_inboxes = 0,
    network_active_tasks = 0,
    network_completed = 0,
    claimable_tasks = [],
    my_reassignment_offers = [],
    available_reassignment_offers = [],
    routine_cooldown_seconds = 0,
  } = data;

  const offerableTasks = [
    ...(current_order ? [{ ...current_order, origin: 'Active' }] : []),
    ...(standby_order ? [{ ...standby_order, origin: 'Standby' }] : []),
    ...deferred_orders.map((order) => ({ ...order, origin: 'Deferred' })),
  ].filter((order) =>
    order.status !== 'Completed' &&
    order.priority !== 'Critical' &&
    order.priority !== 'Priority' &&
    order.category !== 'Internal Compliance' &&
    !order.standby_report_retained &&
    (order.origin !== 'Active' || !submitted_report)
  );
  const mayClaimTransfer = !read_only && !current_order && !standby_order && !on_hold_orders.length && !submitted_report;


  // The physical dispatch server and personal workstation share one
  // registered TGUI interface but intentionally expose different controls.
  if (data.is_server) {
    const {
      server_online = false,
      server_status = 'SERVER MISSING',
      server_initializing = false,
      server_panel_open = false,
      server_queue_capacity = 6,
      server_queue_size = 0,
      server_dispatch_seconds = 0,
      server_intake_seconds = 0,
      server_routine_queue_size = 0,
      server_queue = [],
      server_liaisons = [],
      server_log = [],
      server_history = [],
      server_total_dispatches = 0,
      server_total_faults = 0,
      server_can_recalibrate = false,
      server_recalibrating = false,
      server_recalibration_seconds = 0,
      server_intrusion_active = false,
      server_intrusion_seconds = 0,
      server_intrusion_history = [],
      server_data_compromised = false,
      server_storage_inserted = false,
      server_storage_status = 'NO CARTRIDGE',
      server_can_export = false,
      server_can_eject = false,
      server_is_gorlex = false,
      server_liaison_authorized = false,
    } = data;
    const queuePoints = server_history.map((sample, index) => [index, sample.queue]);
    const dispatchPoints = server_history.map((sample, index) => [index, sample.dispatched]);
    const maxQueue = Math.max(1, ...server_history.map((sample) => sample.queue));
    const maxDispatch = Math.max(1, ...server_history.map((sample) => sample.dispatched));
    const timelineEnd = Math.max(1, server_history.length - 1);
    return (
      <Window title="Central Command | Tasking Distribution Server" width={740} height={720} theme="ntos">
        <Window.Content className="ccpost-theme ccpost-theme--infrastructure ccpost-admin-v2 CCPostServerDashboard">
          <CCPostHeader title="Tasking Distribution Server" division="CENTRAL COMMAND" status="DISPATCH INFRASTRUCTURE" />
          <div className="CCPostAdminNav"><Tabs fluid>
            <Tabs.Tab icon="chart-line" selected={serverTab === 'overview'} onClick={() => setServerTab('overview')}>Telemetry</Tabs.Tab>
            <Tabs.Tab icon="list" selected={serverTab === 'queue'} onClick={() => setServerTab('queue')}>Dispatch Queue ({server_queue.length})</Tabs.Tab>
            <Tabs.Tab icon="terminal" selected={serverTab === 'diagnostics'} onClick={() => setServerTab('diagnostics')}>Diagnostics</Tabs.Tab>
          </Tabs></div>
          <Layout.Content scrollable className="CCPostAdminBody">
          <div className="CCPostTechnicalEyebrow">NETWORK OPERATIONS / PRIMARY ADMINISTRATIVE DISPATCH NODE</div>
          <div className="CCPostMetricRow">
            <div className="CCPostMetric"><div className="CCPostMetric__value">{server_status}</div><div className="CCPostMetric__label">NETWORK HEALTH</div></div>
            <div className="CCPostMetric"><div className="CCPostMetric__value">{server_liaisons.length}</div><div className="CCPostMetric__label">REGISTERED LIAISONS</div></div>
            <div className="CCPostMetric"><div className="CCPostMetric__value">{server_queue_size} / {server_queue_capacity}</div><div className="CCPostMetric__label">CENTRAL QUEUE</div></div>
            <div className="CCPostMetric"><div className="CCPostMetric__value">{server_total_dispatches}</div><div className="CCPostMetric__label">TOTAL DISPATCHES</div></div>
          </div>
          {!server_online && (
            <Section title="Network Diagnostic Alert">
              <NoticeBox danger={server_status === 'INSTALLATION OFFLINE' || server_status === 'SERVER DAMAGED'}>
                Administrative services unavailable: {server_status}. Tasking and Sector Communications are suspended.
              </NoticeBox>
              {server_recalibrating ? (
                <Box className="CCPostRecalibration"><Box bold>NETWORK RECALIBRATION IN PROGRESS</Box><Box>{server_recalibration_seconds} seconds remaining</Box></Box>
              ) : (
                <Button icon="wrench" color="average" disabled={!server_can_recalibrate} onClick={() => act('start_recalibration')}>
                  Initiate Network Recalibration (60s)
                </Button>
              )}
              {!server_can_recalibrate && !server_recalibrating && (
                <Box mt={1} color="label">Only synchronization faults are recalibrated. Restore power or replace damaged hardware first.</Box>
              )}
            </Section>
          )}
          {(Boolean(server_intrusion_active) || Boolean(server_data_compromised)) && (
            <Section title="CLASSIFIED NETWORK SECURITY ALERT">
              {server_intrusion_active ? (
                <>
                  <NoticeBox danger>Unauthorized classified data extraction detected. Estimated transfer time remaining: {server_intrusion_seconds}s.</NoticeBox>
                  {Boolean(server_liaison_authorized) && <Box color="label">Use the storage controls below to interrupt the transfer or eject the cartridge.</Box>}
                </>
              ) : (
                <NoticeBox danger>Classified Tasking Server database compromise recorded. Investigate the physical export port.</NoticeBox>
              )}
            </Section>
          )}
          <Section title="Removable Storage / Classified Export Port">
            <div className="CCPostSeveranceStorage">
              <div>
                <Box bold>STORAGE STATUS</Box>
                <Box color={server_storage_inserted ? 'good' : 'label'}>{server_storage_status}</Box>
                <Box color="label" fontSize="11px" mt={0.5}>
                  {server_is_gorlex
                    ? 'Insert your issued blank encrypted cartridge by using it on the server with its maintenance panel open. Start the transfer here, then return to eject it.'
                    : 'Only physically inserted storage can receive a classified export. Unauthorized transfers are recorded and may be terminated by Central Command.'}
                </Box>
              </div>
              <div className="CCPostSeveranceStorage__actions">
                {Boolean(server_is_gorlex) && (
                  <Button icon="download" color="average" disabled={!server_can_export} onClick={() => act('start_classified_export')}>
                    Start Classified Export (45s)
                  </Button>
                )}
                {Boolean(server_can_eject) && (
                  <Button icon="eject" disabled={!server_storage_inserted} onClick={() => act('eject_classified_cartridge')}>
                    Eject Cartridge
                  </Button>
                )}
                {Boolean(server_liaison_authorized) && Boolean(server_intrusion_active) && (
                  <Button icon="shield-alt" color="bad" onClick={() => act('interrupt_intrusion')}>
                    Terminate Unauthorized Transfer
                  </Button>
                )}
              </div>
            </div>
            {Boolean(server_intrusion_active) && (
              <NoticeBox danger>Unauthorized export in progress. Estimated transfer time remaining: {server_intrusion_seconds}s. Ejecting the cartridge interrupts the download.</NoticeBox>
            )}
          </Section>
          
          {serverTab === 'overview' && (
            <>
              <div className="CCPostTelemetryGrid">
                <Section title="QUEUE OCCUPANCY / 1 MIN SAMPLE">
                  {server_history.length ? (
                    <Box height="126px" position="relative" className="CCPostTelemetryPlot">
                      <Chart.Line fillPositionedParent data={queuePoints} rangeX={[0, timelineEnd]} rangeY={[0, maxQueue]} strokeColor="rgba(76, 220, 207, 1)" fillColor="rgba(76, 220, 207, 0.18)" />
                    </Box>
                  ) : <Box color="label">Awaiting first telemetry sample.</Box>}
                  <Box color="label">Current buffer: {server_queue_size}/{server_queue_capacity} slots</Box>
                </Section>
                <Section title="CUMULATIVE DISPATCH THROUGHPUT">
                  {server_history.length ? (
                    <Box height="126px" position="relative" className="CCPostTelemetryPlot">
                      <Chart.Line fillPositionedParent data={dispatchPoints} rangeX={[0, timelineEnd]} rangeY={[0, maxDispatch]} strokeColor="rgba(148, 190, 247, 1)" fillColor="rgba(148, 190, 247, 0.16)" />
                    </Box>
                  ) : <Box color="label">Awaiting first telemetry sample.</Box>}
                  <Box color="label">Lifetime assignments dispatched: {server_total_dispatches}</Box>
                </Section>
              </div>
              <Section title="Scheduler Telemetry">
                <div className="CCPostTelemetryStats">
                  <div><span>INTAKE WINDOW</span><strong>{server_online ? `${server_intake_seconds}s` : 'PAUSED'}</strong></div>
                  <div><span>ROUTINE BUFFER</span><strong>{server_routine_queue_size}</strong></div>
                  <div><span>DISPATCH CYCLE</span><strong>{server_online && server_routine_queue_size ? `${server_dispatch_seconds}s` : server_online ? 'STANDBY' : 'PAUSED'}</strong></div>
                  <div><span>HISTORICAL FAULTS</span><strong>{server_total_faults}</strong></div>
                </div>
              </Section>
              <Section title={`Registered Personnel (${server_liaisons.length})`}>
                {!server_liaisons.length ? <Box color="label">No Liaisons registered.</Box> : (
                  <LabeledList>{server_liaisons.map((liaison) => (
                    <LabeledList.Item key={liaison.name} label={liaison.name}>{liaison.assignment} | Held: {liaison.held}</LabeledList.Item>
                  ))}</LabeledList>
                )}
              </Section>
            </>
          )}
          {serverTab === 'queue' && (
            <Section title="Central Incident Queue">
              {!server_queue.length ? <NoticeBox>No unassigned emergency or elevated requests.</NoticeBox> : (
                <LabeledList>{server_queue.map((request, index) => (
                  <LabeledList.Item key={`${request.subject}-${index}`} label={request.priority}>
                    {request.subject} | Expires in {Math.ceil(request.expires_in_seconds / 60)} minutes
                  </LabeledList.Item>
                ))}</LabeledList>
              )}
              <Box mt={1} color="label">Emergency/Priority capacity remains reserved. During recoverable outages, pending requests retain their lifespan.</Box>
            </Section>
          )}
          {serverTab === 'diagnostics' && (
            <>
              <Section title="Hardware &amp; Maintenance">
                <LabeledList>
                  <LabeledList.Item label="Network state">{server_status}</LabeledList.Item>
                  <LabeledList.Item label="Initial calibration">{server_initializing ? 'Active' : 'Complete'}</LabeledList.Item>
                  <LabeledList.Item label="Maintenance panel">{server_panel_open ? 'Open' : 'Secured'}</LabeledList.Item>
                  <LabeledList.Item label="Faults this shift">{server_total_faults}</LabeledList.Item>
                  <LabeledList.Item label="Classified export">{server_intrusion_active ? 'UNAUTHORIZED TRANSFER ACTIVE' : server_data_compromised ? 'DATABASE COMPROMISED' : 'SECURE'}</LabeledList.Item>
                </LabeledList>
              </Section>
              <Section title="Classified Security Event History">
                {!server_intrusion_history.length ? <Box color="label">No unauthorized transfers recorded.</Box> : (
                  <div className="CCPostDiagnosticLog">{server_intrusion_history.map((entry, index) => <div key={index}>{entry}</div>)}</div>
                )}
              </Section>
              <Section title="Administrative Event Log">
                {!server_log.length ? <Box color="label">No dispatch events recorded.</Box> : (
                  <div className="CCPostDiagnosticLog">
                    {server_log.slice(0, 26).map((entry, index) => <div key={index}>{entry}</div>)}
                  </div>
                )}
              </Section>
            </>
          )}
        
          </Layout.Content>
        </Window.Content>
      </Window>
    );
  }

  if (!authenticated) {
    return (
      <Window title="Central Command Tasking | Sign In" width={570} height={490} theme="ntos">
        <Window.Content className="ccpost-theme ccpost-theme--sage ccpost-admin-v2">
          <CCPostHeader title="Personnel Tasking" division="CENTRAL COMMAND" />
          <Layout.Content scrollable className="CCPostAdminBody">
          {!admin_server_online && <CCPostServerUnavailable status={admin_server_status} />}
          <div className="CCPostIdentityStrip"><CCPostPersonnelPortrait portrait={identity_portrait} label="OFFICIAL ID RECORD" /><div><strong>{identity_detected ? 'Registered Liaison Identified' : 'Personnel Verification Required'}</strong><div>Authentication uses the Central Command Human Resources roster.</div><div className="CCPostIdentityStrip__meta">{session_owner || 'No active workstation session'}</div></div></div>
          <div className="CCPostLogin">
          <Stack vertical fill>
            <Stack.Item>
              <Section title="Personnel Authentication">
                {session_owner ? (
                  <NoticeBox>
                    This workstation currently has a session for {session_owner}.
                    Signing in with another authorized Liaison ID closes that local
                    session. Outstanding work is preserved on the network.
                  </NoticeBox>
                ) : (
                  <Box color="label" mb={1}>
                    No authenticated personnel session on this workstation.
                  </Box>
                )}
                <LabeledList>
                  <LabeledList.Item label="Personnel record">
                    {identity_detected ? 'HR roster record detected' : 'Registered Liaison ID required'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Security">
                    Authorized Central Command personnel only
                  </LabeledList.Item>
                </LabeledList>
                {!identity_detected && !!identity_issue && (
                  <Box color="average" mt={1}>{identity_issue}</Box>
                )}
                <Button
                  mt={1.5}
                  fluid
                  icon="sign-in-alt"
                  color="good"
                  disabled={!identity_detected || read_only || !admin_server_online}
                  onClick={() => act('login')}
                >
                  Sign In
                </Button>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Box color="label" fontSize="11px" textAlign="center">
                Official activity is recorded. Session authentication does not change
                salary, personnel status or HR compensation decisions.
              </Box>
            </Stack.Item>
          </Stack>
          </div>
        
          </Layout.Content>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      title="Central Command Tasking"
      width={820}
      height={760}
      theme="ntos"
    >
      <Window.Content className="ccpost-theme ccpost-theme--sage ccpost-admin-v2">
          <CCPostHeader title="Personnel Tasking" division="CENTRAL COMMAND" />
          <div className="CCPostAdminNav"><Tabs fluid>
              <Tabs.Tab icon="clipboard-list" selected={tab === 'active'} onClick={() => setTab('active')}>
                My Tasks
              </Tabs.Tab>
              <Tabs.Tab icon="pause" selected={tab === 'deferred'} onClick={() => setTab('deferred')}>
                On Hold ({on_hold_orders.length + deferred_orders.length})
              </Tabs.Tab>
              <Tabs.Tab icon="archive" selected={tab === 'archive'} onClick={() => setTab('archive')}>
                History ({history.length})
              </Tabs.Tab>
              <Tabs.Tab icon="sitemap" selected={tab === 'network'} onClick={() => setTab('network')}>
                Network
              </Tabs.Tab>
            </Tabs></div>
          <Layout.Content scrollable className="CCPostAdminBody">
          {!admin_server_online && <CCPostServerUnavailable status={admin_server_status} />}
        <Stack vertical>
          <Stack.Item>
            <div className="CCPostWorkspaceToolbar">
              <div><strong>Assignment Workspace</strong><span>Authenticated: {session_owner || 'Central Command Liaison'}</span></div>
              <div className="CCPostWorkspaceToolbar__actions">
                <Button icon="print" selected={documentsOpen} onClick={() => setDocumentsOpen(!documentsOpen)}>Documents</Button>
                <Button icon="question-circle" onClick={() => setHelpOpen(!helpOpen)}>{helpOpen ? 'Close Manual' : 'Manual'}</Button>
                {!read_only && <Button icon="sign-out-alt" color="average" onClick={() => act('logout')}>Sign Out</Button>}
              </div>
            </div>
            {documentsOpen && (
            <Section title="Printable Administrative Templates">
              <Box mb={1}>
                Interview and incident forms include successive writable lines
                for detailed statements and findings. Complete them with an
                approved pen and authenticate submitted reports with the
                Central Command seal. The Radio Frequency Reference is a
                restricted reference sheet and requires no stamp.
              </Box>
              {[
                { id: 'interview', label: 'Interview Record' },
                { id: 'inspection', label: 'Inspection Checklist' },
                { id: 'incident', label: 'Incident Report' },
                { id: 'information', label: 'Information Request' },
                { id: 'frequencies', label: 'Intercom Frequency Reference' },
              ].map((template) => (
                <Button
                  key={template.id}
                  icon="print"
                  mb={0.5}
                  mr={0.5}
                  onClick={() => act('print_template', { template_id: template.id })}
                >
                  {template.label}
                </Button>
              ))}
            </Section>
            )}

            {helpOpen && (
              <Section title="Central Command Assignment Procedures">
                <Box>Record acknowledgment, investigate the directive and submit a separate written report bearing an official Central Command stamp. Installation-record tasks require the original certified record printed from Remote Oversight.</Box>
                <Box mt={1}>Consult existing records before contacting station personnel. One concise request is sufficient; avoid interrupting essential work. Record unavailable cooperation as Not Assessed. Assessments affect departmental grants, not Liaison CU rewards.</Box>
                <Box mt={1}>Standby work preserves documentation when switched. Deferred work has its own deadlines, while emergency-suspended assignments retain progress. The Network tab handles voluntary reassignment and recovery.</Box>
              </Section>
            )}
          </Stack.Item>
          {Boolean(read_only) && (
            <Stack.Item>
              <NoticeBox>OBSERVER MODE: Terminal contents are available for viewing only. All operational actions remain restricted.</NoticeBox>
            </Stack.Item>
          )}
          
          {tab === 'active' && (
            <div className="CCPostTaskWorkspace">
            <div className="CCPostTaskWorkspace__rail">
              <div className="CCPostTaskRailHeader">MY ASSIGNMENTS</div>
              <div className="CCPostTaskRailCard CCPostTaskRailCard--selected">
                <strong>{current_order ? current_order.subject : 'No active assignment'}</strong>
                <span>{current_order ? `${current_order.order_code} · ${current_order.priority} · ${current_order.status}` : 'Awaiting dispatch'}</span>
              </div>
              {standby_order && (
                <button type="button" className="CCPostTaskRailCard" disabled={Boolean(read_only) || !can_switch_investigation}
                  title={!can_switch_investigation ? 'Resolve the current priority emergency before switching.' : 'Switch to this investigation; documentation is retained.'}
                  onClick={() => act('switch_investigation', { order_code: standby_order.order_code })}>
                  <strong>{standby_order.subject}</strong><span>{standby_order.order_code} · STANDBY{standby_order.standby_report_retained ? ' · Report retained' : ''}</span>
                </button>
              )}
            </div>
            <div className="CCPostTaskWorkspace__detail">
          <Stack.Item>
            {!current_order ? (
              <Section title="Current Tasking Order">
                <NoticeBox>
                  No active Central Command tasking order.
                </NoticeBox>
              </Section>
            ) : (
              <Section title={current_order.subject}>

                {deferOpen && (
                  <Section title="Temporarily defer this assignment">
                    <Box mb={1}>
                      Select a reason. The order becomes eligible to resume after
                      five minutes and expires after 15 minutes of available
                      waiting time. Up to two orders may be deferred per Liaison,
                      with each order deferrable at most twice. Expiry is paused
                      while another active assignment prevents resumption.
                      Compliance and Critical orders cannot be deferred.
                    </Box>
                    {[
                      'Awaiting staffing',
                      'Awaiting documents',
                      'Situation unresolved',
                      'Additional authorization',
                    ].map((reason) => (
                      <Button.Confirm
                        key={reason}
                        icon="clock"
                        mr={1}
                        mb={1}
                        confirmContent={`Defer this order: ${reason}?`}
                        onClick={() => {
                          act('defer_order', { reason });
                          setDeferOpen(false);
                        }}
                      >
                        {reason}
                      </Button.Confirm>
                    ))}
                  </Section>
                )}
                <div className="CCPostTaskMeta">
                  <span><b>{current_order.order_code}</b></span>
                  <span>{current_order.priority}</span>
                  <span>{current_order.status}</span>
                  <span>Issued: {current_order.issued_at}</span>
                </div>
                <Collapsible title="Official Tasking Record">
                <LabeledList>
                  <LabeledList.Item label="Directive Status">
                    <Box
                      inline
                      bold
                      color={taskStatusColor(current_order.status)}
                    >
                      {current_order.status === 'Pending' ? 'Awaiting Acknowledgement' : current_order.status}
                    </Box>
                  </LabeledList.Item>

                  <LabeledList.Item label="Command Priority">
                    {current_order.priority}
                  </LabeledList.Item>

                  <LabeledList.Item label="Administrative Classification">
                    {current_order.category}
                  </LabeledList.Item>

                  <LabeledList.Item label="Directive Subject">
                    {current_order.subject}
                  </LabeledList.Item>

                  <LabeledList.Item label="Dispatch Time">
                    {current_order.issued_at}
                  </LabeledList.Item>
                  <LabeledList.Item label="Designated Liaison">
                    {current_order.assigned_to || session_owner}
                  </LabeledList.Item>

                  {Boolean(current_order.contact_unavailable) && (
                    <LabeledList.Item label="Contact Status">
                      <Box color="average">Unavailable. Record genuine attempted contact in the submitted report.</Box>
                    </LabeledList.Item>
                  )}
                  {!!current_order.acknowledged_by && (
                    <LabeledList.Item label="Acknowledged By">
                      {current_order.acknowledged_by}
                    </LabeledList.Item>
                  )}

                  {!!current_order.acknowledged_at && (
                    <LabeledList.Item label="Acknowledged At">
                      {current_order.acknowledged_at}
                    </LabeledList.Item>
                  )}

                  {!!current_order.completed_by && (
                    <LabeledList.Item label="Completed By">
                      {current_order.completed_by}
                    </LabeledList.Item>
                  )}

                  {!!current_order.completed_at && (
                    <LabeledList.Item label="Completed At">
                      {current_order.completed_at}
                    </LabeledList.Item>
                  )}
                </LabeledList>
                </Collapsible>

                <Box mt={2} className="CCPostTaskDirective">
                  <Box bold mb={1}>
                    Directive
                  </Box>

                  {current_order.instruction}
                </Box>
                <div className="CCPostTaskActions">
                    {current_order.status === 'Pending' && (
                      <Button
                        icon="check"
                        color="good"
                        onClick={() => act('acknowledge')}
                      >
                        Acknowledge Order
                      </Button>
                    )}

                    {current_order.status !== 'Completed' && (
                      <Button
                        icon="clock"
                        disabled={
                          current_order.priority === 'Critical' ||
                          current_order.category === 'Internal Compliance' ||
                          !!submitted_report ||
                          (current_order.deferral_count || 0) >= 2 ||
                          deferred_orders.length >= max_deferred_orders
                        }
                        onClick={() => setDeferOpen(!deferOpen)}
                      >
                        {deferOpen ? 'Cancel Deferral' : 'Defer Order'}
                      </Button>
                    )}
                    {current_order.status !== 'Completed' && (
                      <Button
                        icon="clipboard-check"
                        color="good"
                        disabled={
                          current_order.status !== 'Acknowledged' ||
                          !submitted_report ||
                          !submitted_report.valid ||
                          (Boolean(current_order.cooperation_available) &&
                            !current_order.assessments_complete)
                        }
                        onClick={() => act('complete')}
                      >
                        Mark Complete
                      </Button>
                    )}

                    {Boolean(current_order.contact_reassignable) &&
                      current_order.status === 'Acknowledged' && (
                        <Button
                          icon="user-friends"
                          disabled={Boolean(read_only)}
                          tooltip="If the designated contact is unavailable, request a suitable replacement or document attempted contact."
                          onClick={() => act('reassign_contact')}
                        >
                          Recheck Contact
                        </Button>
                      )}
                    <Button
                      icon="print"
                      onClick={() =>
                        act('print_order', {
                          order_code: current_order.order_code,
                        })
                      }
                    >
                      Print Copy
                    </Button>
                </div>
                {Boolean(current_order.cooperation_available) && (
                  <Section title="Department Cooperation Assessments" mt={2}>
                    <Box mb={1}>
                      Record actual cooperation. Select Not Assessed if personnel were unavailable or responding to an emergency. No adverse rating or radio notice is issued.
                    </Box>
                    {(current_order.department_assessments || []).map((grant) => (
                      <Section
                        key={grant.department_id}
                        title={grant.department_name}
                        mt={1}
                        buttons={
                          !grant.required ? (
                            <Button
                              icon={grant.participated ? 'check-square' : 'square'}
                              disabled={current_order.status !== 'Acknowledged' || Boolean(read_only)}
                              selected={Boolean(grant.participated)}
                              onClick={() => act('set_department_participation', {
                                department_id: grant.department_id,
                                participating: grant.participated ? 0 : 1,
                              })}
                            >
                              {grant.participated ? 'Participated' : 'Not participating'}
                            </Button>
                          ) : undefined
                        }
                      >
                        {grant.participated ? (
                          <>
                            <div className="CCPostAssessmentOptions">
                            {[
                              'Very Dissatisfied',
                              'Dissatisfied',
                              'Neutral',
                              'Satisfied',
                              'Very Satisfied',
                              'Not Assessed',
                            ].map((rating) => (
                              <Button
                                key={rating}
                                mr={0.5}
                                mb={0.5}
                                selected={grant.rating === rating}
                                disabled={current_order.status !== 'Acknowledged' || Boolean(read_only)}
                                onClick={() => act('set_cooperation', {
                                  department_id: grant.department_id,
                                  rating,
                                })}
                              >
                                {rating}
                              </Button>
                            ))}
                            </div>
                            <Box mt={1} p={1.5} backgroundColor="#e4ede5" textColor="#254631">
                              <Box bold>
                                Selected assessment: {grant.rating || 'Not yet assessed'}
                              </Box>
                              <Box
                                bold
                                color={departmentGrantColors[grant.rating || ''] || 'label'}
                                fontSize="18px"
                                mt={0.5}
                              >
                                {grant.rating === 'Not Assessed' ? 'No assessment issued' : grant.adjusted_amount === null || grant.adjusted_amount === undefined
                                  ? 'Select an assessment to calculate the grant'
                                  : `${grant.adjusted_amount} credits`}
                              </Box>
                            </Box>
                            <Box color="label" mt={0.5}>
                              {grant.rating === 'Not Assessed' ? 'No departmental grant or radio notice is issued.' : `The selected assessment and resulting departmental grant will be transmitted over the ${grant.department_name} radio channel.`}
                            </Box>
                          </>
                        ) : (
                          <Box color="label">
                            No departmental assessment, grant, or radio notice will be issued.
                          </Box>
                        )}
                      </Section>
                    ))}
                    {(current_order.department_assessments || []).length > 1 && (
                      <Box bold mt={1}>
                        Total Departmental Grants: {(current_order.department_assessments || []).reduce(
                          (total, grant) => total + (grant.participated ? (grant.adjusted_amount || 0) : 0),
                          0,
                        )} credits
                      </Box>
                    )}
                    <Box color="label" mt={1}>
                      Select an assessment for every participating department to complete this report.
                      Liaison CU rewards are unaffected.
                    </Box>
                  </Section>
                )}
              </Section>
            )}
          </Stack.Item>

          {!!current_order &&
            current_order.status !== 'Completed' && (
              <Stack.Item>
                <Section
                  title="Completion Documentation"
                  buttons={
                    submitted_report ? (
                      <Button
                        icon="eject"
                        onClick={() => act('eject_report')}
                      >
                        Eject Report
                      </Button>
                    ) : undefined
                  }
                >
                  {current_order.status === 'Pending' && (
                    <NoticeBox>
                      Acknowledge the current tasking order before
                      submitting supporting documentation.
                    </NoticeBox>
                  )}

                  {current_order.status === 'Acknowledged' &&
                    !submitted_report && (
                      <NoticeBox>
                        {current_order.submission_type === 'installation_record'
                          ? 'Print the specified installation record from the Remote Oversight Network, apply a CentCom stamp, and insert it into this terminal.'
                          : 'Submit a separate written report by using the paper on this terminal. The report must contain your own findings and an official Central Command stamp.'}
                      </NoticeBox>
                    )}

                  {!!submitted_report && (
                    <>
                      <LabeledList>
                        <LabeledList.Item label="Document">
                          {submitted_report.name}
                        </LabeledList.Item>

                        <LabeledList.Item
                          label={current_order.submission_type === 'installation_record'
                            ? 'Installation Record'
                            : 'Written Report'}
                        >
                          {submitted_report.has_text ? (
                            <Box color="good" bold>
                              VALID
                            </Box>
                          ) : (
                            <Box color="bad" bold>
                              MISSING
                            </Box>
                          )}
                        </LabeledList.Item>

                        {current_order.submission_type === 'installation_record' && (
                          <LabeledList.Item label="Installation Identification">
                            {submitted_report.record_installation_code || 'NOT IDENTIFIED'}
                            {' / Required: '}
                            {current_order.target_installation_code || 'UNSPECIFIED'}
                          </LabeledList.Item>
                        )}

                        <LabeledList.Item label="CentCom Stamp">
                          {submitted_report.has_centcom_stamp ? (
                            <Box color="good" bold>
                              VALID
                            </Box>
                          ) : (
                            <Box color="bad" bold>
                              MISSING
                            </Box>
                          )}
                        </LabeledList.Item>

                        <LabeledList.Item label="Submission Status">
                          {submitted_report.valid ? (
                            <Box color="good" bold>
                              READY FOR SUBMISSION
                            </Box>
                          ) : (
                            <Box color="bad" bold>
                              REQUIREMENTS NOT MET
                            </Box>
                          )}
                        </LabeledList.Item>
                      </LabeledList>

                      {!submitted_report.valid && (
                        <NoticeBox danger mt={1}>
                          {submitted_report.validation_message ||
                            'Documentation failed verification. Eject the document and review the assignment requirements.'}
                        </NoticeBox>
                      )}

                      {!!submitted_report.valid && (
                        <NoticeBox success mt={1}>
                          Supporting documentation has passed automated
                          validation. {current_order.cooperation_available &&
                          !current_order.assessments_complete
                            ? 'Select a departmental cooperation assessment before completion.'
                            : 'The current tasking order may now be marked complete.'}
                        </NoticeBox>
                      )}
                    </>
                  )}
                </Section>
              </Stack.Item>
            )}
            </div>
          </div>
          )}
          {tab === 'deferred' && (
            <>
          {!on_hold_orders.length && !deferred_orders.length && !queued_incidents.length && !pending_followups.length && (
            <Section title="On-Hold & Deferred Assignments">
              <NoticeBox>No assignments are currently on hold, deferred, or awaiting follow-up.</NoticeBox>
            </Section>
          )}
          {!!on_hold_orders.length && <Stack.Item>
            <Section title={`On-Hold Assignments (${on_hold_orders.length})`}>
              <Box mb={1} color="label">
                Automatically interrupted by higher-priority incident tasking.
                These orders do not expire while suspended and retain their acknowledgment,
                documentation, and cooperation assessment.
              </Box>
              {!on_hold_orders.length ? (
                <NoticeBox>No tasking orders are currently on hold.</NoticeBox>
              ) : on_hold_orders.map((order) => (
                <Section
                  key={order.order_code}
                  title={`${order.order_code} | ${order.subject}`}
                  buttons={
                    <Button
                      icon="play"
                      disabled={read_only || !!current_order || order.order_code !== on_hold_orders[on_hold_orders.length - 1]?.order_code}
                      onClick={() => act('resume_on_hold', { order_code: order.order_code })}
                    >
                      Resume When Available
                    </Button>
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label="Priority">{order.priority}</LabeledList.Item>
                    <LabeledList.Item label="Status">ON HOLD</LabeledList.Item>
                    <LabeledList.Item label="Previously">{order.acknowledged_by ? 'Acknowledged' : 'Pending'}</LabeledList.Item>
                  </LabeledList>
                  <Box mt={1}>{order.instruction}</Box>
                </Section>
              ))}
            </Section>
          </Stack.Item>}
          {(!!queued_incidents.length || !!pending_followups.length) && <Stack.Item>
            {Boolean(queued_incidents.length) && <Section title={`Central Incident Queue (${queued_incidents.length})`}>
              {!queued_incidents.length ? (
                <NoticeBox>No pending incident assignments.</NoticeBox>
              ) : queued_incidents.map((incident, index) => (
                <Section key={`${incident.subject}-${index}`} title={incident.subject}>
                  <Box bold>Priority: {incident.priority}</Box>
                  <Box color="label">{incident.reason}</Box>
                </Section>
              ))}
              <Box color="label" mt={1}>
                Central requests are shared across all three Liaisons. They are not
                additional assignments in your personal inbox.
              </Box>
            </Section>}
            {!!pending_followups.length && <Section title={`My Pending Follow-Ups (${queued_followups})`} mt={1}>
              {!pending_followups.length ? (
                <Box color="label">No scheduled follow-up requests.</Box>
              ) : pending_followups.map((followup) => (
                <Box key={followup.source_order_code} mb={1}>
                  <Box bold>{followup.source_order_code} | {followup.subject}</Box>
                  <Box color="label">
                    {followup.ready_in_seconds > 0
                      ? `Eligible in approximately ${Math.ceil(followup.ready_in_seconds / 60)} minutes, when your inbox is free.`
                      : 'Ready for dispatch when your inbox is free.'}
                  </Box>
                </Box>
              ))}
            </Section>}
          </Stack.Item>}
          {!!deferred_orders.length && <Stack.Item>
            <Section title={`Deferred Orders (${deferred_orders.length}/${max_deferred_orders})`}>
              <Box mb={1} color="label">
                Queued incident assignments: {queued_events} | Pending report
                follow-ups: {queued_followups}
                {queued_events > 0 && (
                  <Box mt={0.5}>
                    Critical: {queued_priorities.Critical || 0} | Priority:{' '}
                    {queued_priorities.Priority || 0} | Elevated:{' '}
                    {queued_priorities.Elevated || 0} | Routine:{' '}
                    {queued_priorities.Routine || 0}
                  </Box>
                )}
                {queued_events > 0 && (
                  <Box mt={1}>
                    {current_order
                      ? 'Queued incidents await an available priority slot; higher-ranked incidents interrupt lower-priority orders.'
                      : queued_events_ready > 0
                        ? 'Queued incident is awaiting prompt dispatch.'
                        : 'Incident remains queued for dispatch.'}
                  </Box>
                )}
              </Box>
              {!deferred_orders.length ? (
                <Box>No deferred orders.</Box>
              ) : deferred_orders.map((order) => (
                <Section
                  key={order.order_code}
                  title={`${order.order_code} | ${order.subject}`}
                  buttons={
                    <Button
                      icon="redo"
                      disabled={!!current_order || (order.resume_in_seconds || 0) > 0}
                      onClick={() => act('resume_deferred', { order_code: order.order_code })}
                    >
                      Resume
                    </Button>
                  }
                >
                  <Box>Reason: {order.deferral_reason || 'Unspecified'}</Box>
                  <Box>Deferred by: {order.deferred_by || 'Unknown'}</Box>
                  <Box>Resume in: {order.resume_in_seconds || 0}s</Box>
                  <Box>Expires in: {order.expires_in_seconds || 0}s{order.deferral_paused ? ' (countdown paused while occupied)' : ''}</Box>
                </Section>
              ))}
            </Section>
          </Stack.Item>}
            </>
          )}
          {tab === 'network' && (
            <Stack.Item>
              <div className="CCPostDispatchStrip">
                <Box bold>Dispatch</Box>
                <Box>Next intake: {dispatch_machine_available ? `${Math.floor(Math.max(0, intake_seconds) / 60)}:${String(Math.floor(Math.max(0, intake_seconds) % 60)).padStart(2, '0')}` : 'Paused'}</Box>
                <Box>Queued: {queued_routine_requests}</Box>
                <Box color="label">{!dispatch_machine_available ? 'Network offline' : dispatch_pending ? `Next attempt: ${Math.floor(Math.max(0, dispatch_seconds) / 60)}:${String(Math.floor(Math.max(0, dispatch_seconds) % 60)).padStart(2, '0')}` : 'Awaiting available Liaisons'}</Box>
                {routine_cooldown_seconds > 0 && <Box color="label">Routine cooldown: {Math.ceil(routine_cooldown_seconds / 60)}m</Box>}
              </div>
              <Section title="Outpost Tasking Network">
                <Box mb={1} color="label">
                  Personal assignments are independently accepted, deferred and
                  completed. Central Command keeps one shared audit record and
                  applies outpost-wide departmental cooldowns.
                </Box>
                <LabeledList>
                  <LabeledList.Item label="Registered terminals">{network_terminals}</LabeledList.Item>
                  <LabeledList.Item label="Personnel inboxes">{network_inboxes}</LabeledList.Item>
                  <LabeledList.Item label="Active assignments">{network_active_tasks}</LabeledList.Item>
                  <LabeledList.Item label="Archived outcomes">{network_completed}</LabeledList.Item>
                  <LabeledList.Item label="Current session">{session_owner}</LabeledList.Item>
                </LabeledList>
              </Section>
              <Collapsible title={`Reassignment Desk (${my_reassignment_offers.length + available_reassignment_offers.length} active offers)`}>
                <Box color="label" mb={1}>
                  Voluntarily offer one of your Routine or Elevated investigations for ten minutes.
                  The task remains yours until another Liaison claims it. Offers can include
                  deferred assignments. Eject any inserted report first; priority emergencies,
                  internal compliance and On Hold work cannot be offered.
                </Box>
                <Section title={`My Reassignment Offers (${my_reassignment_offers.length})`} mt={1}>
                  {!my_reassignment_offers.length ? (
                    <Box color="label">No active transfer offers.</Box>
                  ) : my_reassignment_offers.map((offer) => (
                    <Box key={offer.order_code} mb={1}>
                      <Box bold>{offer.order_code} | {offer.subject}</Box>
                      <Box color="label">
                        {offer.origin} | Offer expires in approximately {Math.ceil((offer.expires_in_seconds || 0) / 60)} minute(s).
                      </Box>
                      <Button
                        icon="times"
                        color="average"
                        disabled={read_only}
                        onClick={() => act('withdraw_reassignment', { order_code: offer.order_code })}
                      >
                        Withdraw Offer
                      </Button>
                    </Box>
                  ))}
                </Section>
                <Section title="Offer One of My Assignments" mt={1}>
                  {!offerableTasks.length ? (
                    <Box color="label">No eligible assignments to offer.</Box>
                  ) : offerableTasks.map((order) => (
                    <Box key={order.order_code} mb={1}>
                      <Box bold>{order.order_code} | {order.subject}</Box>
                      <Box color="label">{order.origin} | {order.priority}</Box>
                      <Button.Confirm
                        icon="share-square"
                        disabled={read_only || my_reassignment_offers.length > 0}
                        confirmContent={`Offer ${order.order_code} to other available Liaisons for ten minutes? Your responsibility remains unchanged until claimed.`}
                        onClick={() => act('offer_reassignment', { order_code: order.order_code })}
                      >
                        Offer for Reassignment
                      </Button.Confirm>
                    </Box>
                  ))}
                </Section>
                <Section title={`Available Reassignments (${available_reassignment_offers.length})`} mt={1}>
                  {!available_reassignment_offers.length ? (
                    <Box color="label">No assignments currently offered by colleagues.</Box>
                  ) : available_reassignment_offers.map((offer) => (
                    <Box key={`${offer.owner_key}-${offer.order_code}`} mb={1}>
                      <Box bold>{offer.order_code} | {offer.subject}</Box>
                      <Box color="label">
                        From {offer.assigned_to} | {offer.origin} | {offer.priority} |
                        {' '}Expires in approximately {Math.ceil((offer.expires_in_seconds || 0) / 60)} minute(s)
                      </Box>
                      <Button.Confirm
                        icon="user-plus"
                        color="good"
                        disabled={!mayClaimTransfer}
                        confirmContent={`Claim ${offer.order_code} from ${offer.assigned_to}? You will take responsibility and receive a printed order copy.`}
                        onClick={() => act('claim_reassignment', { owner_key: offer.owner_key, order_code: offer.order_code })}
                      >
                        Claim Assignment
                      </Button.Confirm>
                    </Box>
                  ))}
                  {!mayClaimTransfer && (
                    <Box color="average">Your Active and Standby slots must both be empty before claiming another Liaison's work.</Box>
                  )}
                </Section>
              </Collapsible>
              <Collapsible title={`Abandoned Work Recovery (${claimable_tasks.length})`}>
                <Box color="label" mb={1}>
                  Assignments become eligible for transfer after their owner is
                  unavailable and has had no authenticated activity for ten minutes.
                  You may claim one only if your own active inbox is empty.
                </Box>
                {!claimable_tasks.length ? (
                  <Box color="label">No eligible outstanding assignments.</Box>
                ) : claimable_tasks.map((task) => (
                  <Section key={task.order_code} title={`${task.order_code} | ${task.subject}`}>
                    <LabeledList>
                      <LabeledList.Item label="Previous owner">{task.assigned_to}</LabeledList.Item>
                      <LabeledList.Item label="Priority">{task.priority}</LabeledList.Item>
                    </LabeledList>
                    <Button.Confirm
                      icon="user-plus"
                      color="average"
                      disabled={Boolean(current_order) || on_hold_orders.length > 0}
                      confirmContent={`Transfer ${task.order_code} into your inbox?`}
                      onClick={() => act('claim_abandoned', { owner_key: task.owner_key, order_code: task.order_code })}
                    >
                      Claim Assignment
                    </Button.Confirm>
                  </Section>
                ))}
              </Collapsible>
            </Stack.Item>
          )}
          {tab === 'archive' && (
            <Stack.Item>
            <Collapsible title="Previous Orders">
              {!history.length ? (
                <NoticeBox>
                  No previous tasking orders have been archived.
                </NoticeBox>
              ) : (
                <Stack vertical>
                  {history.map((order) => (
                    <Stack.Item key={order.order_code}>
                      <Section
                        title={`${order.order_code} | ${order.subject}`}
                        buttons={
                          <>
                            <Button
                              icon="print"
                              onClick={() => act('print_order', { order_code: order.order_code })}
                            >
                              Print Order
                            </Button>
                            {!!(order.archived_paper || order.submitted_report_text) && (
                              <>
                                <Button
                                  icon={
                                    expandedReportCode === order.order_code
                                      ? 'chevron-up'
                                      : 'eye'
                                  }
                                  onClick={() =>
                                    setExpandedReportCode(
                                      expandedReportCode === order.order_code
                                        ? ''
                                        : order.order_code,
                                    )
                                  }
                                >
                                  {expandedReportCode === order.order_code
                                    ? 'Hide Report'
                                    : 'View Report'}
                                </Button>
                                <Button
                                  icon="file-alt"
                                  onClick={() =>
                                    act('print_archived_report', {
                                      order_code: order.order_code,
                                    })
                                  }
                                >
                                  Print Report
                                </Button>
                              </>
                            )}
                          </>
                        }
                      >
                        <LabeledList>
                          <LabeledList.Item label="Status">
                            <Box
                              inline
                              bold
                              color={taskStatusColor(order.status)}
                            >
                              {order.status}
                            </Box>
                          </LabeledList.Item>

                          <LabeledList.Item label="Priority">
                            {order.priority}
                          </LabeledList.Item>

                          <LabeledList.Item label="Category">
                            {order.category}
                          </LabeledList.Item>

                          <LabeledList.Item label="Issued">
                            {order.issued_at}
                          </LabeledList.Item>
                          <LabeledList.Item label="Assigned To">
                            {order.assigned_to || 'Unrecorded'}
                          </LabeledList.Item>
                          {!!order.acknowledged_by && (
                            <LabeledList.Item label="Acknowledged By">
                              {order.acknowledged_by}
                            </LabeledList.Item>
                          )}

                          {!!order.completed_by && (
                            <LabeledList.Item label="Completed By">
                              {order.completed_by}
                            </LabeledList.Item>
                          )}

                          {!!order.completed_at && (
                            <LabeledList.Item label="Completed At">
                              {order.completed_at}
                            </LabeledList.Item>
                          )}
                          {Boolean(order.cooperation_available) && !!order.completed_at &&
                            (order.department_assessments || []).map((grant) => (
                              <LabeledList.Item
                                key={grant.department_id}
                                label={grant.department_name}
                              >
                                {!grant.participated ? (
                                  'Not participating'
                                ) : (
                                  <Box>
                                    <Box>Assessment: <Box inline bold>{grant.rating || 'Not assessed'}</Box></Box>
                                    {!!grant.assessed_by && <Box>Assessing Liaison: {grant.assessed_by}</Box>}
                                    <Box>Authorized Grant: {grant.adjusted_amount ?? 0} credits</Box>
                                    <Box>Financial Outcome: {grant.grant_status || 'Unknown'} ({grant.credited ?? 0} credited)</Box>
                                    <Box>Radio Notice: {grant.radio_status || 'Unknown'}</Box>
                                  </Box>
                                )}
                              </LabeledList.Item>
                            ))}
                        </LabeledList>

                        <Box mt={1}>
                          {order.instruction}
                        </Box>
                        {!!order.audit_events?.length && (
                          <Collapsible title={`Personnel Audit Trail (${order.audit_events.length})`}>
                            {(order.audit_events || []).map((entry, index) => (
                              <Box key={`${order.order_code}-${index}`} mb={0.5}>
                                <Box bold>{entry.action} | {entry.actor}</Box>
                                <Box color="label">{entry.at}{entry.detail ? ` | ${entry.detail}` : ''}</Box>
                              </Box>
                            ))}
                          </Collapsible>
                        )}
                        {!!(order.archived_paper || order.submitted_report_text) &&
                          expandedReportCode === order.order_code && (
                            <Box mt={2} p={2} backgroundColor="#f2efe6" color="#202020">
                            <Box bold>
                              Archived Report: {order.submitted_report_name || 'Untitled'}
                            </Box>
                            <Box color="label" mt={0.5}>
                              CentCom stamp verified: {order.report_stamp_verified ? 'YES' : 'NO'}
                            </Box>
                            <Box
                              mt={1}
                              // The archived original is reconstructed from the same
                              // paper segments and filled fields used by PaperSheet.
                              dangerouslySetInnerHTML={{
                                __html: renderArchivedPaper(order),
                              }}
                            />
                            </Box>
                          )}
                      </Section>
                    </Stack.Item>
                  ))}
                </Stack>
              )}
            </Collapsible>
          </Stack.Item>
          )}
        </Stack>
      
          </Layout.Content>
        </Window.Content>
    </Window>
  );
};

// PaperSheet stores each writing action separately, retaining HTML/Markdown,
// text formatting and the original sequence of [____] editable fields.
// Sanitization must remain the final step before setting innerHTML.
const archivedHtmlEntities: Record<string, string> = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
};

const escapeArchivedText = (text: string) =>
  text.replace(/[&<>"']/g, (character) => archivedHtmlEntities[character] || character);

const renderArchivedPaper = (order: TaskingOrder): string => {
  const snapshot = order.archived_paper;
  if (!snapshot?.raw_text_input?.length) {
    return sanitizeText(
      marked.parse(order.submitted_report_markup ||
        order.submitted_report_text || '', {
        async: false,
        breaks: true,
        gfm: true,
      }) as string,
    );
  }
  const fieldByIndex = new Map<number, ArchivedPaperField>();
  for (const field of snapshot.raw_field_input || []) {
    fieldByIndex.set(Number(field.field_index), field);
  }
  let nextField = 0;
  const contents = snapshot.raw_text_input.map((input) => {
    const withFields = (input.raw_text || '').replace(/\[_+\]/g, (match) => {
      const filled = fieldByIndex.get(nextField++);
      const value = filled?.field_data?.raw_text;
      return value !== undefined && value !== ''
        ? `<u>${escapeArchivedText(value)}</u>`
        : match;
    });
    let segment = marked.parse(withFields, {
      async: false,
      breaks: true,
      gfm: true,
    }) as string;
    if (input.bold) {
      segment = `<b>${segment}</b>`;
    }
    if (input.font || input.color) {
      const face = input.font
        ? ` face="${escapeArchivedText(input.font)}"`
        : '';
      const color = input.color
        ? ` color="${escapeArchivedText(input.color)}"`
        : '';
      segment = `<font${face}${color}>${segment}</font>`;
    }
    return segment;
  }).join('');
  return sanitizeText(contents);
};

const taskStatusColor = (status: string) => {
  switch (status) {
    case 'Completed':
      return 'good';
    case 'Expired':
      return 'bad';
    case 'Deferred':
    case 'On Hold':
      return 'average';

    case 'Acknowledged':
      return 'average';

    case 'Pending':
      return 'label';

    default:
      return 'label';
  }
};
