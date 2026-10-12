import { useBackend } from '../backend';
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
};

type SubmittedReport = {
  name: string;
  has_text: boolean | number;
  has_centcom_stamp: boolean | number;
  valid: boolean | number;
};

type Data = {
  current_order: TaskingOrder | null;
  history: TaskingOrder[];
  submitted_report: SubmittedReport | null;
};

export const CCPostTasking = () => {
  const { act, data } = useBackend<Data>();

  const {
    current_order,
    history = [],
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
                        Submit a separately written report by using the
                        paper on this terminal. The report must contain
                        written findings and bear an official Central
                        Command stamp.
                      </NoticeBox>
                    )}

                  {!!submitted_report && (
                    <>
                      <LabeledList>
                        <LabeledList.Item label="Document">
                          {submitted_report.name}
                        </LabeledList.Item>

                        <LabeledList.Item label="Written Report">
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
                          Supporting documentation does not meet Central
                          Command submission requirements. Eject the
                          document, correct the deficiencies, and
                          resubmit it.
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
                          <Button
                            icon="print"
                            onClick={() =>
                              act('print_order', {
                                order_code: order.order_code,
                              })
                            }
                          >
                            Print Copy
                          </Button>
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

const taskStatusColor = (status: string) => {
  switch (status) {
    case 'Completed':
      return 'good';

    case 'Acknowledged':
      return 'average';

    case 'Pending':
      return 'label';

    default:
      return 'label';
  }
};