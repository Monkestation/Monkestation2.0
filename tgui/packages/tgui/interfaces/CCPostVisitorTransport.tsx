/** Shared visitor departure and camera-consent retrieval interface. The backend enforces every authorization. */
import { CCPostHeader } from './CCPostTheme';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, LabeledList, NoticeBox, Section } from '../components';
import { Layout, Window } from '../layouts';

type Beacon = { ref: string; name: string; area: string; coordinates: string; availability?: string };
type Data = {
  retrieval_mode?: boolean | number;
  outpost_offline?: boolean | number;
  read_only?: boolean | number;
  pad_linked?: boolean | number;
  pad_busy?: boolean | number;
  charging?: boolean | number;
  request_pending?: boolean | number;
  camera_active?: boolean | number;
  selected_target_name?: string;
  selected_target_area?: string;
  selected_target_valid?: boolean | number;
  invitation_cooldown_seconds?: number;
  console_operational?: boolean | number;
  cooldown_seconds?: number;
  status_message?: string;
  passenger_available?: boolean | number;
  passenger_name?: string;
  destination_name?: string;
  destination_area?: string;
  destination_coordinates?: string;
  destination_valid?: boolean | number;
  destination_state?: string;
  destination_status_text?: string;
  destination_ref?: string | null;
  beacons?: Beacon[];
};

export const CCPostVisitorTransport = () => {
  const { act, data } = useBackend<Data>();
  const [search, setSearch] = useLocalState('ccpostVisitorBeaconFilter', '');
  const [manualOpen, setManualOpen] = useLocalState('ccpostVisitorManual', false);
  const retrieval = Boolean(data.retrieval_mode);
  const offline = Boolean(data.outpost_offline);
  const observer = Boolean(data.read_only);
  const connected = Boolean(data.pad_linked);
  const busy = Boolean(data.pad_busy);
  const charging = Boolean(data.charging);
  const powered = Boolean(data.console_operational) && !offline;
  const cooling = (data.cooldown_seconds || 0) > 0;
  const pending = Boolean(data.request_pending);
  const selectedVisitor = Boolean(data.selected_target_valid);
  const canOperate = !observer && powered && connected && !busy;
  const canRetrieval = canOperate && !charging && !pending && !cooling && selectedVisitor && !(data.invitation_cooldown_seconds || 0);
  const canDeparture = canOperate && !charging && !cooling && Boolean(data.passenger_available) && Boolean(data.destination_valid);
  const beacons = (data.beacons || []).filter((beacon) =>
    `${beacon.name} ${beacon.area} ${beacon.coordinates}`.toLowerCase().includes(search.trim().toLowerCase()),
  ).sort((a, b) => a.area.localeCompare(b.area) || a.name.localeCompare(b.name));

  return (
    <Window title={`Central Command Visitor ${retrieval ? 'Retrieval' : 'Transport'}`} theme="ntos" width={800} height={665}>
      <Window.Content className="ccpost-theme ccpost-theme--security ccpost-admin-v2 CCPostVisitorWorkspace">
        <CCPostHeader title={retrieval ? 'Visitor Retrieval' : 'Visitor Transport'} division="CENTRAL COMMAND" status="AUTHORIZED TRANSPORT NETWORK" />
          <Layout.Content scrollable className="CCPostAdminBody">
        {(observer || offline) && <NoticeBox danger={offline}>
          {offline ? 'INSTALLATION OFFLINE. Visitor operations are unavailable.' : 'OBSERVER MODE. Controls require an authorized outpost ID.'}
        </NoticeBox>}
        <div className="CCPostMetricRow">
          <div className="CCPostMetric"><div className="CCPostMetric__value">{!powered ? 'OFFLINE' : connected ? busy ? 'OCCUPIED' : 'LINKED' : 'UNLINKED'}</div><div className="CCPostMetric__label">RECEPTION PAD</div></div>
          <div className="CCPostMetric"><div className="CCPostMetric__value">{charging ? 'CHARGING' : pending ? 'CONSENT' : cooling ? 'COOLDOWN' : 'STANDBY'}</div><div className="CCPostMetric__label">TRANSFER STATE</div></div>
          <div className="CCPostMetric"><div className="CCPostMetric__value">{data.cooldown_seconds || 0}s</div><div className="CCPostMetric__label">RECALIBRATION</div></div>
        </div>
        <div className="CCPostWorkspaceToolbar">
          <div><strong>{retrieval ? 'Camera-Supervised Visitor Retrieval' : 'Beacon-Guided Visitor Departure'}</strong><span>SELECT / VERIFY / AUTHORIZE</span></div>
          <Button icon="question-circle" onClick={() => setManualOpen(!manualOpen)}>{manualOpen ? 'Hide Procedure' : 'Operating Procedure'}</Button>
        </div>
        {manualOpen && <Section title="Transfer Protocol">
          {retrieval
            ? 'Select a person using the action in the station camera view. Retrieval requires that person to be client-controlled, eligible, and to explicitly consent before a five-second transfer can begin. Respect declined invitations and do not repeatedly solicit a visitor. Security may screen arriving visitors and restrict access.'
            : 'Select an enabled station tracking beacon, verify one eligible visitor is standing on the reception pad, and authorize transport. Destinations are validated again during the five-second charging sequence.'}
        </Section>}
        <div className="CCPostVisitorWorkspace__columns">
          <div>
            <Section title={retrieval ? '01 / SELECT VISITOR' : '01 / SELECT DESTINATION'}>
              {retrieval ? (
                <>
                  <Button icon="video" fluid disabled={!canOperate || charging || pending} onClick={() => act('open_camera')}>
                    {data.camera_active ? 'Return to Station Camera' : 'Open Station Camera'}
                  </Button>
                  <Box mt={1} color="label">Use the camera's Select Visitor action. Global crew selection is not available.</Box>
                  <LabeledList>
                    <LabeledList.Item label="Selected Person">{data.selected_target_name || 'No visitor selected'}</LabeledList.Item>
                    <LabeledList.Item label="Station Location">{data.selected_target_area || 'Unassigned'}</LabeledList.Item>
                  </LabeledList>
                  <Button icon="times" disabled={observer || pending || charging || !data.selected_target_name || data.selected_target_name === 'No visitor selected'} onClick={() => act('clear_target')}>Clear Selection</Button>
                </>
              ) : (
                <>
                  <Input fluid placeholder="Find a station beacon" value={search} onChange={setSearch} />
                  <div className="CCPostVisitorWorkspace__beacons">
                    {beacons.length ? beacons.map((beacon) => (
                      <button type="button" className={`CCPostVisitorWorkspace__beacon ${data.destination_ref === beacon.ref ? 'CCPostVisitorWorkspace__beacon--active' : ''}`}
                        key={beacon.ref} disabled={!canOperate || charging} onClick={() => act('select_beacon', { beacon_ref: beacon.ref })}>
                        <strong>{beacon.name && beacon.name.toLowerCase() !== "tracking beacon" ? beacon.name : beacon.area || "Tracking beacon"}</strong>
                        <span>{beacon.name && beacon.name.toLowerCase() !== "tracking beacon" ? beacon.area : beacon.name || "Tracking beacon"} · {beacon.availability || 'unknown'}</span>
                        <small>{beacon.coordinates}</small>
                      </button>
                    )) : <Box color="label">No tracking beacons match the search.</Box>}
                  </div>
                  <Button icon="times" disabled={!data.destination_ref || !canOperate || charging} onClick={() => act('clear_beacon')}>Clear Destination</Button>
                </>
              )}
            </Section>
          </div>
          <div>
            <Section title="02 / VERIFY TRANSFER">
              <LabeledList>
                <LabeledList.Item label="Receiver Pad">{!connected ? 'NOT LINKED' : busy ? 'BUSY' : 'AVAILABLE'}</LabeledList.Item>
                {retrieval ? (
                  <>
                    <LabeledList.Item label="Visitor Eligibility"><Box color={selectedVisitor ? 'good' : 'bad'}>{selectedVisitor ? 'ELIGIBLE' : 'NOT VERIFIED'}</Box></LabeledList.Item>
                    <LabeledList.Item label="Consent State">{pending ? 'INVITATION PENDING' : charging ? 'ACCEPTED / TRANSFERRING' : 'NOT REQUESTED'}</LabeledList.Item>
                    <LabeledList.Item label="Invitation Lockout">{data.invitation_cooldown_seconds || 0}s</LabeledList.Item>
                  </>
                ) : (
                  <>
                    <LabeledList.Item label="Passenger"><Box color={data.passenger_available ? 'good' : 'bad'}>{data.passenger_name || 'NONE'}</Box></LabeledList.Item>
                    <LabeledList.Item label="Destination">{data.destination_name || 'NONE'}</LabeledList.Item>
                    <LabeledList.Item label="Location">{data.destination_area || 'UNASSIGNED'}</LabeledList.Item>
                    <LabeledList.Item label="Landing Site"><Box color={data.destination_valid ? 'good' : 'bad'}>{data.destination_valid ? 'VALID' : data.destination_status_text || 'UNAVAILABLE'}</Box></LabeledList.Item>
                  </>
                )}
              </LabeledList>
            </Section>
            <Section title="03 / AUTHORIZE TRANSFER">
              {retrieval ? (
                <>
                  <Button icon="user-check" fluid color="good" disabled={!canRetrieval} onClick={() => act('request_retrieval')}>Request Voluntary Retrieval</Button>
                  <Box mt={1} color="label">The selected visitor must accept the invitation before a transfer can occur.</Box>
                  <Button mt={1} icon="times" color="average" disabled={observer || !charging} onClick={() => act('cancel_retrieval')}>Cancel Active Retrieval</Button>
                </>
              ) : (
                <>
                  <Button icon="exchange-alt" color="good" fluid disabled={!canDeparture} onClick={() => act('begin_transport')}>Initiate Visitor Transport</Button>
                  <Button mt={1} icon="times" color="average" disabled={!canOperate || !charging} onClick={() => act('cancel_transport')}>Cancel Transport</Button>
                </>
              )}
              <Box mt={2} color="label">{data.status_message || 'Awaiting authenticated transfer authorization.'}</Box>
            </Section>
          </div>
        </div>
      
          </Layout.Content>
        </Window.Content>
    </Window>
  );
};
