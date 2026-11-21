import { CCPostHeader, CCPostPersonnelPortrait } from './CCPostTheme';
import { sortBy } from '../../common/collections';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Layout, Window } from '../layouts';

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
  portrait?: string | null;
  role: string;
  paycheck: number;
  promotion_tier: number;
  qualifying_assignments: number;
  freight_inspections?: number;
  freight_discrepancies?: number;
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
  hr_outpost_offline?: boolean | number;
  hr_has_case?: boolean | number;
  hr_personnel_record?: HRRecord | null;
};

/** Full ordinary fax functionality, with a separate private HR records tab. */
export const CCPostHRFax = () => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useLocalState('ccpostHRFaxTab', 'fax');
  const [recipientSearch, setRecipientSearch] = useLocalState('ccpostFaxRecipientSearch', '');
  const {
    faxes: allFaxes = [],
    fax_id = '',
    fax_name = '',
    visible = false,
    has_paper = '',
    syndicate_network = false,
    fax_history = [],
    special_faxes = [],
    hr_outpost_offline = false,
    hr_personnel_record: record = null,
  } = data;
  const syndicate = Boolean(syndicate_network);
  const faxes = sortBy((fax: FaxInfo) => fax.fax_name)(
    (allFaxes || []).filter((fax) => fax.visible && (syndicate || !fax.syndicate_network)),
  );
  const special = (special_faxes || []).filter((fax) => syndicate || !fax.emag_needed);
  const query = recipientSearch.trim().toLowerCase();
  const visibleRecipients = query ? faxes.filter((fax) => fax.fax_name.toLowerCase().includes(query) || fax.fax_id.toLowerCase().includes(query)) : faxes;
  const visibleSpecial = query ? special.filter((fax) => fax.fax_name.toLowerCase().includes(query)) : special;
  const hasPaper = Boolean(has_paper);
  const activeCase = record?.active_case;
  const isEmployee = Boolean(record);

  if (hr_outpost_offline) {
    return (
      <Window title="Central Command Administrative Fax" width={610} height={320} theme="ntos">
        <Window.Content className="ccpost-theme ccpost-theme--sage ccpost-admin-v2">
          <CCPostHeader title="Administrative Fax & Personnel" division="CENTRAL COMMAND" />
          <Layout.Content scrollable className="CCPostAdminBody">
          <NoticeBox danger>INSTALLATION OFFLINE. Administrative fax services and HR records are unavailable after loss of the Liaison Outpost.</NoticeBox>
          <Section title="Physical Paper Tray">
            <Box mb={1}>{hasPaper ? 'Inserted paper can be recovered manually.' : 'No paper inserted.'}</Box>
            <Button icon="eject" disabled={!hasPaper} onClick={() => act('remove')}>Remove Paper</Button>
          </Section>
        
          </Layout.Content>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={680} height={690} title="Central Command Administrative Fax" theme="ntos">
      <Window.Content className="ccpost-theme ccpost-theme--sage ccpost-admin-v2">
          <CCPostHeader title="Administrative Fax & Personnel" division="CENTRAL COMMAND" />
          <div className="CCPostAdminNav"><Tabs fluid>
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
              <Tabs.Tab
                icon="history"
                selected={tab === 'history'}
                onClick={() => setTab('history')}
              >
                Fax History ({fax_history.length})
              </Tabs.Tab>
            </Tabs></div>
          <Layout.Content scrollable className="CCPostAdminBody">
        <Stack vertical>
          <Stack.Item>
            <div className="CCPostWorkspaceToolbar"><div><strong>Administrative Correspondence</strong><span>Personnel records require your registered outpost identification.</span></div></div>
          </Stack.Item>
          
          {tab === 'fax' && (
            <>
              <Stack.Item>
                <Section title="Network Identity">
                  <LabeledList>
                    <LabeledList.Item label="Network Name">{fax_name}</LabeledList.Item>
                    <LabeledList.Item label="Network ID">{fax_id}</LabeledList.Item>
                    <LabeledList.Item label="Visible to Network">
                      {visible ? 'Yes' : 'No'}
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
                    tooltip={!isEmployee ? 'Registered outpost ID required.' : activeCase ? 'Close or withdraw your current HR case before printing a new intake form.' : 'Print a new HR-001 Intake form.'}
                    disabled={!isEmployee || Boolean(activeCase)}
                    onClick={() => act('hr_print_intake')}
                  >
                    Print HR-001 Intake
                  </Button>
                  <Button
                    icon="paper-plane"
                    tooltip={!isEmployee ? 'Registered outpost ID required.' : !hasPaper ? 'Insert the completed HR document first.' : 'Submit the completed HR document.'}
                    disabled={!isEmployee || !hasPaper}
                    onClick={() => act('hr_send')}
                  >
                    Submit HR Correspondence
                  </Button>
                  <Button.Confirm
                    icon="times-circle"
                    tooltip={!activeCase ? 'No active HR case to withdraw.' : 'Withdraw the current HR case.'}
                    disabled={!isEmployee || !activeCase}
                    confirmContent="Withdraw this active HR case?"
                    onClick={() => act('hr_withdraw')}
                  >
                    Withdraw Case
                  </Button.Confirm>
                </Section>
              </Stack.Item>
              <Stack.Item>
                <Section title="Recipient Directory">
                  <div className="CCPostFaxDirectory__head">
                    <Input placeholder="Search fax recipients" value={recipientSearch} onChange={setRecipientSearch} width="230px" />
                    <Box color="label">{visibleRecipients.length + visibleSpecial.length} destinations</Box>
                  </div>
                  {!hasPaper && <Box color="label" mb={1}>Insert a document into the paper tray to enable transmission.</Box>}
                  {!visibleRecipients.length && !visibleSpecial.length ? (
                    <NoticeBox>{query ? 'No recipients match this search.' : 'No receiving faxes were detected on the network.'}</NoticeBox>
                  ) : (
                    <>
                      {!!visibleSpecial.length && <Box bold mb={1}>Special Recipients</Box>}
                      <div className="CCPostFaxDirectory">
                        {visibleSpecial.map((fax) => (
                          <Button key={fax.fax_id} fluid disabled={!hasPaper} color={fax.color as any}
                            tooltip={!hasPaper ? 'Insert a paper document first.' : undefined}
                            onClick={() => act('send_special', { id: fax.fax_id, name: fax.fax_name })}>
                            {fax.fax_name}
                          </Button>
                        ))}
                      </div>
                      {!!visibleRecipients.length && <Box bold mb={1} mt={1}>Network Recipients</Box>}
                      <div className="CCPostFaxDirectory">
                        {visibleRecipients.map((fax) => (
                          <Button key={fax.fax_id} fluid disabled={!hasPaper} color={fax.syndicate_network ? 'red' : 'blue'}
                            tooltip={!hasPaper ? 'Insert a paper document first.' : undefined}
                            onClick={() => act('send', { id: fax.fax_id, name: fax.fax_name })}>
                            {fax.fax_name}
                          </Button>
                        ))}
                      </div>
                    </>
                  )}
                </Section>
              </Stack.Item>
            </>
          )}
          {tab === 'history' && (
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
                    <div className="CCPostIdentityStrip"><CCPostPersonnelPortrait portrait={record.portrait} label="PERSONNEL RECORD" /><div><strong>{record.name}</strong><div>{record.role}</div><div className="CCPostIdentityStrip__meta">CENTRAL COMMAND / ACTIVE FILE</div></div></div>
                    <LabeledList>
                      <LabeledList.Item label="Employee">{record.name}</LabeledList.Item>
                      <LabeledList.Item label="Assignment">{record.role}</LabeledList.Item>
                      <LabeledList.Item label="Status">Active</LabeledList.Item>
                      <LabeledList.Item label="Pay per Cycle">{record.paycheck} credits</LabeledList.Item>
                      {record.role === 'Outpost Security Officer' && (<>
                          <LabeledList.Item label="Freight clearances">{record.freight_inspections ?? 0}</LabeledList.Item>
                          <LabeledList.Item label="Discrepancies resolved">{record.freight_discrepancies ?? 0}</LabeledList.Item>
                        </>)}
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
                  <details className="CCPostUtilityDisclosure" open={Boolean(activeCase)}><summary>Current HR Case{activeCase ? ` · ${activeCase.reference} · ${activeCase.status}` : ""}</summary>
                  <Section
                    title="Current HR Case"
                    buttons={activeCase && (
                      <Button
                        icon="copy"
                        disabled={!activeCase.can_replace}
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
                  </Section></details>
                </Stack.Item>
                <Stack.Item>
                  <details className="CCPostUtilityDisclosure"><summary>Service History &amp; HR Outcomes</summary>
                  <Section>
                    {record.awards?.length ? (
                      <Box>Recorded HR outcomes: {record.awards.join(', ')}</Box>
                    ) : (
                      <Box color="label">No recorded employee recognition or corrective outcomes.</Box>
                    )}
                  </Section></details>
                </Stack.Item>
                <Stack.Item>
                  <details className="CCPostUtilityDisclosure"><summary>Closed HR Cases ({record.history?.length || 0})</summary>
                  <Section>
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
                  </Section></details>
                </Stack.Item>
              </>
            )
          )}
        </Stack>
      
          </Layout.Content>
        </Window.Content>
    </Window>
  );
};
