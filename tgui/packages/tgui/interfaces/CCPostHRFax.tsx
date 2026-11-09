import { sortBy } from '../../common/collections';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type FaxInfo = {
  fax_name: string;
  fax_id: string;
  visible: boolean;
  has_paper: boolean;
  syndicate_network: boolean;
};

type FaxHistory = {
  history_type: string;
  history_fax_name: string;
  history_time: string;
};

type FaxSpecial = {
  fax_name: string;
  fax_id: string;
  color: string;
  emag_needed: boolean;
};

type HRHistory = {
  reference: string;
  category: string;
  disposition: string;
  closed_at: string;
};

type HRCase = {
  reference: string;
  category: string;
  status: string;
  stage: string;
  can_replace: boolean | number;
  replacements_remaining: number;
};

type HRRecord = {
  name: string;
  role: string;
  paycheck: number;
  promotion_tier: number;
  qualifying_assignments: number;
  next_pay_target: number;
  awards: string[];
  history: HRHistory[];
  active_case: HRCase | null;
};

type Data = {
  faxes?: FaxInfo[];
  fax_id?: string;
  fax_name?: string;
  visible?: boolean | number;
  has_paper?: string;
  syndicate_network?: boolean | number;
  fax_history?: FaxHistory[];
  special_faxes?: FaxSpecial[];
  hr_has_case?: boolean | number;
  hr_personnel_record?: HRRecord | null;
};

/** Full ordinary fax functionality, with a separate private HR records tab. */
export const CCPostHRFax = () => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useLocalState('ccpostHRFaxTab', 'fax');
  const {
    faxes: allFaxes = [],
    fax_id = '',
    fax_name = '',
    visible = false,
    has_paper = '',
    syndicate_network = false,
    fax_history = [],
    special_faxes = [],
    hr_personnel_record: record = null,
  } = data;
  const syndicate = Boolean(syndicate_network);
  const faxes = sortBy((fax: FaxInfo) => fax.fax_name)(
    (allFaxes || []).filter((fax) => fax.visible && (syndicate || !fax.syndicate_network)),
  );
  const special = (special_faxes || []).filter((fax) => syndicate || !fax.emag_needed);
  const hasPaper = Boolean(has_paper);
  const activeCase = record?.active_case;
  const isEmployee = Boolean(record);

  return (
    <Window width={680} height={690} title="Central Command Administrative Fax" theme="ntos">
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Outpost Administrative Fax">
              <Box>
                Official fax correspondence and private Central Command Human
                Resources records. Personnel records are accessible only to the
                employee wearing their own registered outpost identification.
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="fax"
                selected={tab === 'fax'}
                onClick={() => setTab('fax')}
              >
                Fax Operations
              </Tabs.Tab>
              <Tabs.Tab
                icon="id-card"
                selected={tab === 'records'}
                onClick={() => setTab('records')}
              >
                Personnel Records
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          {tab === 'fax' && (
            <>
              <Stack.Item>
                <Section title="Network Identity">
                  <LabeledList>
                    <LabeledList.Item label="Network Name">{fax_name}</LabeledList.Item>
                    <LabeledList.Item label="Network ID">{fax_id}</LabeledList.Item>
                    <LabeledList.Item label="Visible to Network">
                      {Boolean(visible) ? 'Yes' : 'No'}
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Paper Tray"
                  buttons={
                    <Button icon="eject" disabled={!hasPaper} onClick={() => act('remove')}>
                      Remove
                    </Button>
                  }
                >
                  <Box color={hasPaper ? 'good' : 'bad'}>
                    {hasPaper ? 'Paper in tray' : 'No paper inserted'}
                  </Box>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section title="Human Resources Correspondence">
                  <Box mb={1} color="label">
                    HR requests are restricted to authenticated outpost employees.
                    Use a completed HR form in the paper tray to submit a reply.
                  </Box>
                  <Button
                    icon="print"
                    disabled={!isEmployee || Boolean(activeCase)}
                    onClick={() => act('hr_print_intake')}
                  >
                    Print HR-001 Intake
                  </Button>
                  <Button
                    icon="paper-plane"
                    disabled={!isEmployee || !hasPaper}
                    onClick={() => act('hr_send')}
                  >
                    Submit HR Correspondence
                  </Button>
                  <Button.Confirm
                    icon="times-circle"
                    disabled={!isEmployee || !activeCase}
                    confirmContent="Withdraw this active HR case?"
                    onClick={() => act('hr_withdraw')}
                  >
                    Withdraw Case
                  </Button.Confirm>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section title="Send Ordinary Fax">
                  {!faxes.length && !special.length ? (
                    <NoticeBox>No receiving faxes were detected on the network.</NoticeBox>
                  ) : (
                    <Box>
                      {special.map((fax) => (
                        <Button
                          key={fax.fax_id}
                          disabled={!hasPaper}
                          color={fax.color as any}
                          onClick={() => act('send_special', { id: fax.fax_id, name: fax.fax_name })}
                        >
                          {fax.fax_name}
                        </Button>
                      ))}
                      {faxes.map((fax) => (
                        <Button
                          key={fax.fax_id}
                          disabled={!hasPaper}
                          color={fax.syndicate_network ? 'red' : 'blue'}
                          onClick={() => act('send', { id: fax.fax_id, name: fax.fax_name })}
                        >
                          {fax.fax_name}
                        </Button>
                      ))}
                    </Box>
                  )}
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section
                  title="Fax History"
                  buttons={
                    <Button icon="trash" disabled={!fax_history?.length} onClick={() => act('history_clear')}>
                      Clear
                    </Button>
                  }
                >
                  {!fax_history?.length ? (
                    <Box color="label">No fax transmissions logged.</Box>
                  ) : (
                    <Table>
                      {fax_history.map((item, i) => (
                        <Table.Row key={`${item.history_type}-${item.history_time}-${i}`}>
                          <Table.Cell>
                            <Box color={item.history_type === 'Send' ? 'good' : 'average'}>
                              {item.history_type}
                            </Box>
                          </Table.Cell>
                          <Table.Cell>{item.history_fax_name}</Table.Cell>
                          <Table.Cell>{item.history_time}</Table.Cell>
                        </Table.Row>
                      ))}
                    </Table>
                  )}
                </Section>
              </Stack.Item>
            </>
          )}
          {tab === 'records' && (
            !record ? (
              <Stack.Item>
                <NoticeBox>
                  Personnel record access denied. Equip the outpost ID belonging
                  to your registered employee account. Records are not shared
                  with other staff, visitors, or observers.
                </NoticeBox>
              </Stack.Item>
            ) : (
              <>
                <Stack.Item>
                  <Section title="Employee Profile">
                    <LabeledList>
                      <LabeledList.Item label="Employee">{record.name}</LabeledList.Item>
                      <LabeledList.Item label="Assignment">{record.role}</LabeledList.Item>
                      <LabeledList.Item label="Status">Active</LabeledList.Item>
                      <LabeledList.Item label="Pay per Cycle">{record.paycheck} credits</LabeledList.Item>
                      {record.role === 'Central Command Liaison' && (
                        <>
                          <LabeledList.Item label="Salary Tier">{record.promotion_tier}</LabeledList.Item>
                          <LabeledList.Item label="Qualifying Assignments">
                            {record.qualifying_assignments}
                            {record.next_pay_target > 0
                              ? ` / ${record.next_pay_target} for next tier`
                              : ' (maximum tier reached)'}
                          </LabeledList.Item>
                        </>
                      )}
                    </LabeledList>
                  </Section>
                </Stack.Item>
                <Stack.Item>
                  <Section
                    title="Current HR Case"
                    buttons={activeCase && (
                      <Button
                        icon="copy"
                        disabled={!Boolean(activeCase.can_replace)}
                        onClick={() => act('hr_replace_form')}
                      >
                        Replacement Form
                      </Button>
                    )}
                  >
                    {!activeCase ? (
                      <NoticeBox>No active Human Resources case.</NoticeBox>
                    ) : (
                      <LabeledList>
                        <LabeledList.Item label="Reference">{activeCase.reference}</LabeledList.Item>
                        <LabeledList.Item label="Category">{activeCase.category}</LabeledList.Item>
                        <LabeledList.Item label="Status">{activeCase.status}</LabeledList.Item>
                        <LabeledList.Item label="Processing Stage">{activeCase.stage}</LabeledList.Item>
                        <LabeledList.Item label="Remaining Replacements">
                          {activeCase.replacements_remaining}
                        </LabeledList.Item>
                      </LabeledList>
                    )}
                    {activeCase && (
                      <Box mt={1} color="label">
                        A replacement voids the previous response-form token.
                        A newly printed form must be completed and submitted instead.
                      </Box>
                    )}
                  </Section>
                </Stack.Item>
                <Stack.Item>
                  <Section title="Service History & HR Outcomes">
                    {record.awards?.length ? (
                      <Box>Recorded HR outcomes: {record.awards.join(', ')}</Box>
                    ) : (
                      <Box color="label">No recorded employee recognition or corrective outcomes.</Box>
                    )}
                  </Section>
                </Stack.Item>
                <Stack.Item>
                  <Section title={`Closed HR Cases (${record.history?.length || 0})`}>
                    {!record.history?.length ? (
                      <Box color="label">No previous HR cases have been archived.</Box>
                    ) : (
                      <Table>
                        {record.history.map((item, i) => (
                          <Table.Row key={`${item.reference}-${i}`}>
                            <Table.Cell>{item.reference}</Table.Cell>
                            <Table.Cell>{item.category}</Table.Cell>
                            <Table.Cell>{item.disposition}</Table.Cell>
                            <Table.Cell>{item.closed_at}</Table.Cell>
                          </Table.Row>
                        ))}
                      </Table>
                    )}
                  </Section>
                </Stack.Item>
              </>
            )
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
