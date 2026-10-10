import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  Section,
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
  acknowledged_by: string | null;
  acknowledged_at: string | null;
  completed_by: string | null;
  completed_at: string | null;
};

type Data = {
  current_order: TaskingOrder | null;
  history: TaskingOrder[];
};

const getStatusColor = (status: string) => {
  switch (status) {
    case 'Completed':
      return 'good';

    case 'Acknowledged':
      return 'average';

    default:
      return 'bad';
  }
};

export const CCPostTasking = (props) => {
  const { act, data } = useBackend<Data>();

  const { current_order, history = [] } = data;

  return (
    <Window
      theme="ntos"
      title="Central Command Tasking Network"
      width={600}
      height={650}
    >
      <Window.Content scrollable>
        <NoticeBox>
          SECURE CENTRAL COMMAND LINK: ACTIVE
        </NoticeBox>

        {current_order ? (
          <Section title="Active Tasking Order">
            <LabeledList>
              <LabeledList.Item label="Order">
                {current_order.order_code}
              </LabeledList.Item>

              <LabeledList.Item label="Category">
                {current_order.category}
              </LabeledList.Item>

              <LabeledList.Item label="Subject">
                {current_order.subject}
              </LabeledList.Item>

              <LabeledList.Item label="Priority">
                {current_order.priority}
              </LabeledList.Item>

              <LabeledList.Item label="Issued">
                {current_order.issued_at}
              </LabeledList.Item>

              <LabeledList.Item label="Status">
                <Box color={getStatusColor(current_order.status)}>
                  {current_order.status}
                </Box>
              </LabeledList.Item>
            </LabeledList>

            <Section title="Instructions" mt={1}>
              <Box>
                {current_order.instruction}
              </Box>
            </Section>

            {current_order.acknowledged_by && (
              <Box mt={1}>
                <b>Acknowledged by:</b>{' '}
                {current_order.acknowledged_by} at{' '}
                {current_order.acknowledged_at}
              </Box>
            )}

            {current_order.completed_by && (
              <Box mt={1}>
                <b>Completed by:</b>{' '}
                {current_order.completed_by} at{' '}
                {current_order.completed_at}
              </Box>
            )}

            <Box mt={2}>
              <Button
                icon="clipboard-check"
                disabled={current_order.status !== 'Pending'}
                onClick={() => act('acknowledge')}
              >
                Acknowledge Order
              </Button>

              <Button
                icon="check"
                color="good"
                disabled={current_order.status !== 'Acknowledged'}
                onClick={() => act('complete')}
              >
                Mark Complete
              </Button>

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
            </Box>
          </Section>
        ) : (
          <NoticeBox>
            No active Central Command tasking orders.
          </NoticeBox>
        )}

        <Collapsible
          title={`Previous Orders (${history.length})`}
        >
          {history.length ? (
            history.map((order) => (
              <Section
                key={order.order_code}
                title={`${order.order_code} - ${order.subject}`}
              >
                <LabeledList>
                  <LabeledList.Item label="Category">
                    {order.category}
                  </LabeledList.Item>

                  <LabeledList.Item label="Priority">
                    {order.priority}
                  </LabeledList.Item>

                  <LabeledList.Item label="Issued">
                    {order.issued_at}
                  </LabeledList.Item>

                  <LabeledList.Item label="Status">
                    <Box color={getStatusColor(order.status)}>
                      {order.status}
                    </Box>
                  </LabeledList.Item>
                </LabeledList>

                <Box mt={1}>
                  {order.instruction}
                </Box>

                {order.acknowledged_by && (
                  <Box mt={1}>
                    <b>Acknowledged by:</b>{' '}
                    {order.acknowledged_by} at{' '}
                    {order.acknowledged_at}
                  </Box>
                )}

                {order.completed_by && (
                  <Box mt={1}>
                    <b>Completed by:</b>{' '}
                    {order.completed_by} at{' '}
                    {order.completed_at}
                  </Box>
                )}

                <Button
                  mt={1}
                  icon="print"
                  onClick={() =>
                    act('print_order', {
                      order_code: order.order_code,
                    })
                  }
                >
                  Print Copy
                </Button>
              </Section>
            ))
          ) : (
            <Box>
              No archived tasking orders.
            </Box>
          )}
        </Collapsible>
      </Window.Content>
    </Window>
  );
};