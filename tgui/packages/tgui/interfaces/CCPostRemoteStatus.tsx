import { useBackend, useLocalState, useSharedState } from '../backend';
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

type CommandEntry = {
  role: string;
  name: string;
};

type ShuttleData = {
  status: string;
  timer: number;
};

type SectorNotice = {
  notice_code: string;
  category: string;
  source: string;
  priority: string;
  title: string;
  body: string;
  issued_at: string;
  has_operational_effect: boolean;
  operational_effect_active: boolean;
  operational_effect_seconds: number;
  operational_effect_summary?: string;
};

type InstallationHistoryEntry = {
  timestamp: string;
  category: string;
  title: string;
  details: string;
};

type SectorInstallation = {
  code: string;
  name: string;
  function: string;
  regional_dependency: string;
  last_authenticated_contact: string;
  last_contact_seconds_ago: number;
  loss_consequence?: string;
  contact_name: string;
  contact_role: string;
  status: string;
  status_since: string;
  condition: string;
  telemetry: string;
  condition_details: string;
  incident_summary: string;
  response_status: string;
  ert_dispatched: boolean;
  destroyed: boolean;
  trust_label: string;
  followup_active: boolean;
  followup_subject?: string;
  followup_status: string;
  history: InstallationHistoryEntry[];
};

type Data = {
  station_name: string;
  alert_level: string;
  registered_crew: number;
  last_update: string;
  command_roster: CommandEntry[];
  shuttle: ShuttleData;
  sector_notices: SectorNotice[];
  sector_installations: SectorInstallation[];
};

const formatTimer = (seconds: number) => {
  const remaining = Math.max(0, Math.floor(seconds));
  const minutes = Math.floor(remaining / 60);
  const secs = remaining % 60;

  return `${minutes}:${secs < 10 ? '0' : ''}${secs}`;
};

const formatNoticeDuration = (totalSeconds: number) => {
  const seconds = Math.max(0, Math.floor(totalSeconds || 0));
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;

  if (!minutes) {
    return `${remainingSeconds}s`;
  }

  return `${minutes}m ${remainingSeconds}s`;
};

const formatRelativeContact = (secondsAgo: number) => {
  const seconds = Math.max(0, Math.floor(secondsAgo || 0));

  if (seconds < 15) {
    return 'just now';
  }

  if (seconds < 60) {
    return `${seconds}s ago`;
  }

  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) {
    return `${minutes}m ago`;
  }

  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  return remainingMinutes ? `${hours}h ${remainingMinutes}m ago` : `${hours}h ago`;
};

const installationAttentionRank = (installation: SectorInstallation) => {
  if (installation.destroyed) {
    return 0;
  }

  switch (installation.status) {
    case 'CRITICAL':
      return 1;
    case 'NO CONTACT':
    case 'OFFLINE':
      return 2;
    case 'COMMUNICATIONS DEGRADED':
      return 3;
    case 'UNDER REVIEW':
    case 'MAINTENANCE':
      return 4;
    default:
      return 5;
  }
};

const getAlertColor = (alertLevel: string) => {
  switch (alertLevel.toLowerCase()) {
    case 'green':
      return 'good';
    case 'blue':
      return 'blue';
    case 'yellow':
      return 'average';
    case 'amber':
      return 'orange';
    case 'red':
    case 'delta':
    case 'gamma':
    case 'epsilon':
    case 'lambda':
      return 'bad';
    default:
      return 'label';
  }
};

const getNoticeColor = (priority: string) => {
  switch (priority.toLowerCase()) {
    case 'important':
      return 'bad';
    case 'advisory':
      return 'average';
    default:
      return 'label';
  }
};

const getInstallationColor = (status: string) => {
  switch (status) {
    case 'ONLINE':
    case 'ROUTINE OPERATIONS':
      return 'good';

    case 'MAINTENANCE':
    case 'UNDER REVIEW':
      return 'average';

    case 'COMMUNICATIONS DEGRADED':
      return 'orange';

    case 'NO CONTACT':
    case 'OFFLINE':
    case 'CRITICAL':
      return 'bad';

    default:
      return 'label';
  }
};

const getConditionColor = (condition: string) => {
  switch (condition) {
    case 'OPERATIONAL':
      return 'good';

    case 'DEGRADED':
    case 'UNKNOWN':
      return 'orange';

    case 'NON-OPERATIONAL':
    case 'CRITICAL':
    case 'DESTROYED':
      return 'bad';

    default:
      return 'label';
  }
};

const getTelemetryColor = (telemetry: string) => {
  switch (telemetry) {
    case 'ACTIVE':
      return 'good';

    case 'DEGRADED':
      return 'orange';

    case 'SIGNAL LOST':
    case 'INACTIVE':
    case 'EMERGENCY':
    case 'TERMINATED':
      return 'bad';

    default:
      return 'label';
  }
};

const getRelationshipColor = (relationship: string) => {
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

const getResponseColor = (response: string) => {
  switch (response) {
    case 'ERT OPERATION COMPLETE':
    case 'INCIDENT STABILIZED':
    case 'ERT + LIAISON RECOVERY':
    case 'ERT RECOVERY / AID DENIED':
    case 'LIAISON-SUPPORTED RECOVERY':
    case 'RECOVERY DESPITE AID DENIAL':
      return 'good';

    case 'ERT DISPATCHED':
    case 'NO ERT DISPATCHED':
    case 'ERT + LIAISON AID':
    case 'LIAISON AID AUTHORIZED':
      return 'average';

    case 'ERT OPERATION FAILED':
    case 'INSTALLATION LOST':
    case 'ERT + AID FAILED':
    case 'ERT FAILED / AID DENIED':
    case 'LIAISON AID INSUFFICIENT':
    case 'AID DENIED / INSTALLATION LOST':
      return 'bad';

    default:
      return 'label';
  }
};

export const CCPostRemoteStatus = () => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useSharedState('tab', 'station');

  const {
    station_name,
    alert_level,
    registered_crew,
    last_update,
    command_roster,
    shuttle,
    sector_notices,
    sector_installations,
  } = data;

  const operationalInstallations = sector_installations.filter(
    (installation) =>
      installation.status === 'ONLINE' ||
      installation.status === 'ROUTINE OPERATIONS',
  ).length;

  const criticalInstallations = sector_installations.filter(
    (installation) => installation.status === 'CRITICAL',
  ).length;

  const destroyedInstallations = sector_installations.filter(
    (installation) => installation.destroyed,
  ).length;

  const [selectedRecordInstallation, setSelectedRecordInstallation] =
    useLocalState('recordInstallation', sector_installations[0]?.code || '');
  const activeRecordInstallation =
    sector_installations.find(
      (installation) => installation.code === selectedRecordInstallation,
    ) || sector_installations[0];
  const activeRecordCode = activeRecordInstallation?.code || '';

  const [noticeCategoryFilter, setNoticeCategoryFilter] = useLocalState(
    'noticeCategoryFilter',
    'ALL',
  );
  const [noticePriorityFilter, setNoticePriorityFilter] = useLocalState(
    'noticePriorityFilter',
    'ALL',
  );
  const [noticeSourceFilter, setNoticeSourceFilter] = useLocalState(
    'noticeSourceFilter',
    'ALL',
  );
  const [noticeImpactFilter, setNoticeImpactFilter] = useLocalState(
    'noticeImpactFilter',
    'ALL',
  );
  const [installationView, setInstallationView] = useLocalState(
    'installationView',
    'ALL',
  );

  const noticeCategories = Array.from(
    new Set(sector_notices.map((notice) => notice.category)),
  ).sort();
  const noticeSources = Array.from(
    new Set(sector_notices.map((notice) => notice.source)),
  ).sort();
  const noticePriorities = ['Routine', 'Advisory', 'Important', 'Priority'];

  const filteredNotices = sector_notices.filter((notice) => {
    if (noticeCategoryFilter !== 'ALL' && notice.category !== noticeCategoryFilter) {
      return false;
    }
    if (noticePriorityFilter !== 'ALL' && notice.priority !== noticePriorityFilter) {
      return false;
    }
    if (noticeSourceFilter !== 'ALL' && notice.source !== noticeSourceFilter) {
      return false;
    }
    if (noticeImpactFilter === 'ACTIVE' && !notice.operational_effect_active) {
      return false;
    }
    if (
      noticeImpactFilter === 'EXPIRED' &&
      (!notice.has_operational_effect || notice.operational_effect_active)
    ) {
      return false;
    }
    if (noticeImpactFilter === 'INFORMATIONAL' && notice.has_operational_effect) {
      return false;
    }
    return true;
  });

  const noticeFiltersActive =
    noticeCategoryFilter !== 'ALL' ||
    noticePriorityFilter !== 'ALL' ||
    noticeSourceFilter !== 'ALL' ||
    noticeImpactFilter !== 'ALL';

  const filteredInstallations = sector_installations
    .filter((installation) => {
      if (installationView === 'OPERATIONAL') {
        return (
          !installation.destroyed &&
          (installation.status === 'ONLINE' ||
            installation.status === 'ROUTINE OPERATIONS')
        );
      }
      if (installationView === 'ATTENTION') {
        return (
          !installation.destroyed &&
          installation.status !== 'ONLINE' &&
          installation.status !== 'ROUTINE OPERATIONS'
        );
      }
      if (installationView === 'DESTROYED') {
        return Boolean(installation.destroyed);
      }
      return true;
    })
    .slice()
    .sort((a, b) => {
      const rankDifference = installationAttentionRank(a) - installationAttentionRank(b);
      return rankDifference || a.name.localeCompare(b.name);
    });

  return (
    <Window
      theme="ntos"
      title="Central Command Remote Oversight Network"
      width={660}
      height={700}
    >
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="satellite-dish"
            selected={tab === 'station'}
            onClick={() => setTab('station')}
          >
            Station Status
          </Tabs.Tab>

          <Tabs.Tab
            icon="envelope"
            selected={tab === 'notices'}
            onClick={() => setTab('notices')}
          >
            Sector Notices ({filteredNotices.length}/{sector_notices.length})
          </Tabs.Tab>

          <Tabs.Tab
            icon="building"
            selected={tab === 'installations'}
            onClick={() => setTab('installations')}
          >
            Sector Installations
          </Tabs.Tab>

          <Tabs.Tab
            icon="clock-rotate-left"
            selected={tab === 'records'}
            onClick={() => setTab('records')}
          >
            Installation Records
          </Tabs.Tab>
        </Tabs>

        {tab === 'station' && (
          <>
            <NoticeBox>
              READ-ONLY TELEMETRY LINK - INFORMATION SHOULD BE VERIFIED BEFORE
              FORMAL REPORTING
            </NoticeBox>

            <Section title="Station Status">
              <LabeledList>
                <LabeledList.Item label="Installation">
                  {station_name}
                </LabeledList.Item>

                <LabeledList.Item label="Central Command Link">
                  <Box color="good">ONLINE</Box>
                </LabeledList.Item>

                <LabeledList.Item label="Alert Condition">
                  <Box color={getAlertColor(alert_level)}>
                    {alert_level.toUpperCase()}
                  </Box>
                </LabeledList.Item>

                <LabeledList.Item label="Registered Personnel">
                  {registered_crew}
                </LabeledList.Item>

                <LabeledList.Item label="Last Update">
                  {last_update}
                </LabeledList.Item>
              </LabeledList>
            </Section>

            <Section title="Registered Command Personnel">
              <LabeledList>
                {command_roster.map((entry) => (
                  <LabeledList.Item key={entry.role} label={entry.role}>
                    <Box
                      color={entry.name === 'UNSTAFFED' ? 'bad' : undefined}
                    >
                      {entry.name}
                    </Box>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>

            <Section title="Emergency Evacuation">
              <LabeledList>
                <LabeledList.Item label="Emergency Shuttle">
                  {shuttle.status}
                </LabeledList.Item>

                {!!shuttle.timer && (
                  <LabeledList.Item label="Timer">
                    {formatTimer(shuttle.timer)}
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </>
        )}

        {tab === 'notices' && (
          <>
            <NoticeBox>
              CENTRAL COMMAND SECTOR INFORMATION NETWORK - NOTICES MAY NOT
              REQUIRE LOCAL ACTION
            </NoticeBox>

            <Section
              title={`Notice Filters (${filteredNotices.length}/${sector_notices.length})`}
              buttons={
                noticeFiltersActive ? (
                  <Button
                    icon="rotate-left"
                    onClick={() => {
                      setNoticeCategoryFilter('ALL');
                      setNoticePriorityFilter('ALL');
                      setNoticeSourceFilter('ALL');
                      setNoticeImpactFilter('ALL');
                    }}
                  >
                    Reset Filters
                  </Button>
                ) : undefined
              }
            >
              <Box bold mb={0.5}>
                Category
              </Box>
              <Box mb={1}>
                <Button
                  color={noticeCategoryFilter === 'ALL' ? 'good' : undefined}
                  onClick={() => setNoticeCategoryFilter('ALL')}
                >
                  All
                </Button>
                {noticeCategories.map((category) => (
                  <Button
                    key={`notice-category-${category}`}
                    color={noticeCategoryFilter === category ? 'good' : undefined}
                    onClick={() => setNoticeCategoryFilter(category)}
                  >
                    {category}
                  </Button>
                ))}
              </Box>

              <Box bold mb={0.5}>
                Priority
              </Box>
              <Box mb={1}>
                <Button
                  color={noticePriorityFilter === 'ALL' ? 'good' : undefined}
                  onClick={() => setNoticePriorityFilter('ALL')}
                >
                  All
                </Button>
                {noticePriorities.map((priority) => (
                  <Button
                    key={`notice-priority-${priority}`}
                    color={noticePriorityFilter === priority ? 'good' : undefined}
                    onClick={() => setNoticePriorityFilter(priority)}
                  >
                    {priority}
                  </Button>
                ))}
              </Box>

              <Box bold mb={0.5}>
                Source
              </Box>
              <Box mb={1}>
                <Button
                  color={noticeSourceFilter === 'ALL' ? 'good' : undefined}
                  onClick={() => setNoticeSourceFilter('ALL')}
                >
                  All
                </Button>
                {noticeSources.map((source) => (
                  <Button
                    key={`notice-source-${source}`}
                    color={noticeSourceFilter === source ? 'good' : undefined}
                    onClick={() => setNoticeSourceFilter(source)}
                  >
                    {source}
                  </Button>
                ))}
              </Box>

              <Box bold mb={0.5}>
                Operational Impact
              </Box>
              <Box>
                {[
                  ['ALL', 'All'],
                  ['ACTIVE', 'Active Effect'],
                  ['EXPIRED', 'Expired Effect'],
                  ['INFORMATIONAL', 'Informational Only'],
                ].map(([value, label]) => (
                  <Button
                    key={`notice-impact-${value}`}
                    color={noticeImpactFilter === value ? 'good' : undefined}
                    onClick={() => setNoticeImpactFilter(value)}
                  >
                    {label}
                  </Button>
                ))}
              </Box>
            </Section>

            {sector_notices.length === 0 ? (
              <Section>
                <Box color="label">No sector notices currently available.</Box>
              </Section>
            ) : !filteredNotices.length ? (
              <NoticeBox>No sector notices match the active filters.</NoticeBox>
            ) : (
              filteredNotices.map((notice) => (
                <Section
                  key={notice.notice_code}
                  title={`${notice.notice_code} // ${notice.title}`}
                >
                  <LabeledList>
                    <LabeledList.Item label="Issued">
                      {notice.issued_at}
                    </LabeledList.Item>

                    <LabeledList.Item label="Source">
                      {notice.source}
                    </LabeledList.Item>

                    <LabeledList.Item label="Category">
                      {notice.category}
                    </LabeledList.Item>

                    <LabeledList.Item label="Priority">
                      <Box color={getNoticeColor(notice.priority)}>
                        {notice.priority.toUpperCase()}
                      </Box>
                    </LabeledList.Item>

                    {Boolean(notice.has_operational_effect) && (
                      <LabeledList.Item label="Operational Impact">
                        <Box
                          bold
                          color={notice.operational_effect_active ? 'average' : 'label'}
                        >
                          {notice.operational_effect_active
                            ? `ACTIVE EFFECT - ${formatNoticeDuration(
                                notice.operational_effect_seconds,
                              )} remaining`
                            : 'EFFECT EXPIRED'}
                        </Box>
                      </LabeledList.Item>
                    )}
                  </LabeledList>

                  <Box mt={2}>{notice.body}</Box>

                  {Boolean(notice.has_operational_effect) &&
                    notice.operational_effect_summary && (
                      <Box
                        mt={1.5}
                        p={1}
                        backgroundColor="rgba(255, 255, 255, 0.04)"
                      >
                        <Box bold mb={0.5}>
                          Sector Effect
                        </Box>
                        {notice.operational_effect_summary}
                      </Box>
                    )}
                </Section>
              ))
            )}
          </>
        )}

        {tab === 'installations' && (
          <>
            <NoticeBox>
              CENTRAL COMMAND SECTOR INSTALLATION NETWORK - REMOTE TELEMETRY
              ONLY
            </NoticeBox>

            <Section title="Installation View">
              <Box>
                {[
                  ['ALL', 'All'],
                  ['ATTENTION', 'Needs Attention'],
                  ['OPERATIONAL', 'Operational'],
                  ['DESTROYED', 'Destroyed'],
                ].map(([value, label]) => (
                  <Button
                    key={`installation-view-${value}`}
                    color={installationView === value ? 'good' : undefined}
                    onClick={() => setInstallationView(value)}
                  >
                    {label}
                  </Button>
                ))}
              </Box>
              <Box mt={1} color="label">
                Showing {filteredInstallations.length} of {sector_installations.length}{' '}
                registered installations. Attention sorting places confirmed losses
                and active operational problems first.
              </Box>
            </Section>

            <Section title="Network Summary">
              <LabeledList>
                <LabeledList.Item label="Registered Installations">
                  {sector_installations.length}
                </LabeledList.Item>

                <LabeledList.Item label="Routine Operations">
                  <Box color="good">{operationalInstallations}</Box>
                </LabeledList.Item>

                <LabeledList.Item label="Critical Incidents">
                  <Box color={criticalInstallations > 0 ? 'bad' : 'good'}>
                    {criticalInstallations}
                  </Box>
                </LabeledList.Item>

                <LabeledList.Item label="Confirmed Losses">
                  <Box color={destroyedInstallations > 0 ? 'bad' : 'good'}>
                    {destroyedInstallations}
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>

            {filteredInstallations.map((installation) => (
              <Section
                key={installation.code}
                title={`${installation.code} // ${installation.name}`}
              >
                {installation.status === 'CRITICAL' && (
                  <NoticeBox danger>
                    CRITICAL OPERATIONAL EVENT - CENTRAL EMERGENCY MANAGEMENT
                    NOTIFIED
                  </NoticeBox>
                )}

                {!!installation.destroyed && (
                  <NoticeBox danger>
                    CONFIRMED INSTALLATION LOSS - REMOTE TELEMETRY TERMINATED
                  </NoticeBox>
                )}

                <LabeledList>
                  <LabeledList.Item label="Function">
                    {installation.function}
                  </LabeledList.Item>

                  <LabeledList.Item label="Regional Dependency">
                    {installation.regional_dependency}
                  </LabeledList.Item>

                  <LabeledList.Item label="Operational Status">
                    <Box color={getInstallationColor(installation.status)}>
                      {installation.status}
                    </Box>
                  </LabeledList.Item>

                  <LabeledList.Item label="Relationship Assessment">
                    <Box color={getRelationshipColor(installation.trust_label)} bold>
                      {installation.trust_label}
                    </Box>
                  </LabeledList.Item>

                  <LabeledList.Item label="Condition">
                    <Box color={getConditionColor(installation.condition)}>
                      {installation.condition}
                    </Box>
                  </LabeledList.Item>

                  <LabeledList.Item label="Telemetry">
                    <Box color={getTelemetryColor(installation.telemetry)}>
                      {installation.telemetry}
                    </Box>
                  </LabeledList.Item>

                  <LabeledList.Item label="Last Authenticated Contact">
                    {installation.last_authenticated_contact}{' '}
                    <Box inline color="label">
                      ({formatRelativeContact(installation.last_contact_seconds_ago)})
                    </Box>
                  </LabeledList.Item>

                  {installation.response_status !== 'NONE' && (
                    <LabeledList.Item label="Central Response">
                      <Box
                        color={getResponseColor(
                          installation.response_status,
                        )}
                      >
                        {installation.response_status}
                      </Box>
                    </LabeledList.Item>
                  )}

                  {installation.incident_summary !== 'No active incident.' && (
                    <LabeledList.Item label="Incident">
                      {installation.incident_summary}
                    </LabeledList.Item>
                  )}

                  <LabeledList.Item label="Remarks">
                    {installation.condition_details}
                  </LabeledList.Item>

                  {!!installation.destroyed && !!installation.loss_consequence && (
                    <LabeledList.Item label="Permanent Sector Consequence">
                      <Box color="bad">{installation.loss_consequence}</Box>
                    </LabeledList.Item>
                  )}

                  <LabeledList.Item label="Last Status Change">
                    {installation.status_since}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))}
          </>
        )}

        {tab === 'records' && (
          <>
            <NoticeBox>
              SHIFT ADMINISTRATIVE RECORDS — RELATIONSHIP ASSESSMENTS ARE
              QUALITATIVE AND REFLECT LIAISON INTERACTIONS, NOT CORPORATE LOYALTY
              OR LEGAL AUTHORITY
            </NoticeBox>

            {!sector_installations.length ? (
              <Section>
                <Box color="label">No installation records are available.</Box>
              </Section>
            ) : (
              <Stack>
                <Stack.Item minWidth="185px" shrink={0} basis={0}>
                  <Tabs vertical>
                    {sector_installations.map((installation) => (
                      <Tabs.Tab
                        key={`record-tab-${installation.code}`}
                        selected={activeRecordCode === installation.code}
                        onClick={() =>
                          setSelectedRecordInstallation(installation.code)
                        }
                      >
                        {installation.name}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Stack.Item>

                <Stack.Item grow>
                  {!!activeRecordInstallation && (
                    <Section
                      title={`${activeRecordInstallation.code} // ${activeRecordInstallation.name}`}
                      buttons={
                        <>
                          <Button
                            icon="print"
                            onClick={() =>
                              act('print_installation_record', {
                                installation_code: activeRecordInstallation.code,
                              })
                            }
                          >
                            Print Record
                          </Button>
                          <Button.Confirm
                            icon="trash"
                            color="danger"
                            disabled={!activeRecordInstallation.history.length}
                            confirmContent="Clear retained history?"
                            onClick={() =>
                              act('clear_installation_history', {
                                installation_code: activeRecordInstallation.code,
                              })
                            }
                          >
                            Clear History
                          </Button.Confirm>
                        </>
                      }
                    >
                      <LabeledList>
                        <LabeledList.Item label="Function">
                          {activeRecordInstallation.function}
                        </LabeledList.Item>
                        <LabeledList.Item label="Regional Dependency">
                          {activeRecordInstallation.regional_dependency}
                        </LabeledList.Item>
                        <LabeledList.Item label="Current Status">
                          <Box
                            color={getInstallationColor(
                              activeRecordInstallation.status,
                            )}
                          >
                            {activeRecordInstallation.status}
                          </Box>
                        </LabeledList.Item>
                        <LabeledList.Item label="Condition">
                          <Box
                            color={getConditionColor(
                              activeRecordInstallation.condition,
                            )}
                          >
                            {activeRecordInstallation.condition}
                          </Box>
                        </LabeledList.Item>
                        <LabeledList.Item label="Telemetry">
                          <Box
                            color={getTelemetryColor(
                              activeRecordInstallation.telemetry,
                            )}
                          >
                            {activeRecordInstallation.telemetry}
                          </Box>
                        </LabeledList.Item>
                        <LabeledList.Item label="Last Authenticated Contact">
                          {activeRecordInstallation.last_authenticated_contact}{' '}
                          <Box inline color="label">
                            ({formatRelativeContact(
                              activeRecordInstallation.last_contact_seconds_ago,
                            )})
                          </Box>
                        </LabeledList.Item>
                        <LabeledList.Item label="Named Contact">
                          {activeRecordInstallation.contact_role}{' '}
                          {activeRecordInstallation.contact_name}
                        </LabeledList.Item>
                        <LabeledList.Item label="Relationship Assessment">
                          <Box
                            color={getRelationshipColor(
                              activeRecordInstallation.trust_label,
                            )}
                            bold
                          >
                            {activeRecordInstallation.trust_label}
                          </Box>
                        </LabeledList.Item>
                        {activeRecordInstallation.response_status !== 'NONE' && (
                          <LabeledList.Item label="Central Response">
                            <Box
                              color={getResponseColor(
                                activeRecordInstallation.response_status,
                              )}
                            >
                              {activeRecordInstallation.response_status}
                            </Box>
                          </LabeledList.Item>
                        )}
                        {activeRecordInstallation.incident_summary !==
                          'No active incident.' && (
                          <LabeledList.Item label="Incident">
                            {activeRecordInstallation.incident_summary}
                          </LabeledList.Item>
                        )}
                        <LabeledList.Item label="Remarks">
                          {activeRecordInstallation.condition_details}
                        </LabeledList.Item>
                        {!!activeRecordInstallation.destroyed &&
                          !!activeRecordInstallation.loss_consequence && (
                            <LabeledList.Item label="Permanent Sector Consequence">
                              <Box color="bad">
                                {activeRecordInstallation.loss_consequence}
                              </Box>
                            </LabeledList.Item>
                          )}
                        <LabeledList.Item label="Last Status Change">
                          {activeRecordInstallation.status_since}
                        </LabeledList.Item>
                        <LabeledList.Item label="Active Follow-Up">
                          {activeRecordInstallation.followup_active ? (
                            <>
                              <Box bold>
                                {activeRecordInstallation.followup_subject ||
                                  'Active matter'}
                              </Box>
                              <Box color="label">
                                {activeRecordInstallation.followup_status}
                              </Box>
                            </>
                          ) : (
                            <Box color="label">No active case.</Box>
                          )}
                        </LabeledList.Item>
                      </LabeledList>

                      <Box mt={1.5} bold>
                        Recent Administrative History
                      </Box>

                      {!activeRecordInstallation.history.length ? (
                        <Box mt={1} color="label">
                          No notable history has been recorded this shift.
                        </Box>
                      ) : (
                        activeRecordInstallation.history.map((entry, index) => (
                          <Box
                            key={`${activeRecordInstallation.code}-${entry.timestamp}-${index}`}
                            mt={1}
                            p={1}
                            backgroundColor="rgba(255, 255, 255, 0.04)"
                          >
                            <Box bold>
                              {entry.timestamp} — {entry.category}: {entry.title}
                            </Box>
                            <Box mt={0.5}>{entry.details}</Box>
                          </Box>
                        ))
                      )}
                    </Section>
                  )}
                </Stack.Item>
              </Stack>
            )}
          </>
        )}
      </Window.Content>
    </Window>
  );
};