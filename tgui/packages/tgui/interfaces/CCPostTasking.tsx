import { marked } from 'marked';
import { sanitizeText } from '../sanitize';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

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
};

type Data = {
  authenticated?: boolean;
  identity_detected?: boolean;
  session_owner?: string;
  network_terminals?: number;
  network_inboxes?: number;
  network_active_tasks?: number;
  network_completed?: number;
  claimable_tasks?: ReassignableTask[];
  current_order: TaskingOrder | null;
  history: TaskingOrder[];
  deferred_orders: TaskingOrder[];
  on_hold_orders: TaskingOrder[];
  queued_incidents: { subject: string; priority: string; reason: string }[];
  read_only?: boolean;
  queued_events: number;
  queued_priorities?: Record<string, number>;
  queued_events_ready: number;
  queued_followups: number;
  dispatch_seconds?: number;
  dispatch_pending?: boolean | number;
  dispatch_machine_available?: boolean | number;
  submitted_report: SubmittedReport | null;
};

// Color only the monetary outcome. The remainder of the interface retains
// NTOS styling, and zero-credit outcomes are not presented as successes.
const departmentGrantColors: Record<string, string> = {
  'Very Dissatisfied': '#EF4444',
  Dissatisfied: '#F59E0B',
  Neutral: '#FACC15',
  Satisfied: '#4ADE80',
  'Very Satisfied': '#7DD3FC',
};

export const CCPostTasking = () => {
  const { act, data } = useBackend<Data>();
  const [helpOpen, setHelpOpen] = useLocalState('ccpostTaskHelp', false);
  const [tab, setTab] = useLocalState('ccpostTaskMainTab', 'active');
  const [deferOpen, setDeferOpen] = useLocalState('ccpostTaskDefer', false);
  const [expandedReportCode, setExpandedReportCode] = useLocalState(
    'ccpostTaskExpandedReportCode',
    '',
  );

  const {
    current_order,
    history = [],
    deferred_orders = [],
    on_hold_orders = [],
    queued_incidents = [],
    read_only = false,
    queued_events = 0,
    queued_priorities = {},
    queued_events_ready = 0,
    queued_followups = 0,
    dispatch_seconds = 0,
    dispatch_pending = false,
    dispatch_machine_available = true,
    submitted_report,
    authenticated = false,
    identity_detected = false,
    session_owner = '',
    network_terminals = 0,
    network_inboxes = 0,
    network_active_tasks = 0,
    network_completed = 0,
    claimable_tasks = [],
  } = data;

  if (!authenticated) {
    return (
      <Window title="Central Command Tasking | Sign In" width={570} height={385} theme="ntos">
        <Window.Content>
          <Stack vertical fill>
            <Stack.Item>
              <Section title="NANOTRASEN | CENTRAL COMMAND">
                <Box bold>Personnel Tasking &amp; Administrative Oversight Network</Box>
                <Box mt={1} color="label">
                  All terminals share one administrative archive. Individual assignments
                  are issued to registered Liaisons and follow their personnel identity,
                  not the desk or circuit board.
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Authorized Personnel Sign-In">
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
                <Button
                  mt={1.5}
                  fluid
                  icon="sign-in-alt"
                  color="good"
                  disabled={!identity_detected || read_only}
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
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      title="Central Command Tasking"
      width={700}
      height={700}
      theme="ntos"
    >
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section
              title={`Central Command Tasking | ${session_owner}`}
              buttons={
                <>
                  <Button icon="question-circle" onClick={() => setHelpOpen(!helpOpen)}>
                    {helpOpen ? 'Close Manual' : 'Operating Manual'}
                  </Button>
                  {!read_only && (
                    <Button icon="sign-out-alt" color="average" onClick={() => act('logout')}>
                      Sign Out
                    </Button>
                  )}
                </>
              }
            >
              {helpOpen && (
                <Box>
                  <Box bold>CENTRAL COMMAND ASSIGNMENT PROCEDURES</Box>
                  <Box mt={1}>
                    Upon receipt of an authorized tasking order, record
                    acknowledgment and undertake the specified investigation.
                    Findings must distinguish verified information from
                    uncorroborated statements. Prepare a separate written report,
                    apply the Central Command seal, and deposit the document
                    before requesting final acceptance. The order itself does
                    not constitute completion evidence.
                  </Box>
                  <Box mt={1}>
                    Installation record certification requires the original
                    system-generated record from the Remote Oversight Network,
                    authenticated by a Liaison stamp. Ordinary transcripts or
                    handwritten substitutes do not satisfy this directive.
                  </Box>
                  <Box mt={1}>
                    Manually deferred orders remain subject to their deadlines.
                    Incident-suspended assignments retain their progress and do
                    not expire while on hold.
                    Completed assignments and the verification status of their
                    submitted evidence are retained in the official archive.
                    Sector Communications handles regional correspondence;
                    Logistics maintains the Operational Allocation ledger.
                  </Box>
                  <Box mt={1} color="label">
                    RECORDS ADMINISTRATION NOTICE: Archived copies do not
                    reproduce original physical stamp authorization.
                  </Box>
                </Box>
              )}
            </Section>
          </Stack.Item>
          {Boolean(read_only) && (
            <Stack.Item>
              <NoticeBox>OBSERVER MODE: Terminal contents are available for viewing only. All operational actions remain restricted.</NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab icon="clipboard-list" selected={tab === 'active'} onClick={() => setTab('active')}>
                My Tasks
              </Tabs.Tab>
              <Tabs.Tab icon="pause" selected={tab === 'deferred'} onClick={() => setTab('deferred')}>
                On-Hold &amp; Deferred ({on_hold_orders.length + deferred_orders.length + queued_events})
              </Tabs.Tab>
              <Tabs.Tab icon="archive" selected={tab === 'archive'} onClick={() => setTab('archive')}>
                Shared History ({history.length})
              </Tabs.Tab>
              <Tabs.Tab icon="sitemap" selected={tab === 'network'} onClick={() => setTab('network')}>
                Network
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {tab === 'active' && (
            <>
          <Stack.Item>
            <Section title="Routine Dispatch Status">
              <Box color="label">
                {!Boolean(dispatch_machine_available)
                  ? 'Dispatch paused: Terminal offline or damaged.'
                  : Boolean(dispatch_pending)
                    ? `Next scheduler attempt in approximately ${dispatch_seconds}s. Urgent incidents may arrive earlier; ongoing assignments can delay routine dispatch.`
                    : 'No scheduled routine dispatch. The scheduler will resume when operational.'}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Collapsible title="Printable Administrative Templates">
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
            </Collapsible>
          </Stack.Item>
          <Stack.Item>
            {!current_order ? (
              <Section title="Current Tasking Order">
                <NoticeBox>
                  No active Central Command tasking order.
                </NoticeBox>
              </Section>
            ) : (
              <Section
                title={`Current Tasking Order | ${current_order.order_code}`}
                buttons={
                  <>
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
                          deferred_orders.length >= 1
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
                            !Boolean(current_order.assessments_complete))
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
                  </>
                }
              >
                {deferOpen && (
                  <Section title="Temporarily defer this assignment">
                    <Box mb={1}>
                      Select a reason. The order becomes eligible to resume after
                      five minutes and expires after 25 minutes. At most one
                      order can be deferred, each at most twice. Expiry is paused
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
                <LabeledList>
                  <LabeledList.Item label="Status">
                    <Box
                      inline
                      bold
                      color={taskStatusColor(current_order.status)}
                    >
                      {current_order.status}
                    </Box>
                  </LabeledList.Item>

                  <LabeledList.Item label="Priority">
                    {current_order.priority}
                  </LabeledList.Item>

                  <LabeledList.Item label="Category">
                    {current_order.category}
                  </LabeledList.Item>

                  <LabeledList.Item label="Subject">
                    {current_order.subject}
                  </LabeledList.Item>

                  <LabeledList.Item label="Issued">
                    {current_order.issued_at}
                  </LabeledList.Item>
                  <LabeledList.Item label="Assigned To">
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

                <Box mt={2}>
                  <Box bold mb={1}>
                    Directive
                  </Box>

                  {current_order.instruction}
                </Box>
                {Boolean(current_order.cooperation_available) && (
                  <Section title="Department Cooperation Assessments" mt={2}>
                    <Box mb={1}>
                      Assess participating departments independently. Each
                      assessment affects only that department's credit grant,
                      not the Liaison's Operational Allocation reward.
                    </Box>
                    {(current_order.department_assessments || []).map((grant) => (
                      <Section
                        key={grant.department_id}
                        title={`Department Cooperation Assessment: ${grant.department_name}`}
                        mt={1}
                        buttons={
                          !Boolean(grant.required) ? (
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
                        {Boolean(grant.participated) ? (
                          <>
                            {[
                              'Very Dissatisfied',
                              'Dissatisfied',
                              'Neutral',
                              'Satisfied',
                              'Very Satisfied',
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
                            <Box mt={1} p={1.5} backgroundColor="#1e2d3f">
                              <Box bold>
                                Selected assessment: {grant.rating || 'Not yet assessed'}
                              </Box>
                              <Box
                                bold
                                color={departmentGrantColors[grant.rating || ''] || 'label'}
                                fontSize="18px"
                                mt={0.5}
                              >
                                {grant.adjusted_amount === null || grant.adjusted_amount === undefined
                                  ? 'Select an assessment to calculate the grant'
                                  : `${grant.adjusted_amount} credits`}
                              </Box>
                            </Box>
                            <Box color="label" mt={0.5}>
                              {`The selected assessment and resulting departmental grant will be transmitted over the ${grant.department_name} radio channel.`}
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
                          {!!submitted_report.has_text ? (
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
                          {!!submitted_report.has_centcom_stamp ? (
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
                          {!!submitted_report.valid ? (
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
                          validation. {Boolean(current_order.cooperation_available) &&
                          !Boolean(current_order.assessments_complete)
                            ? 'Select a departmental cooperation assessment before completion.'
                            : 'The current tasking order may now be marked complete.'}
                        </NoticeBox>
                      )}
                    </>
                  )}
                </Section>
              </Stack.Item>
            )}

            </>
          )}
          {tab === 'deferred' && (
            <>
          <Stack.Item>
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
                      disabled={read_only || !!current_order || queued_events > 0 || order.order_code !== on_hold_orders[on_hold_orders.length - 1]?.order_code}
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
          </Stack.Item>
          <Stack.Item>
            <Section title={`Queued Incident Orders (${queued_incidents.length})`}>
              {!queued_incidents.length ? (
                <NoticeBox>No pending incident assignments.</NoticeBox>
              ) : queued_incidents.map((incident, index) => (
                <Section key={`${incident.subject}-${index}`} title={incident.subject}>
                  <Box bold>Priority: {incident.priority}</Box>
                  <Box color="label">{incident.reason}</Box>
                </Section>
              ))}
              <Box color="label" mt={1}>
                Pending report follow-ups: {queued_followups}
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title={`Deferred Orders (${deferred_orders.length})`}>
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
                  <Box>Expires in: {order.expires_in_seconds || 0}s</Box>
                </Section>
              ))}
            </Section>
          </Stack.Item>
            </>
          )}
          {tab === 'network' && (
            <Stack.Item>
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
              <Section title={`Abandoned Work Recovery (${claimable_tasks.length})`} mt={1}>
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
              </Section>
            </Stack.Item>
          )}
          {tab === 'archive' && (
            <>
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
                                {!Boolean(grant.participated) ? (
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
            </>
          )}
        </Stack>
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