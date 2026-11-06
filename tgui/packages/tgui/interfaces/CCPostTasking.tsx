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
  submission_type?: string;
  target_installation_code?: string;
  submitted_report_name?: string;
  submitted_report_text?: string;
  submitted_report_markup?: string;
  archived_paper?: ArchivedPaper | null;
  report_stamp_verified?: boolean;
  source_order_code?: string;
  assigned_contact?: string;
  assigned_role?: string;
  deferral_count?: number;
  deferral_reason?: string;
  deferred_by?: string;
  resume_in_seconds?: number;
  expires_in_seconds?: number;
};

type SubmittedReport = {
  name: string;
  has_text: boolean | number;
  has_centcom_stamp: boolean | number;
  record_installation_code?: string | null;
  validation_message?: string | null;
  valid: boolean | number;
};

type Data = {
  current_order: TaskingOrder | null;
  history: TaskingOrder[];
  deferred_orders: TaskingOrder[];
  queued_events: number;
  queued_priorities?: Record<string, number>;
  queued_events_ready: number;
  queued_followups: number;
  submitted_report: SubmittedReport | null;
};

export const CCPostTasking = () => {
  const { act, data } = useBackend<Data>();
  const [helpOpen, setHelpOpen] = useLocalState('ccpostTaskHelp', false);
  const [deferOpen, setDeferOpen] = useLocalState('ccpostTaskDefer', false);
  const [expandedReportCode, setExpandedReportCode] = useLocalState(
    'ccpostTaskExpandedReportCode',
    '',
  );

  const {
    current_order,
    history = [],
    deferred_orders = [],
    queued_events = 0,
    queued_priorities = {},
    queued_events_ready = 0,
    queued_followups = 0,
    submitted_report,
  } = data;

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
              title="Central Command Tasking | Operating Manual"
              buttons={
                <Button icon="question-circle" onClick={() => setHelpOpen(!helpOpen)}>
                  {helpOpen ? 'Close Manual' : 'Operating Manual'}
                </Button>
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
                    Deferred orders remain subject to their deadlines.
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
                          deferred_orders.length >= 2
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
                          !submitted_report.valid
                        }
                        onClick={() => act('complete')}
                      >
                        Mark Complete
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
                      five minutes and expires after 25 minutes. At most two
                      orders can be deferred, each at most twice. Compliance and
                      Critical orders cannot be deferred.
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
                          validation. The current tasking order may now
                          be marked complete.
                        </NoticeBox>
                      )}
                    </>
                  )}
                </Section>
              </Stack.Item>
            )}

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
                      ? 'Incident tasking is queued until the current order is completed or deferred.'
                      : queued_events_ready > 0
                        ? 'Incident tasking is ready and will be issued at the next assignment cycle.'
                        : 'Incident tasking awaits available personnel in the relevant station department.'}
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
                        </LabeledList>

                        <Box mt={1}>
                          {order.instruction}
                        </Box>
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
      return 'average';

    case 'Acknowledged':
      return 'average';

    case 'Pending':
      return 'label';

    default:
      return 'label';
  }
};