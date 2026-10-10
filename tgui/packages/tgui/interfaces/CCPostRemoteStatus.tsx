import { useBackend, useSharedState } from '../backend';
import {
  Box,
  LabeledList,
  NoticeBox,
  Section,
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
};

type SectorInstallation = {
  code: string;
  name: string;
  function: string;
  status: string;
  status_since: string;
  condition: string;
  telemetry: string;
  condition_details: string;
  incident_summary: string;
  response_status: string;
  ert_dispatched: boolean;
  destroyed: boolean;
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

const getResponseColor = (response: string) => {
  switch (response) {
    case 'ERT OPERATION COMPLETE':
    case 'INCIDENT STABILIZED':
      return 'good';

    case 'ERT DISPATCHED':
    case 'NO ERT DISPATCHED':
      return 'average';

    case 'ERT OPERATION FAILED':
    case 'INSTALLATION LOST':
      return 'bad';

    default:
      return 'label';
  }
};

export const CCPostRemoteStatus = () => {
  const { data } = useBackend<Data>();
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
            Sector Notices ({sector_notices.length})
          </Tabs.Tab>

          <Tabs.Tab
            icon="building"
            selected={tab === 'installations'}
            onClick={() => setTab('installations')}
          >
            Sector Installations
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

            {sector_notices.length === 0 && (
              <Section>
                <Box color="label">No sector notices currently available.</Box>
              </Section>
            )}

            {sector_notices.map((notice) => (
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
                </LabeledList>

                <Box mt={2}>{notice.body}</Box>
              </Section>
            ))}
          </>
        )}

        {tab === 'installations' && (
          <>
            <NoticeBox>
              CENTRAL COMMAND SECTOR INSTALLATION NETWORK - REMOTE TELEMETRY
              ONLY
            </NoticeBox>

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

            {sector_installations.map((installation) => (
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

                  <LabeledList.Item label="Operational Status">
                    <Box color={getInstallationColor(installation.status)}>
                      {installation.status}
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

                  <LabeledList.Item label="Last Status Change">
                    {installation.status_since}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))}
          </>
        )}
      </Window.Content>
    </Window>
  );
};