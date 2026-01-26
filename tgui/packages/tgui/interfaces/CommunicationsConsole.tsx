import { sortBy } from 'common/collections';
import { capitalize } from 'common/string';
import { type JSX, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  Blink,
  Box,
  Button,
  Dimmer,
  Flex,
  Icon,
  Modal,
  Section,
  TextArea,
} from '../components';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';
import { StatusDisplayControls } from './common/StatusDisplayControls';

const STATE_BUYING_SHUTTLE = 'buying_shuttle';
const STATE_CHANGING_STATUS = 'changing_status';
const STATE_MAIN = 'main';
const STATE_MESSAGES = 'messages';

// Used for whether or not you need to swipe to confirm an alert level change
const SWIPE_NEEDED = 'SWIPE_NEEDED';

const EMAG_SHUTTLE_NOTICE =
  'This shuttle is deemed significantly dangerous to the crew, and is only supplied by the Syndicate.';

// Shared / base data always present
export type CommunicationsBaseData = {
  authenticated: BooleanLike;
  emagged: BooleanLike;
  syndicate: BooleanLike;
  hasConnection: BooleanLike;

  canRequestSafeCode: BooleanLike;
  safeCodeDeliveryWait: number;
  safeCodeDeliveryArea: string | null;

  callShuttleReasonMinLength: number;
  maxStatusLineLength: number;
  maxMessageLength: number;
  settableLevels: string[];
};

// Only present when authenticated OR silicon
export type CommunicationsAuthedData = CommunicationsBaseData & {
  authenticated: true;
  canLogOut: BooleanLike;
  page: CommunicationsPage;
};

// Page enum (matches DM states)
export type CommunicationsPage =
  | typeof STATE_MAIN
  | typeof STATE_MESSAGES
  | typeof STATE_BUYING_SHUTTLE
  | typeof STATE_CHANGING_STATUS;

/* ---------------- STATE_MAIN ---------------- */

export type CommunicationsMainData<Page = typeof STATE_MAIN> =
  CommunicationsAuthedData & {
    page: Page;

    canBuyShuttles: BooleanLike;
    canMakeAnnouncement: BooleanLike;
    canMessageAssociates: BooleanLike;
    canRecallShuttles: BooleanLike;
    canRequestNuke: BooleanLike;
    canSendToSectors: BooleanLike;
    canSetAlertLevel: false | 'NO_SWIPE_NEEDED' | 'SWIPE_NEEDED';
    canToggleEmergencyAccess: BooleanLike;

    importantActionReady: BooleanLike;

    shuttleCalled: BooleanLike;
    shuttleRecallable?: BooleanLike;
    shuttleCalledPreviously?: BooleanLike;
    shuttleLastCalled: false | string;

    aprilFools: BooleanLike;

    alertLevel: string;
    alertLevelTick?: number;

    authorizeName: string;

    shuttleCanEvacOrFailReason: boolean | string;

    emergencyAccess?: BooleanLike;

    sectors?: string[];
  };

/* ---------------- STATE_MESSAGES ---------------- */

export type CommunicationsMessage = {
  answered: BooleanLike;
  content: string;
  title: string;
  possibleAnswers: string[];
};

export type CommunicationsMessagesData = CommunicationsAuthedData & {
  page: typeof STATE_MESSAGES;
  messages: CommunicationsMessage[];
};

/* ---------------- STATE_BUYING_SHUTTLE ---------------- */

export type CommunicationsShuttle = {
  name: string;
  description: string;
  occupancy_limit: number;
  creditCost: number;
  initial_cost: number;
  emagOnly: BooleanLike;
  prerequisites: string[];
  ref: string;
};

export type CommunicationsBuyingShuttleData = CommunicationsAuthedData & {
  page: typeof STATE_BUYING_SHUTTLE;
  budget: number;
  shuttles: CommunicationsShuttle[];
};

/* ---------------- STATE_CHANGING_STATUS ---------------- */

export type CommunicationsChangingStatusData = CommunicationsAuthedData & {
  page: typeof STATE_CHANGING_STATUS;
  upperText: string;
  lowerText: string;
};

/* ---------------- UNION ---------------- */

export type CommunicationsData =
  | CommunicationsBaseData
  | CommunicationsMainData
  | CommunicationsMessagesData
  | CommunicationsBuyingShuttleData
  | CommunicationsChangingStatusData;

type AlertLevelConfirmState =
  | { open: false }
  | {
      open: true;
      alertLevel: string;
      tick?: number;
    };

const sortShuttles = sortBy<CommunicationsShuttle>(
  (shuttle) => !shuttle.emagOnly,
  (shuttle) => shuttle.initial_cost,
);

type AlertButtonProps = {
  alertLevel: string;
  setAlertConfirm: (value: AlertLevelConfirmState) => void;
};

const AlertButton = ({
  alertLevel,
  setAlertConfirm: setShowAlertLevelConfirm,
}: AlertButtonProps) => {
  const { act, data } = useBackend<CommunicationsMainData>();
  const { alertLevelTick, canSetAlertLevel } = data;

  const thisIsCurrent = data.alertLevel === alertLevel;

  return (
    <Button
      icon="exclamation-triangle"
      color={thisIsCurrent && 'good'}
      onClick={() => {
        if (thisIsCurrent) return;

        if (canSetAlertLevel === 'SWIPE_NEEDED') {
          setShowAlertLevelConfirm({
            open: true,
            alertLevel,
            tick: alertLevelTick,
          });
        } else {
          act('changeSecurityLevel', {
            newSecurityLevel: alertLevel,
          });
        }
      }}
    >
      {capitalize(alertLevel)}
    </Button>
  );
};

type MessageModalProps = {
  /** Label shown above the textarea */
  label: string;
  /** Placeholder text for the input */
  placeholder?: string;

  /** Button text for submit */
  buttonText: string;

  /** Icon for submit button */
  icon?: string;

  /** Minimum required message length */
  minLength?: number;

  /** Optional notice shown under buttons */
  notice?: string;

  /** Called with the final message */
  onSubmit: (message: string) => void;

  /** Called when cancel/back is pressed */
  onBack: () => void;
};

const MessageModal = (props: MessageModalProps) => {
  const { data } = useBackend<CommunicationsBaseData>();
  const { maxMessageLength } = data;

  const [input, setInput] = useState('');

  const longEnough =
    props.minLength === undefined || input.length >= props.minLength;

  return (
    <Modal>
      <Flex direction="column">
        <Flex.Item fontSize="16px" maxWidth="90vw" mb={1}>
          {props.label}:
        </Flex.Item>

        <Flex.Item mr={2} mb={1}>
          <TextArea
            fluid
            height="20vh"
            width="80vw"
            backgroundColor="black"
            textColor="white"
            onChange={(value) => {
              setInput(value.substring(0, maxMessageLength));
            }}
            value={input}
            placeholder={props.placeholder}
          />
        </Flex.Item>

        <Flex.Item>
          <Button
            icon={props.icon}
            content={props.buttonText}
            color="good"
            disabled={!longEnough}
            tooltip={!longEnough ? 'You need a longer reason.' : ''}
            tooltipPosition="right"
            onClick={() => {
              if (longEnough) {
                setInput('');
                props.onSubmit(input);
              }
            }}
          />

          <Button
            icon="times"
            content="Cancel"
            color="bad"
            onClick={props.onBack}
          />
        </Flex.Item>

        {!!props.notice && (
          <Flex.Item maxWidth="90vw">{props.notice}</Flex.Item>
        )}
      </Flex>
    </Modal>
  );
};

const NoConnectionModal = () => {
  return (
    <Dimmer>
      <Flex direction="column" textAlign="center" width="300px">
        <Flex.Item>
          <Icon color="red" name="wifi" size={10} />

          <Blink>
            <div
              style={{
                background: '#db2828',
                bottom: '60%',
                left: '25%',
                height: '10px',
                position: 'relative',
                transform: 'rotate(45deg)',
                width: '150px',
              }}
            />
          </Blink>
        </Flex.Item>

        <Flex.Item fontSize="16px">
          A connection to the station cannot be established.
        </Flex.Item>
      </Flex>
    </Dimmer>
  );
};

const PageBuyingShuttle = () => {
  const { act, data } = useBackend<CommunicationsBuyingShuttleData>();

  return (
    <Box>
      <Section>
        <Button
          icon="chevron-left"
          onClick={() => act('setState', { state: STATE_MAIN })}
        >
          Back
        </Button>
      </Section>

      <Section>
        Budget: <b>{data.budget.toLocaleString()}</b> credits
      </Section>

      {sortShuttles(data.shuttles).map((shuttle) => (
        <Section
          title={
            <span
              style={{
                display: 'inline-block',
                width: '70%',
              }}
            >
              {shuttle.name}
            </span>
          }
          key={shuttle.ref}
          buttons={
            <Button
              color={shuttle.emagOnly ? 'red' : 'default'}
              disabled={data.budget < shuttle.creditCost}
              onClick={() =>
                act('purchaseShuttle', {
                  shuttle: shuttle.ref,
                })
              }
              tooltip={
                data.budget < shuttle.creditCost
                  ? `You need ${shuttle.creditCost - data.budget} more credits.`
                  : shuttle.emagOnly
                    ? EMAG_SHUTTLE_NOTICE
                    : undefined
              }
              tooltipPosition="left"
            >
              {`${shuttle.creditCost.toLocaleString()} credits`}
            </Button>
          }
        >
          <Box>{shuttle.description}</Box>
          <Box color="teal" fontSize="10px" italic>
            Occupancy Limit: {shuttle.occupancy_limit}
          </Box>
          <Box color="violet" fontSize="10px" bold>
            {shuttle.prerequisites ? (
              <b>Prerequisitces: {shuttle.prerequisites}</b>
            ) : null}
          </Box>
        </Section>
      ))}
    </Box>
  );
};

const PageChangingStatus = () => {
  const { act } = useBackend();

  return (
    <Box>
      <Section>
        <Button
          icon="chevron-left"
          content="Back"
          onClick={() => act('setState', { state: STATE_MAIN })}
        />
      </Section>

      <StatusDisplayControls />
    </Box>
  );
};

const PageMain = () => {
  const { act, data } = useBackend<CommunicationsMainData>();
  const {
    alertLevel,
    alertLevelTick,
    aprilFools,
    callShuttleReasonMinLength,
    canBuyShuttles,
    canMakeAnnouncement,
    canMessageAssociates,
    canRecallShuttles,
    canRequestNuke,
    canSendToSectors,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    emagged,
    syndicate,
    emergencyAccess,
    importantActionReady,
    sectors,
    settableLevels,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleCanEvacOrFailReason,
    shuttleLastCalled,
    shuttleRecallable,
  } = data;

  const [callingShuttle, setCallingShuttle] = useState<boolean>(false);
  const [messagingAssociates, setMessagingAssociates] =
    useState<boolean>(false);
  const [messagingSector, setMessagingSector] = useState<string | null>(null);
  const [requestingNukeCodes, setRequestingNukeCodes] =
    useState<boolean>(false);

  const [alertLevelConfirm, setAlertConfirm] = useState<AlertLevelConfirmState>(
    {
      open: false,
    },
  );

  const shuttleDisabled = typeof shuttleCanEvacOrFailReason === 'string';

  return (
    <Box>
      {!syndicate && (
        <Section title="Emergency Shuttle">
          {(!!shuttleCalled && (
            <Button.Confirm
              icon="space-shuttle"
              content="Recall Emergency Shuttle"
              color="bad"
              disabled={!canRecallShuttles || !shuttleRecallable}
              tooltip={
                (canRecallShuttles &&
                  !shuttleRecallable &&
                  "It's too late for the emergency shuttle to be recalled.") ||
                'You do not have permission to recall the emergency shuttle.'
              }
              tooltipPosition="bottom-end"
              onClick={() => act('recallShuttle')}
            />
          )) || (
            <Button
              icon="space-shuttle"
              disabled={shuttleDisabled}
              tooltip={
                typeof shuttleCanEvacOrFailReason === 'string'
                  ? shuttleCanEvacOrFailReason
                  : undefined
              }
              tooltipPosition="bottom-end"
              onClick={() => setCallingShuttle(true)}
            >
              Call Emergency Shuttle
            </Button>
          )}
          {!!shuttleCalledPreviously &&
            ((shuttleLastCalled && (
              <Box>
                Most recent shuttle call/recall traced to:{' '}
                <b>{shuttleLastCalled}</b>
              </Box>
            )) || (
              <Box>Unable to trace most recent shuttle/recall signal.</Box>
            ))}
        </Section>
      )}

      {!!canSetAlertLevel && (
        <Section title="Alert Level">
          <Flex justify="space-between">
            <Flex.Item>
              <Box>
                Currently on <b>{capitalize(alertLevel)}</b> Alert
              </Box>
            </Flex.Item>

            <Flex.Item>
              {settableLevels.map((level) => (
                <AlertButton
                  key={level}
                  alertLevel={level}
                  setAlertConfirm={setAlertConfirm}
                />
              ))}
            </Flex.Item>
          </Flex>
        </Section>
      )}

      <Section title="Functions">
        <Flex direction="column">
          {!!canMakeAnnouncement && (
            <Button
              icon="bullhorn"
              content="Make Priority Announcement"
              onClick={() => act('makePriorityAnnouncement')}
            />
          )}

          {!!canToggleEmergencyAccess && (
            <Button.Confirm
              icon="id-card-o"
              content={`${
                emergencyAccess ? 'Disable' : 'Enable'
              } Emergency Maintenance Access`}
              color={emergencyAccess ? 'bad' : undefined}
              onClick={() => act('toggleEmergencyAccess')}
            />
          )}

          {!syndicate && (
            <Button
              icon="desktop"
              content="Set Status Display"
              onClick={() => act('setState', { state: STATE_CHANGING_STATUS })}
            />
          )}

          <Button
            icon="envelope-o"
            content="Message List"
            onClick={() => act('setState', { state: STATE_MESSAGES })}
          />

          {canBuyShuttles !== 0 && (
            <Button
              icon="shopping-cart"
              content="Purchase Shuttle"
              disabled={canBuyShuttles !== 1}
              // canBuyShuttles is a string detailing the fail reason
              // if one can be given
              tooltip={canBuyShuttles !== 1 ? canBuyShuttles : undefined}
              tooltipPosition="top"
              onClick={() => act('setState', { state: STATE_BUYING_SHUTTLE })}
            />
          )}

          {!!canMessageAssociates && (
            <Button
              icon="comment-o"
              content={`Send message to ${emagged ? '[UNKNOWN]' : 'CentCom'}`}
              disabled={!importantActionReady}
              onClick={() => setMessagingAssociates(true)}
            />
          )}

          {!!canRequestNuke && (
            <Button
              icon="radiation"
              content="Request Nuclear Authentication Codes"
              disabled={!importantActionReady}
              onClick={() => setRequestingNukeCodes(true)}
            />
          )}

          {!!emagged && !syndicate && (
            <Button
              icon="undo"
              content="Restore Backup Routing Data"
              onClick={() => act('restoreBackupRoutingData')}
            />
          )}
        </Flex>
      </Section>

      {!!canMessageAssociates && messagingAssociates && (
        <MessageModal
          label={`Message to transmit to ${
            emagged ? '[ABNORMAL ROUTING COORDINATES]' : 'CentCom'
          } via quantum entanglement`}
          notice="Please be aware that this process is very expensive, and abuse will lead to...termination. Transmission does not guarantee a response."
          icon="bullhorn"
          buttonText="Send"
          onBack={() => setMessagingAssociates(false)}
          onSubmit={(message) => {
            setMessagingAssociates(false);
            act('messageAssociates', {
              message,
            });
          }}
        />
      )}

      {!!canRequestNuke && requestingNukeCodes && (
        <MessageModal
          label="Reason for requesting nuclear self-destruct codes"
          notice="Misuse of the nuclear request system will not be tolerated under any circumstances. Transmission does not guarantee a response."
          icon="bomb"
          buttonText="Request Codes"
          onBack={() => setRequestingNukeCodes(false)}
          onSubmit={(reason) => {
            setRequestingNukeCodes(false);
            act('requestNukeCodes', {
              reason,
            });
          }}
        />
      )}

      {!!callingShuttle && (
        <MessageModal
          label="Nature of emergency"
          icon="space-shuttle"
          buttonText="Call Shuttle"
          minLength={callShuttleReasonMinLength}
          onBack={() => setCallingShuttle(false)}
          onSubmit={(reason) => {
            setCallingShuttle(false);
            act('callShuttle', {
              reason,
            });
          }}
        />
      )}

      {!!canSetAlertLevel &&
        alertLevelConfirm.open &&
        alertLevelConfirm.tick === alertLevelTick && (
          <Modal>
            <Flex direction="column" textAlign="center" width="300px">
              <Flex.Item fontSize="16px" mb={2}>
                Swipe ID to confirm change
              </Flex.Item>

              <Flex.Item mr={2} mb={1}>
                <Button
                  icon="id-card-o"
                  content="Swipe ID"
                  color="good"
                  fontSize="16px"
                  onClick={() =>
                    act('changeSecurityLevel', {
                      newSecurityLevel: alertLevelConfirm.alertLevel,
                    })
                  }
                />

                <Button
                  icon="times"
                  color="bad"
                  fontSize="16px"
                  onClick={() =>
                    setAlertConfirm({
                      open: false,
                    })
                  }
                >
                  Cancel
                </Button>
              </Flex.Item>
            </Flex>
          </Modal>
        )}

      {!!canSendToSectors && sectors!.length > 0 && (
        <Section title="Allied Sectors">
          <Flex direction="column">
            {sectors!.map((sectorName) => (
              <Flex.Item key={sectorName}>
                <Button
                  content={`Send a message to station in ${sectorName} sector`}
                  disabled={!importantActionReady}
                  onClick={() => setMessagingSector(sectorName)}
                />
              </Flex.Item>
            ))}

            {sectors!.length > 2 && (
              <Flex.Item>
                <Button
                  content="Send a message to all allied stations"
                  disabled={!importantActionReady}
                  onClick={() => setMessagingSector('all')}
                />
              </Flex.Item>
            )}
          </Flex>
        </Section>
      )}

      {!!canSendToSectors && sectors!.length > 0 && messagingSector && (
        <MessageModal
          label="Message to send to allied station"
          notice="Please be aware that this process is very expensive, and abuse will lead to...termination."
          icon="bullhorn"
          buttonText="Send"
          onBack={() => setMessagingSector(null)}
          onSubmit={(message) => {
            act('sendToOtherSector', {
              destination: messagingSector,
              message,
            });

            setMessagingSector(null);
          }}
        />
      )}
    </Box>
  );
};

const PageMessages = (props) => {
  const { act, data } = useBackend<CommunicationsMessagesData>();
  const messages = data.messages || [];

  const children: JSX.Element[] = [];

  children.push(
    <Section>
      <Button
        icon="chevron-left"
        onClick={() => act('setState', { state: STATE_MAIN })}
      >
        Back
      </Button>
    </Section>,
  );

  const messageElements: JSX.Element[] = [];

  for (const [messageIndex, message] of Object.entries(messages)) {
    const answers: JSX.Element | null =
      message.possibleAnswers.length > 0 ? (
        <Box mt={1}>
          {message.possibleAnswers.map((answer, answerIndex) => (
            <Button
              content={answer}
              color={message.answered === answerIndex + 1 ? 'good' : undefined}
              key={answerIndex}
              onClick={
                message.answered
                  ? undefined
                  : () =>
                      act('answerMessage', {
                        message: parseInt(messageIndex, 10) + 1,
                        answer: answerIndex + 1,
                      })
              }
            />
          ))}
        </Box>
      ) : null;

    const textHtml = {
      __html: sanitizeText(message.content),
    };

    messageElements.push(
      <Section
        title={message.title}
        key={messageIndex}
        buttons={
          <Button.Confirm
            icon="trash"
            color="red"
            onClick={() =>
              act('deleteMessage', {
                message: messageIndex + 1,
              })
            }
          >
            Delete
          </Button.Confirm>
        }
      >
        <Box dangerouslySetInnerHTML={textHtml} />

        {answers}
      </Section>,
    );
  }

  children.push(...messageElements.reverse());

  return children;
};

export const CommunicationsConsole = (props) => {
  const { act, data } =
    useBackend<CommunicationsMainData<CommunicationsPage>>();
  const {
    authenticated,
    authorizeName,
    canLogOut,
    emagged,
    hasConnection,
    page,
    canRequestSafeCode,
    safeCodeDeliveryWait,
    safeCodeDeliveryArea,
  } = data;

  return (
    <Window width={400} height={650} theme={emagged ? 'syndicate' : undefined}>
      <Window.Content scrollable>
        {!hasConnection && <NoConnectionModal />}

        {(canLogOut || !authenticated) && (
          <Section title="Authentication">
            <Button
              icon={authenticated ? 'sign-out-alt' : 'sign-in-alt'}
              content={
                authenticated
                  ? `Log Out${authorizeName ? ` (${authorizeName})` : ''}`
                  : 'Log In'
              }
              color={authenticated ? 'bad' : 'good'}
              onClick={() => act('toggleAuthentication')}
            />
          </Section>
        )}

        {(!!canRequestSafeCode && (
          <Section title="Emergency Safe Code">
            <Button
              icon="key"
              content="Request Safe Code"
              color="good"
              onClick={() => act('requestSafeCodes')}
            />
          </Section>
        )) ||
          (!!safeCodeDeliveryWait && (
            <Section title="Emergency Safe Code Delivery">
              {`Drop pod to ${safeCodeDeliveryArea} in \
            ${Math.round(safeCodeDeliveryWait / 10)}s`}
            </Section>
          ))}

        {!!authenticated &&
          ((page === STATE_BUYING_SHUTTLE && <PageBuyingShuttle />) ||
            (page === STATE_CHANGING_STATUS && <PageChangingStatus />) ||
            (page === STATE_MAIN && <PageMain />) ||
            (page === STATE_MESSAGES && <PageMessages />) || (
              <Box>Page not implemented: {page}</Box>
            ))}
      </Window.Content>
    </Window>
  );
};
