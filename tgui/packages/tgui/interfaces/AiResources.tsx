import { toFixed } from 'common/math';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Data = {
  total_assigned_cpu: number;
  total_cpu: number;
  total_ram: number;
  total_assigned_ram: number;
  authenticated: BooleanLike;
  username: string;
  user_image: string;
  has_access: boolean;
  human_only: BooleanLike;
  ais: AiData[];
};

type AiData = {
  name: string;
  ref: string;
  assigned_cpu: number;
  assigned_ram: number;
};

export const AiResources = (props) => {
  const { act, data } = useBackend<Data>();

  const {
    total_assigned_cpu,
    total_cpu,
    total_ram,
    total_assigned_ram,
    authenticated,
    username,
    user_image,
    has_access,
    human_only,
    ais = [],
  } = data;

  const remaining_cpu = total_cpu - total_assigned_cpu;
  const remaining_ram = total_ram - total_assigned_ram;

  return (
    <Window width={450} height={authenticated ? 400 : 250}>
      <Window.Content>
        {(!!authenticated && (
          <Stack vertical fill>
            <Section
              title="Cloud CPU Resources"
              buttons={
                <>
                  <Button
                    icon="male"
                    color={human_only ? 'bad' : 'good'}
                    onClick={() => act('toggle_human_status')}
                    tooltip={
                      human_only
                        ? 'This will allow Silicon to interact with the computer.'
                        : 'This will prevent Silicon from interacting with the computer.'
                    }
                  >
                    {human_only ? 'Allow Silicon Usage' : 'Ban Silicon Usage'}
                  </Button>
                  <Button
                    icon="sign-out-alt"
                    color="bad"
                    onClick={() => act('log_out')}
                  >
                    Log Out
                  </Button>
                </>
              }
            >
              <ProgressBar
                value={remaining_cpu}
                ranges={{
                  good: [0.8, Infinity],
                  average: [0.4, 0.8],
                  bad: [-Infinity, 0.4],
                }}
                maxValue={total_cpu}
              >
                {toFixed(remaining_cpu)}/{toFixed(total_cpu)} THz (
                {toFixed(remaining_cpu * 100)}%)
              </ProgressBar>
            </Section>
            <Section my={-2} title="Cloud RAM Resources">
              <ProgressBar
                ranges={{
                  good: [total_ram * 0.8, Infinity],
                  average: [total_ram * 0.4, total_ram * 0.8],
                  bad: [-Infinity, total_ram * 0.4],
                }}
                value={remaining_ram}
                maxValue={total_ram}
              >
                {remaining_ram} TB
              </ProgressBar>
            </Section>
            <Section
              my={1}
              fill
              title="Active AI's"
              style={{ overflowY: 'auto', overflowX: 'hidden' }}
            >
              <Stack vertical>
                {ais.map((ai, index) => {
                  return (
                    <Section
                      fill
                      key={index}
                      title={ai.name}
                      buttons={
                        <Button
                          icon="trash"
                          onClick={() =>
                            act('clear_ai_resources', { targetAI: ai.ref })
                          }
                        >
                          Clear AI Resources
                        </Button>
                      }
                    >
                      <Stack.Item>
                        CPU Capacity:
                        <Stack>
                          <Slider
                            minValue={0}
                            maxValue={total_cpu}
                            stepPixelSize={1}
                            value={ai.assigned_cpu}
                            unit={'THz'}
                            onChange={(_, value) =>
                              act('set_cpu', {
                                targetAI: ai.ref,
                                amount_cpu: value,
                              })
                            }
                          />
                        </Stack>
                      </Stack.Item>
                      <Stack.Item>
                        RAM Capacity:
                        <Stack>
                          <Slider
                            minValue={0}
                            maxValue={total_ram}
                            stepPixelSize={1}
                            value={ai.assigned_ram}
                            unit={'TB'}
                            onChange={(_, value) =>
                              act('set_ram', {
                                targetAI: ai.ref,
                                amount_ram: value,
                              })
                            }
                          />
                        </Stack>
                      </Stack.Item>
                    </Section>
                  );
                })}
              </Stack>
            </Section>
          </Stack>
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
            <Box textAlign="center" position="bottom">
              <NoticeBox
                textAlign="center"
                mt="1.5rem"
                color={has_access ? 'good' : 'bad'}
              >
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
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
