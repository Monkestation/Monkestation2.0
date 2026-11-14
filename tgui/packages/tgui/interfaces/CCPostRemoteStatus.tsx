import { CCPostHeader } from './CCPostTheme';
import { useBackend, useLocalState, useSharedState } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Tabs,
} from '../components';
import { Layout, Window } from '../layouts';

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
  outpost_offline?: boolean | number;
  read_only?: boolean | number;
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
  const [helpOpen, setHelpOpen] = useLocalState('ccpostNetworkHelp', false);

  const {
    read_only = false,
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

  const [recordSearch, setRecordSearch] = useLocalState('ccpostRecordSearch', '');
  const [selectedRecordInstallation, setSelectedRecordInstallation] =
    useLocalState('recordInstallation', sector_installations[0]?.code || '');
  const activeRecordInstallation =
    sector_installations.find(
      (installation) => installation.code === selectedRecordInstallation,
    ) || sector_installations[0];
  const activeRecordCode = activeRecordInstallation?.code || '';
  const filteredRecordInstallations = sector_installations.filter((item) => `${item.name} ${item.code} ${item.function}`.toLowerCase().includes(recordSearch.trim().toLowerCase()));

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
  const [noticeSearch, setNoticeSearch] = useLocalState('ccpostNoticeSearch', '');
  const [installationSearch, setInstallationSearch] = useLocalState('ccpostInstallationSearch', '');
  const [selectedNoticeCode, setSelectedNoticeCode] = useLocalState('ccpostSelectedNotice', '');
  const [selectedFacilityCode, setSelectedFacilityCode] = useLocalState('ccpostSelectedFacility', '');
  const [extraNoticeFilters, setExtraNoticeFilters] = useLocalState('ccpostExtraNoticeFilters', false);

  const noticeCategories = Array.from(
    new Set(sector_notices.map((notice) => notice.category)),
  ).sort();
  const noticeSources = Array.from(
    new Set(sector_notices.map((notice) => notice.source)),
  ).sort();

  const filteredNotices = sector_notices.filter((notice) => {
    const query = noticeSearch.trim().toLowerCase();
    if (query && !`${notice.title} ${notice.source} ${notice.notice_code} ${notice.body}`.toLowerCase().includes(query)) {
      return false;
    }
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
    Boolean(noticeSearch.trim()) ||
    noticeCategoryFilter !== 'ALL' ||
    noticePriorityFilter !== 'ALL' ||
    noticeSourceFilter !== 'ALL' ||
    noticeImpactFilter !== 'ALL';

  const filteredInstallations = sector_installations
    .filter((installation) => {
      const query = installationSearch.trim().toLowerCase();
      if (query && !`${installation.name} ${installation.code} ${installation.function}`.toLowerCase().includes(query)) return false;
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

  const activeNotice = filteredNotices.find((notice) => notice.notice_code === selectedNoticeCode) || filteredNotices[0];
  const activeFacility = filteredInstallations.find((installation) => installation.code === selectedFacilityCode) || filteredInstallations[0];

  return (
    <Window
      theme="ntos"
      title="Central Command Remote Oversight Network"
      width={820}
      height={740}
    >
      <Window.Content className="ccpost-theme ccpost-theme--oversight ccpost-admin-v2">
          <CCPostHeader title="Remote Oversight Network" division="CENTRAL COMMAND" />
          <div className="CCPostAdminFixedMetrics"><div className="CCPostMetricRow">
          <div className="CCPostMetric"><div className="CCPostMetric__value">{sector_installations.length}</div><div className="CCPostMetric__label">REGISTERED FACILITIES</div></div>
          <div className="CCPostMetric"><div className="CCPostMetric__value">{operationalInstallations}</div><div className="CCPostMetric__label">OPERATIONAL</div></div>
          <div className="CCPostMetric"><div className="CCPostMetric__value">{criticalInstallations}</div><div className="CCPostMetric__label">CRITICAL</div></div>
        </div>
        </div>
          <div className="CCPostAdminNav"><Tabs>
          <Tabs.Tab
            icon="satellite-dish"
            selected={tab === 'station'}
            onClick={() => setTab('station')}
          >
            Station
          </Tabs.Tab>

          <Tabs.Tab
            icon="envelope"
            selected={tab === 'notices'}
            onClick={() => setTab('notices')}
          >
            Notices ({filteredNotices.length})
          </Tabs.Tab>

          <Tabs.Tab
            icon="building"
            selected={tab === 'installations'}
            onClick={() => setTab('installations')}
          >
            Facilities
          </Tabs.Tab>

          <Tabs.Tab
            icon="clock-rotate-left"
            selected={tab === 'records'}
            onClick={() => setTab('records')}
          >
            Records
          </Tabs.Tab>
        </Tabs><Button icon="question-circle" onClick={() => setHelpOpen(!helpOpen)}>{helpOpen ? 'Hide Manual' : 'Operating Manual'}</Button></div>
          <Layout.Content scrollable className="CCPostAdminBody">
          {Boolean(data.outpost_offline) && <NoticeBox danger>INSTALLATION OFFLINE. Remote Oversight telemetry is no longer reliable and administrative operations have been suspended.</NoticeBox>}
        {Boolean(read_only) && (
          <NoticeBox>
            OBSERVER MODE: Read-only. Network controls and administrative actions
            remain restricted to authorized Central Command personnel.
          </NoticeBox>
        )}
        <div className="CCPostTelemetryMeta">REGIONAL MONITORING <span>Read-only telemetry · {last_update || 'Awaiting transmission'}</span></div>
        {helpOpen && (
          <Section title="Regional Oversight Procedures">
            <Box>Monitor station conditions, review sector notices and examine installation records. This network does not grant direct operational control of any facility.</Box>
            <Box mt={1}>Verify relevant telemetry and printed records before reporting findings. Existing records should be consulted before contacting station personnel; respect local operational authority. Sector Communications handles correspondence and Tasking records formal investigations.</Box>
            <Box mt={1} color="label">RESTRICTED CORPORATE TELEMETRY. Reports may be incomplete while regional communications are impaired.</Box>
          </Section>
        )}
        

        {tab === 'station' && (
          <>
            
            <div className="CCPostOversightColumns">
              <div>
                <Section title="Station Link" className="CCPostStationLinkCard">
                  <LabeledList>
                    <LabeledList.Item label="Station">{station_name}</LabeledList.Item>
                    <LabeledList.Item label="Link"><span className={`CCPostStatusTag ${data.outpost_offline ? 'CCPostStatusTag--bad' : 'CCPostStatusTag--good'}`}>{data.outpost_offline ? "OFFLINE" : "ONLINE"}</span></LabeledList.Item>
                    <LabeledList.Item label="Alert"><span className={`CCPostStatusTag CCPostStatusTag--${getAlertColor(alert_level)}`}>{alert_level.toUpperCase()}</span></LabeledList.Item>
                    <LabeledList.Item label="Personnel">{registered_crew}</LabeledList.Item>
                    <LabeledList.Item label="Updated">{last_update}</LabeledList.Item>
                  </LabeledList>
                </Section>
                <Section title="Evacuation" className="CCPostEvacuationCard">
                  <LabeledList>
                    <LabeledList.Item label="Shuttle"><span className="CCPostStatusTag">{shuttle.status}</span></LabeledList.Item>
                    {!!shuttle.timer && <LabeledList.Item label="Timer">{formatTimer(shuttle.timer)}</LabeledList.Item>}
                  </LabeledList>
                </Section>
              </div>
              <div>
                <Section title="Station Command Registry" className="CCPostCommandRegistry">
                  {!command_roster.length ? <Box color="label">No command records available.</Box> : (
                    <LabeledList>
                      {command_roster.map((entry) => (
                        <LabeledList.Item key={entry.role} label={entry.role}>
                          <Box color={entry.name === 'UNSTAFFED' ? 'label' : undefined}>{entry.name === 'UNSTAFFED' ? 'Unstaffed' : entry.name}</Box>
                        </LabeledList.Item>
                      ))}
                    </LabeledList>
                  )}
                </Section>
              </div>
            </div>
            <div className="CCPostOverviewInfo">Live station telemetry is read-only. Verify significant reports before issuing formal correspondence.</div>
          </>
        )}

        {tab === 'notices' && (
          <>
            <div className="CCPostOverviewInfo">Sector notices are informational unless an active operational effect is recorded.</div>
            <div className="CCPostOversightFilters">
              <Input placeholder="Search notices" value={noticeSearch} onChange={setNoticeSearch} width="210px" />
              {['ALL', 'Important', 'Priority'].map((priority) => (
                <Button key={priority} selected={noticePriorityFilter === priority} onClick={() => setNoticePriorityFilter(priority)}>{priority === 'ALL' ? 'All priorities' : priority}</Button>
              ))}
              <Button icon="filter" selected={extraNoticeFilters} onClick={() => setExtraNoticeFilters(!extraNoticeFilters)}>{extraNoticeFilters ? 'Hide Filters' : 'More Filters'}</Button>
              {noticeFiltersActive && <Button icon="rotate-left" onClick={() => { setNoticeCategoryFilter('ALL'); setNoticePriorityFilter('ALL'); setNoticeSourceFilter('ALL'); setNoticeImpactFilter('ALL'); setNoticeSearch(''); }}>Reset</Button>}
            </div>
            {extraNoticeFilters && (
              <Section title="Additional Notice Filters">
                <Box bold>Category</Box>
                <div className="CCPostOversightFilters">{['ALL', ...noticeCategories].map((category) => <Button key={category} selected={noticeCategoryFilter === category} onClick={() => setNoticeCategoryFilter(category)}>{category === 'ALL' ? 'All categories' : category}</Button>)}</div>
                <Box bold>Source</Box>
                <div className="CCPostOversightFilters">{['ALL', ...noticeSources].map((source) => <Button key={source} selected={noticeSourceFilter === source} onClick={() => setNoticeSourceFilter(source)}>{source === 'ALL' ? 'All sources' : source}</Button>)}</div>
                <Box bold>Impact</Box>
                <div className="CCPostOversightFilters">{[['ALL','All'],['ACTIVE','Active'],['EXPIRED','Expired'],['INFORMATIONAL','Informational']].map(([key,label]) => <Button key={key} selected={noticeImpactFilter === key} onClick={() => setNoticeImpactFilter(key)}>{label}</Button>)}</div>
              </Section>
            )}
            <div className="CCPostOversightColumns">
              <div>
                <Section title={`Received Notices (${filteredNotices.length})`}>
                  {!filteredNotices.length ? <Box color="label">No matching notices.</Box> : filteredNotices.map((notice) => (
                    <button key={notice.notice_code} className={`CCPostOversightRow ${activeNotice?.notice_code === notice.notice_code ? 'CCPostOversightRow--active' : ''}`} onClick={() => setSelectedNoticeCode(notice.notice_code)}>
                      <strong>{notice.title}</strong>
                      <small>{notice.notice_code} · {notice.priority} · {notice.issued_at}</small>
                      {Boolean(notice.operational_effect_active) && <small>ACTIVE SECTOR EFFECT</small>}
                    </button>
                  ))}
                </Section>
              </div>
              <div>
                {activeNotice ? (
                  <Section title={activeNotice.title}>
                    <LabeledList>
                      <LabeledList.Item label="Reference">{activeNotice.notice_code}</LabeledList.Item>
                      <LabeledList.Item label="Issued">{activeNotice.issued_at}</LabeledList.Item>
                      <LabeledList.Item label="Source">{activeNotice.source}</LabeledList.Item>
                      <LabeledList.Item label="Category">{activeNotice.category}</LabeledList.Item>
                      <LabeledList.Item label="Priority"><Box color={getNoticeColor(activeNotice.priority)}>{activeNotice.priority}</Box></LabeledList.Item>
                      {Boolean(activeNotice.has_operational_effect) && <LabeledList.Item label="Effect"><Box color={activeNotice.operational_effect_active ? 'average' : 'label'}>{activeNotice.operational_effect_active ? `${formatNoticeDuration(activeNotice.operational_effect_seconds)} remaining` : 'EXPIRED'}</Box></LabeledList.Item>}
                    </LabeledList>
                    <Box mt={2} className="CCPostDocumentCard">{activeNotice.body}</Box>
                    {Boolean(activeNotice.has_operational_effect) && !!activeNotice.operational_effect_summary && <Box mt={1} className="CCPostReviewFinding"><Box bold>Operational Impact</Box>{activeNotice.operational_effect_summary}</Box>}
                  </Section>
                ) : <Section title="Notice Details"><Box color="label">Select a notice to view its details.</Box></Section>}
              </div>
            </div>
          </>
        )}

        {tab === 'installations' && (
          <>
            <div className="CCPostOverviewInfo">Monitor installation conditions and relationship assessments. Local operations remain under the authority of each installation.</div>
            <div className="CCPostOversightFilters">
              <Input placeholder="Search installations" value={installationSearch} onChange={setInstallationSearch} width="215px" />
              {[['ALL','All'],['ATTENTION','Needs Attention'],['OPERATIONAL','Operational'],['DESTROYED','Destroyed']].map(([key,label]) => (
                <Button key={key} selected={installationView === key} onClick={() => setInstallationView(key)}>{label}</Button>
              ))}
            </div>
            <div className="CCPostOversightColumns">
              <div>
                <Section title={`Facilities (${filteredInstallations.length})`}>
                  {!filteredInstallations.length ? <Box color="label">No installations match these filters.</Box> : filteredInstallations.map((installation) => (
                    <button key={installation.code} className={`CCPostOversightRow ${activeFacility?.code === installation.code ? 'CCPostOversightRow--active' : ''}`} onClick={() => setSelectedFacilityCode(installation.code)}>
                      <strong>{installation.name}</strong>
                      <small>{installation.code} · {installation.status}</small>
                      <small>Last contact {formatRelativeContact(installation.last_contact_seconds_ago)}</small>
                    </button>
                  ))}
                </Section>
              </div>
              <div>
                {activeFacility ? (
                  <Section title={`${activeFacility.code} / ${activeFacility.name}`} buttons={<Button icon="folder-open" onClick={() => { setSelectedRecordInstallation(activeFacility.code); setTab('records'); }}>View Record</Button>}>
                    {activeFacility.status === 'CRITICAL' && <NoticeBox danger>CRITICAL OPERATIONAL EVENT</NoticeBox>}
                    {Boolean(activeFacility.destroyed) && <NoticeBox danger>INSTALLATION LOSS CONFIRMED</NoticeBox>}
                    <LabeledList>
                      <LabeledList.Item label="Function">{activeFacility.function}</LabeledList.Item>
                      <LabeledList.Item label="Status"><Box color={getInstallationColor(activeFacility.status)}>{activeFacility.status}</Box></LabeledList.Item>
                      <LabeledList.Item label="Condition"><Box color={getConditionColor(activeFacility.condition)}>{activeFacility.condition}</Box></LabeledList.Item>
                      <LabeledList.Item label="Telemetry"><Box color={getTelemetryColor(activeFacility.telemetry)}>{activeFacility.telemetry}</Box></LabeledList.Item>
                      <LabeledList.Item label="Relationship"><Box color={getRelationshipColor(activeFacility.trust_label)}>{activeFacility.trust_label}</Box></LabeledList.Item>
                      <LabeledList.Item label="Last Contact">{activeFacility.last_authenticated_contact}</LabeledList.Item>
                      <LabeledList.Item label="Regional Dependency">{activeFacility.regional_dependency}</LabeledList.Item>
                      {activeFacility.response_status !== 'NONE' && <LabeledList.Item label="Central Response"><Box color={getResponseColor(activeFacility.response_status)}>{activeFacility.response_status}</Box></LabeledList.Item>}
                    </LabeledList>
                    <Box mt={1} className="CCPostReviewFinding"><Box bold>Operational Remarks</Box>{activeFacility.condition_details}</Box>
                    {activeFacility.incident_summary !== 'No active incident.' && <Box mt={1}><Box bold>Incident</Box>{activeFacility.incident_summary}</Box>}
                    {!!activeFacility.loss_consequence && Boolean(activeFacility.destroyed) && <NoticeBox danger mt={1}>{activeFacility.loss_consequence}</NoticeBox>}
                  </Section>
                ) : <Section title="Facility Details"><Box color="label">Select an installation to inspect its telemetry.</Box></Section>}
              </div>
            </div>
          </>
        )}

        {tab === 'records' && (
          <>
            <div className="CCPostOverviewInfo">Shift administrative records. Relationship assessments reflect Liaison interactions, not corporate loyalty or legal authority.</div>
            <div className="CCPostOversightFilters">
              <Input placeholder="Search records" value={recordSearch} onChange={setRecordSearch} width="215px" />
              <Box color="label">{filteredRecordInstallations.length} registered records</Box>
            </div>

            {!sector_installations.length ? (
              <Section>
                <Box color="label">No installation records are available.</Box>
              </Section>
            ) : (
              <div className="CCPostOversightColumns">
                <div>
                  <Section title={`Facilities (${filteredRecordInstallations.length})`}>
                    {!filteredRecordInstallations.length ? <Box color="label">No matching installation records.</Box> : filteredRecordInstallations.map((installation) => (
                      <button
                        type="button"
                        key={`record-tab-${installation.code}`}
                        className={`CCPostOversightRow ${activeRecordCode === installation.code ? 'CCPostOversightRow--active' : ''}`}
                        onClick={() => setSelectedRecordInstallation(installation.code)}
                      >
                        <strong>{installation.name}</strong>
                        <small>{installation.code} · {installation.status}</small>
                        <small>Last contact {formatRelativeContact(installation.last_contact_seconds_ago)}</small>
                      </button>
                    ))}
                  </Section>
                </div>
                <div>
                  {!!activeRecordInstallation && (
                    <Section
                      title={`${activeRecordInstallation.code} // ${activeRecordInstallation.name}`}
                      buttons={
                        <div className="CCPostRecordActions">
                          <Button
                            icon="print"
                            disabled={Boolean(read_only)}
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
                            disabled={Boolean(read_only) || !activeRecordInstallation.history.length}
                            confirmContent="Clear retained history?"
                            onClick={() =>
                              act('clear_installation_history', {
                                installation_code: activeRecordInstallation.code,
                              })
                            }
                          >
                            Clear History
                          </Button.Confirm>
                        </div>
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

                      <Collapsible title={`Recent Administrative History (${activeRecordInstallation.history.length})`}>

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
                      </Collapsible>
                    </Section>
                  )}
                </div>
              </div>
            )}
          </>
        )}
      
          </Layout.Content>
        </Window.Content>
    </Window>
  );
};