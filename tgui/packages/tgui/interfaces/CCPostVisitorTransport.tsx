import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type TransportBeacon = {
  ref: string;
  name: string;
  area: string;
  coordinates: string;
  availability?: string;
};

type Data = {
  read_only?: boolean | number;
  pad_linked?: boolean | number;
  charging?: boolean | number;
  pad_busy?: boolean | number;
  retrieval_mode?: boolean | number;
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
  beacons?: TransportBeacon[];
};

export const CCPostVisitorTransport = () => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useLocalState('ccpostVisitorTransportTab', 'transport');
  const [manualOpen, setManualOpen] = useLocalState('ccpostVisitorTransportManual', false);
  const [beaconFilter, setBeaconFilter] = useLocalState('ccpostVisitorBeaconFilter', '');

  const {
    retrieval_mode = false,
    pad_busy = false,
    request_pending = false,
    camera_active = false,
    selected_target_name = 'No visitor selected',
    selected_target_area = '',
    selected_target_valid = false,
    invitation_cooldown_seconds = 0,
    read_only = false,
    pad_linked = false,
    charging = false,
    console_operational = true,
    cooldown_seconds = 0,
    status_message = '',
    passenger_available = false,
    passenger_name = 'No eligible passenger detected on the pad.',
    destination_name = 'No destination selected',
    destination_area = '',
    destination_coordinates = '',
    destination_valid = false,
    destination_state = "missing",
    destination_status_text = "",
    destination_ref = null,
    beacons = [],
  } = data;

  const observer = Boolean(read_only);
  const padReady = Boolean(pad_linked);
  const powered = Boolean(console_operational);
  const isCharging = Boolean(charging);
  const passengerReady = Boolean(passenger_available);
  const beaconReady = Boolean(destination_valid);
  const coolingDown = cooldown_seconds > 0;
  const canOperate = !observer && powered && padReady && !Boolean(pad_busy);
  const canTransport =
    canOperate && !isCharging && !coolingDown && passengerReady && beaconReady;

  const searchTerm = beaconFilter.trim().toLowerCase();
  const filteredBeacons = beacons
    .filter((beacon) =>
      !searchTerm ||
      `${beacon.name} ${beacon.area} ${beacon.coordinates}`
        .toLowerCase()
        .includes(searchTerm),
    )
    .slice()
    .sort((a, b) => a.area.localeCompare(b.area) || a.name.localeCompare(b.name));

  const systemStatus = !powered
    ? 'OFFLINE'
    : !padReady
      ? 'PAD NOT LINKED'
      : isCharging
        ? 'CHARGING'
        : coolingDown
          ? 'COOLDOWN'
          : canTransport
            ? 'READY'
            : 'STANDBY';

  const systemStatusColor = !powered || !padReady
    ? 'bad'
    : isCharging || coolingDown
      ? 'average'
      : canTransport
        ? 'good'
        : 'label';

  if (Boolean(retrieval_mode)) {
    const canRequest = canOperate && !isCharging && !request_pending &&
      !coolingDown && invitation_cooldown_seconds <= 0 && Boolean(selected_target_valid);
    return (
      <Window title="Central Command Visitor Retrieval" width={650} height={535} theme="ntos">
        <Window.Content scrollable>
          <Stack vertical>
            {observer && <Stack.Item><NoticeBox>
              OBSERVER MODE: Read-only. Visitor retrieval requires authorized outpost personnel.
            </NoticeBox></Stack.Item>}
            <Stack.Item>
              <Section title="Visitor Retrieval Network">
                Supervised, voluntary transfer from a camera-visible station location to
                the outpost visitor reception pad. No station teleporter required.
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="System Status">
                <LabeledList>
                  <LabeledList.Item label="Telepad">
                    <Box color={!padReady || pad_busy ? 'bad' : 'good'}>
                      {!padReady ? 'NOT LINKED' : pad_busy ? 'IN USE' : 'AVAILABLE'}
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="System">
                    {!powered ? 'OFFLINE' : isCharging ? 'CHARGING (5 SECONDS)' :
                      request_pending ? 'AWAITING CONSENT (UP TO 20 SECONDS)' :
                        coolingDown ? `COOLDOWN (${cooldown_seconds}s)` : 'STANDBY'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Camera View">
                    {camera_active ? 'ACTIVE' : 'INACTIVE'}
                  </LabeledList.Item>
                  {invitation_cooldown_seconds > 0 && (
                    <LabeledList.Item label="Visitor Invitation Cooldown">
                      {invitation_cooldown_seconds}s remaining
                    </LabeledList.Item>
                  )}
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Selected Visitor" buttons={
                <Button icon="times" disabled={observer || isCharging || request_pending ||
                  !Boolean(selected_target_name && selected_target_name !== 'No visitor selected')}
                  onClick={() => act('clear_target')}>Clear Selection</Button>
              }>
                <LabeledList>
                  <LabeledList.Item label="Name">{selected_target_name}</LabeledList.Item>
                  <LabeledList.Item label="Station Area">
                    {selected_target_area || 'Not selected'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Eligibility">
                    <Box color={selected_target_valid ? 'good' : 'label'}>
                      {selected_target_valid ? 'CAMERA VISIBLE / ELIGIBLE' : 'NO ELIGIBLE VISITOR'}
                    </Box>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Retrieval Authorization">
                <Stack>
                  <Stack.Item grow>
                    <Button fluid icon="video" disabled={!canOperate || isCharging || request_pending}
                      onClick={() => act('open_camera')}>
                      Open Station Camera View
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Button fluid icon="user-check" color="good" disabled={!canRequest}
                      onClick={() => act('request_retrieval')}>
                      Request Visitor Retrieval
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button icon="times" color="average" disabled={observer || !isCharging}
                      onClick={() => act('cancel_retrieval')}>
                      Cancel
                    </Button>
                  </Stack.Item>
                </Stack>
                <Box color="label" mt={1}>
                  In camera view, use the <Box inline bold>Select Visitor</Box> action to pick
                  an eligible person, then return here to send the invitation. Declines, timeouts, and completed retrievals trigger a shared
                  25-second recalibration cooldown across all retrieval consoles.
                </Box>
                {!!status_message && <Box mt={1} color="label">{status_message}</Box>}
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      title="Central Command Visitor Transport"
      width={690}
      height={650}
      theme="ntos"
    >
      <Window.Content scrollable>
        <Stack vertical>
          {observer && (
            <Stack.Item>
              <NoticeBox>
                OBSERVER MODE: Read-only. Transport controls remain restricted to
                authorized Central Command personnel.
              </NoticeBox>
            </Stack.Item>
          )}

          <Stack.Item>
            <Section
              title="Visitor Transport Control"
              buttons={
                <Button
                  icon="question-circle"
                  onClick={() => setManualOpen(!manualOpen)}
                >
                  {manualOpen ? 'Close Manual' : 'Operating Manual'}
                </Button>
              }
            >
              <Box>
                Supervised visitor departure via registered station tracking
                beacons. Outpost personnel are not eligible for transport.
              </Box>
              {manualOpen && (
                <Box mt={1}>
                  <Box bold>VISITOR TRANSPORT PROCEDURE</Box>
                  <Box mt={0.5}>
                    Select an available station tracking beacon, direct one
                    visitor onto the linked pad, then initiate transport. The
                    five-second charging sequence is cancelled if the passenger
                    leaves or the selected destination becomes unavailable.
                  </Box>
                  <Box mt={0.5} color="label">
                    Destination selection and transport activation require an
                    authorized Central Command outpost ID.
                  </Box>
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="exchange-alt"
                selected={tab === 'transport'}
                onClick={() => setTab('transport')}
              >
                Transport Control
              </Tabs.Tab>
              <Tabs.Tab
                icon="map-marker-alt"
                selected={tab === 'beacons'}
                onClick={() => setTab('beacons')}
              >
                Tracking Beacons ({beacons.length})
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          {tab === 'transport' && (
            <>
              <Stack.Item>
                <Section title="System Status">
                  <LabeledList>
                    <LabeledList.Item label="Transport Status">
                      <Box bold color={systemStatusColor}>
                        {systemStatus}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Linked Telepad">
                      <Box color={padReady ? 'good' : 'bad'}>
                        {padReady ? 'CONNECTED' : 'NOT DETECTED'}
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Passenger">
                      <Box color={passengerReady ? 'good' : 'label'}>
                        {passenger_name}
                      </Box>
                    </LabeledList.Item>
                    {isCharging && (
                      <LabeledList.Item label="Charging">
                        <Box bold color="average">
                          Transport sequence in progress (5 seconds)
                        </Box>
                      </LabeledList.Item>
                    )}
                    {coolingDown && !isCharging && (
                      <LabeledList.Item label="Cooldown">
                        {cooldown_seconds}s remaining
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Section>
              </Stack.Item>

              <Stack.Item>
                <Section
                  title="Selected Destination"
                  buttons={
                    <>
                      <Button
                        icon="times"
                        disabled={!destination_ref || !canOperate || isCharging}
                        onClick={() => act('clear_beacon')}
                      >
                        Deselect Beacon
                      </Button>
                      <Button
                        icon="map-marker-alt"
                        onClick={() => setTab('beacons')}
                      >
                        {destination_ref ? 'Change Beacon' : 'Select Beacon'}
                      </Button>
                    </>
                  }
                >
                  <LabeledList>
                    <LabeledList.Item label="Tracking Beacon">
                      <Box bold>{destination_name}</Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Station Area">
                      {destination_area || 'Not selected'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Coordinates">
                      {destination_coordinates || 'Not selected'}
                    </LabeledList.Item>
                    <LabeledList.Item label="Lock Status">
                      <Box color={beaconReady ? 'good' : 'bad'}>
                        {beaconReady
                          ? destination_state === 'adjacent'
                            ? 'ADJACENT LANDING AVAILABLE'
                            : 'VALID STATION DESTINATION'
                          : destination_state === 'occupied'
                            ? 'TEMPORARILY OCCUPIED'
                            : 'NO VALID DESTINATION'}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                  {destination_ref && !beaconReady && (
                    <NoticeBox danger mt={1}>
                      {destination_status_text}
                    </NoticeBox>
                  )}
                </Section>
              </Stack.Item>

              <Stack.Item>
                <Section title="Transport Authorization">
                  <Stack>
                    <Stack.Item grow>
                      <Button
                        fluid
                        icon="exchange-alt"
                        color="good"
                        disabled={!canTransport}
                        onClick={() => act('begin_transport')}
                      >
                        Initiate Visitor Transport
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="times"
                        color="average"
                        disabled={!canOperate || !isCharging}
                        onClick={() => act('cancel_transport')}
                      >
                        Cancel Transport
                      </Button>
                    </Stack.Item>
                  </Stack>
                  {status_message && (
                    <Box mt={1} color="label">
                      Last system message: {status_message}
                    </Box>
                  )}
                </Section>
              </Stack.Item>
            </>
          )}

          {tab === 'beacons' && (
            <Stack.Item>
              <Section title="Registered Station Tracking Beacons">
                <Box mb={1} color="label">
                  Enabled station tracking beacons are listed, including temporarily
                  occupied destinations. The landing tile is checked again
                  before transport.
                </Box>
                <Box mb={1}>
                  <Input
                    fluid
                    placeholder="Search beacon name, area or coordinates"
                    value={beaconFilter}
                    onChange={setBeaconFilter}
                  />
                </Box>
                {!beacons.length ? (
                  <NoticeBox danger>
                    No safe station tracking beacons are currently available.
                  </NoticeBox>
                ) : !filteredBeacons.length ? (
                  <NoticeBox>No tracking beacons match this search.</NoticeBox>
                ) : (
                  <Stack vertical>
                    {filteredBeacons.map((beacon) => {
                      const selected = destination_ref === beacon.ref;
                      return (
                        <Stack.Item key={beacon.ref}>
                          <Section
                            title={`${beacon.name} | ${beacon.area}`}
                            buttons={
                              <Button
                                icon={selected ? 'check' : 'location-arrow'}
                                color={selected ? 'good' : undefined}
                                disabled={observer || !powered || !padReady || isCharging}
                                onClick={() => {
                                  act('select_beacon', { beacon_ref: beacon.ref });
                                  setTab('transport');
                                }}
                              >
                                {selected ? 'Selected' : 'Select Beacon'}
                              </Button>
                            }
                          >
                            <Box color="label">
                              Coordinates: {beacon.coordinates}
                              {beacon.availability === 'occupied' && ' | Temporarily occupied'}
                              {beacon.availability === 'adjacent' && ' | Adjacent landing available'}
                            </Box>
                          </Section>
                        </Stack.Item>
                      );
                    })}
                  </Stack>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
