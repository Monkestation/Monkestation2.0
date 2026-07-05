import type { BooleanLike } from 'common/react';
import { Fragment, useState } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type Data = {
  authenticated: BooleanLike;
  has_access: boolean;
  username: string;
  intellicard: string[];
  intellicard_ai: string[];
  can_log_out: BooleanLike;
  intellicard_ai_health: number;
  can_upload: BooleanLike;
  downloading: BooleanLike;
  download_progress: number;
  current_ai_ref: string;
  downloading_ref: string;
  ais: AiData[];
  is_servant_of_ratvar: BooleanLike;
};

type AiData = {
  name: string;
  in_core: BooleanLike;
  active: BooleanLike;
  can_download: BooleanLike;
  ref: string;
  health: number;
  being_cogged: BooleanLike;
};

export const AiControlPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    authenticated,
    username,
    has_access,
    intellicard,
    intellicard_ai,
    can_log_out,
    intellicard_ai_health,
    can_upload,
    downloading,
    download_progress,
    current_ai_ref,
    downloading_ref,
    ais,
    is_servant_of_ratvar,
  } = data;

  const [tab, setTab] = useState(1);

  return (
    <Window width={500} height={330}>
      <Window.Content scrollable>
        {(!!authenticated && (
          <Section fill>
            <Stack vertical>
              <Stack.Item>
                <Tabs fluid>
                  <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
                    Upload
                  </Tabs.Tab>
                  <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
                    Download
                  </Tabs.Tab>
                </Tabs>
              </Stack.Item>
              <Stack.Item>
                {tab === 1 && (
                  <Section
                    title="Upload"
                    buttons={
                      <Fragment>
                        <Button
                          onClick={() => act('eject_intellicard')}
                          color="bad"
                          icon="eject"
                          tooltip="Ejects IntelliCard, cancelling any current downloads"
                          disabled={!intellicard}
                        >
                          Eject IntelliCard
                        </Button>
                        <Button
                          icon="sign-out-alt"
                          color="bad"
                          tooltip={
                            !can_log_out
                              ? 'This console has administrator privileges and cannot be logged out of.'
                              : null
                          }
                          disabled={!can_log_out}
                          onClick={() => act('log_out')}
                        >
                          Log Out
                        </Button>
                      </Fragment>
                    }
                  >
                    <NoticeBox>
                      Upload also possible by inserting an MMI or Positronic
                      Brain
                    </NoticeBox>
                    {(!intellicard && (
                      <Stack align="center" justify="center">
                        <Stack.Item>
                          <NoticeBox>No IntelliCard inserted!</NoticeBox>
                        </Stack.Item>
                      </Stack>
                    )) || (
                      <Box>
                        {(intellicard_ai && (
                          <Stack align="center" justify="center">
                            <Stack.Item width="50%">
                              <Section
                                textAlign="center"
                                title={intellicard_ai}
                              >
                                <ProgressBar
                                  ranges={{
                                    good: [75, Infinity],
                                    average: [25, 75],
                                    bad: [-Infinity, 25],
                                  }}
                                  mb={0.75}
                                  minValue={0}
                                  maxValue={100}
                                  value={intellicard_ai_health}
                                />
                                <Button
                                  color="good"
                                  icon="upload"
                                  disabled={!can_upload}
                                  tooltip={
                                    !can_upload
                                      ? 'A common cause of upload being unavailable is a lack of any active AI data cores.'
                                      : null
                                  }
                                  onClick={() => act('upload_intellicard')}
                                >
                                  Upload
                                </Button>
                              </Section>
                            </Stack.Item>
                          </Stack>
                        )) || (
                          <Stack align="center" justify="center">
                            <Stack.Item>
                              <NoticeBox>Intellicard contains no AI!</NoticeBox>
                            </Stack.Item>
                          </Stack>
                        )}
                      </Box>
                    )}
                  </Section>
                )}
                {tab === 2 && (
                  <Section
                    title="AIs Available for Download"
                    buttons={
                      <Fragment>
                        <Button
                          onClick={() => act('eject_intellicard')}
                          color="bad"
                          icon="eject"
                          tooltip="Ejects IntelliCard, cancelling any current downloads"
                          disabled={!intellicard}
                        >
                          Eject IntelliCard
                        </Button>
                        <Button
                          icon="sign-out-alt"
                          color="bad"
                          tooltip={
                            !can_log_out
                              ? 'This console has administrator privileges and cannot be logged out of.'
                              : null
                          }
                          disabled={!can_log_out}
                          onClick={() => act('log_out')}
                        >
                          Log Out
                        </Button>
                      </Fragment>
                    }
                  >
                    {(downloading && (
                      <Fragment>
                        <NoticeBox mb={0.1} danger>
                          Currently downloading {downloading}
                        </NoticeBox>
                        <ProgressBar
                          color="bad"
                          minValue={0}
                          value={download_progress}
                          maxValue={100}
                        />
                        <Button.Confirm
                          mt={0.5}
                          fluid
                          color="bad"
                          icon="stop"
                          textAlign="center"
                          onClick={() => act('stop_download')}
                        >
                          Cancel Download
                        </Button.Confirm>
                        {!!current_ai_ref &&
                          current_ai_ref === downloading_ref && (
                            <Button
                              color="average"
                              icon="download"
                              onClick={() => act('skip_download')}
                            >
                              Instantly finish download
                            </Button>
                          )}
                      </Fragment>
                    )) || (
                      <Box>
                        {ais
                          .filter((ai) => {
                            return !!ai.in_core;
                          })
                          .map((ai, index) => {
                            return (
                              <Section
                                key={index}
                                title={
                                  <Box
                                    inline
                                    color={ai.active ? 'good' : 'bad'}
                                  >
                                    {ai.name} |{' '}
                                    {ai.active ? 'Active' : 'Inactive'}
                                  </Box>
                                }
                                buttons={
                                  <Fragment>
                                    <Button
                                      color={ai.can_download ? 'good' : 'bad'}
                                      tooltip={
                                        !intellicard
                                          ? ai.can_download
                                            ? 'Requires IntelliCard'
                                            : '&¤!65%'
                                          : null
                                      }
                                      disabled={
                                        intellicard ? !ai.can_download : true
                                      }
                                      icon="download"
                                      onClick={() =>
                                        act('start_download', {
                                          download_target: ai.ref,
                                        })
                                      }
                                    >
                                      {ai.can_download ? 'Download' : '&gr4&!/'}
                                    </Button>
                                    {!!is_servant_of_ratvar &&
                                      !ai.being_cogged && (
                                        <Button
                                          color="good"
                                          tooltip="Requires an integration cog"
                                          icon="download"
                                          onClick={() =>
                                            act('start_cog', {
                                              target_ai: ai.ref,
                                            })
                                          }
                                        >
                                          Start integrating
                                        </Button>
                                      )}
                                    {!!ai.being_cogged && (
                                      <Button
                                        color="bad"
                                        icon="stop"
                                        onClick={() =>
                                          act('stop_cog', { target_ai: ai.ref })
                                        }
                                      >
                                        Stop integrating
                                      </Button>
                                    )}
                                  </Fragment>
                                }
                              >
                                <Box bold>Integrity:</Box>
                                <ProgressBar
                                  mt={0.5}
                                  minValue={0}
                                  ranges={{
                                    good: [75, Infinity],
                                    average: [25, 75],
                                    bad: [-Infinity, 25],
                                  }}
                                  value={ai.health}
                                  maxValue={100}
                                />
                              </Section>
                            );
                          })}
                      </Box>
                    )}
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Section>
        )) || (
          <Section title="Welcome" fill>
            <Stack align="center" justify="center" mt="0.5rem" mb="0.5rem">
              <Stack.Item>
                <Stack vertical fill>
                  <Box inline fontSize="18px" bold>
                    {(data.user_image && (
                      <>
                        <img
                          src={data.user_image}
                          width="125px"
                          height="125px"
                        />
                        <img src="scanlines.png" width="125px" height="125px" />
                      </>
                    )) || (
                      <Icon
                        name="user-circle"
                        verticalAlign="middle"
                        size={4.5}
                        mr="1rem"
                      />
                    )}
                    {username ? username : 'Unknown'}
                  </Box>
                </Stack>
              </Stack.Item>
            </Stack>
            <Stack vertical textAlign="center">
              <Stack.Item my={1}>
                <Input
                  fluid
                  placeholder="123456"
                  onEnter={(value) => {
                    act('log_in_control_code', { control_code: value });
                  }}
                />
              </Stack.Item>
              <Stack.Item>
                <NoticeBox color={has_access ? 'good' : 'bad'}>
                  {has_access ? 'Access Granted' : 'Access Denied'}
                </NoticeBox>
                <Button
                  icon="sign-in-alt"
                  color={has_access ? 'good' : 'bad'}
                  fluid
                  onClick={() => {
                    act('log_in');
                  }}
                >
                  Log In
                </Button>
              </Stack.Item>
              <Stack.Item>
                <NoticeBox my={1} color="red">
                  Alternatively you can use the AI Control Code as a one-time
                  password. This will alert the station of your location and
                  name.
                </NoticeBox>
              </Stack.Item>
            </Stack>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
