import { Fragment, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Tabs,
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

  const [tab, setTab] = useState(1);

  const remaining_cpu = (1 - total_assigned_cpu) * 100;

  return (
    <Window width={500} height={450}>
      <Window.Content scrollable>
        {(!!authenticated && (
          <Fragment>
            <Tabs>
              <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
                Resource Allocation
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
                Settings
              </Tabs.Tab>
            </Tabs>
            {tab === 1 && (
              <Fragment>
                <Section
                  title="Cloud CPU Resources"
                  buttons={
                    <Button
                      icon="sign-out-alt"
                      color="bad"
                      onClick={() => act('log_out')}
                    >
                      Log Out
                    </Button>
                  }
                >
                  <ProgressBar
                    value={total_assigned_cpu}
                    ranges={{
                      good: [0.8, Infinity],
                      average: [0.4, 0.8],
                      bad: [-Infinity, 0.4],
                    }}
                    maxValue={1}
                  >
                    {total_cpu * total_assigned_cpu}/{total_cpu} THz (
                    {total_assigned_cpu * 100}%)
                  </ProgressBar>
                </Section>
                <Section title="Cloud RAM Resources">
                  <ProgressBar
                    ranges={{
                      good: [total_ram * 0.8, Infinity],
                      average: [total_ram * 0.4, total_ram * 0.8],
                      bad: [-Infinity, total_ram * 0.4],
                    }}
                    value={total_assigned_ram}
                    maxValue={total_ram}
                  >
                    {total_assigned_ram}/{total_ram} TB
                  </ProgressBar>
                </Section>
                <Section title="Active AI's">
                  <LabeledList>
                    {ais.map((ai, index) => {
                      return (
                        <Section
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
                          <LabeledList.Item>
                            CPU Capacity:
                            <Stack>
                              <ProgressBar
                                minValue={0}
                                value={total_cpu * ai.assigned_cpu}
                                maxValue={total_cpu}
                              >
                                {total_cpu * ai.assigned_cpu} THz
                              </ProgressBar>
                              <NumberInput
                                width="60px"
                                unit="%"
                                value={ai.assigned_cpu * 100}
                                minValue={0}
                                maxValue={remaining_cpu + ai.assigned_cpu * 100}
                                onChange={(value) =>
                                  act('set_cpu', {
                                    targetAI: ai.ref,
                                    amount_cpu:
                                      Math.round((value / 100) * 100) / 100,
                                  })
                                }
                              />
                              <Button
                                height={1.75}
                                icon="arrow-up"
                                onClick={() =>
                                  act('max_cpu', {
                                    targetAI: ai.ref,
                                  })
                                }
                              >
                                Max
                              </Button>
                            </Stack>
                          </LabeledList.Item>
                          <LabeledList.Item>
                            RAM Capacity:
                            <Stack>
                              <ProgressBar
                                minValue={0}
                                value={ai.assigned_ram}
                                maxValue={total_ram}
                              >
                                {ai.assigned_ram} TB
                              </ProgressBar>
                              <Button
                                mr={1}
                                ml={1}
                                height={1.75}
                                icon="plus"
                                onClick={() =>
                                  act('add_ram', {
                                    targetAI: ai.ref,
                                  })
                                }
                              />
                              <Button
                                height={1.75}
                                icon="minus"
                                onClick={() =>
                                  act('remove_ram', {
                                    targetAI: ai.ref,
                                  })
                                }
                              />
                            </Stack>
                          </LabeledList.Item>
                        </Section>
                      );
                    })}
                  </LabeledList>
                </Section>
              </Fragment>
            )}
            {tab === 2 && (
              <Section title="Settings">
                <Button
                  icon="male"
                  color={human_only ? 'bad' : 'good'}
                  onClick={() => act('toggle_human_status')}
                >
                  {human_only
                    ? 'Allow Silicon Console Usage'
                    : 'Ban Silicon Console Usage'}
                </Button>
              </Section>
            )}
          </Fragment>
        )) || (
          <Section title="Welcome">
            <Stack align="center" justify="center" mt="0.5rem">
              <Stack.Item>
                {(user_image && (
                  <Fragment style={{ position: 'relative' }}>
                    <img
                      src={user_image}
                      width="125px"
                      height="125px"
                      style={`-ms-interpolation-mode: nearest-neighbor;
                        border-radius: 50%; border: 3px solid white;
                        margin-right:-125px`}
                    />
                    <img
                      src="scanlines.png"
                      width="125px"
                      height="125px"
                      style={`-ms-interpolation-mode: nearest-neighbor;
                        border-radius: 50%; border: 3px solid white;opacity: 0.3;`}
                    />
                  </Fragment>
                )) || (
                  <Icon
                    name="user-circle"
                    verticalAlign="middle"
                    size={4.5}
                    mr="1rem"
                  />
                )}
                <Box inline fontSize="18px" bold>
                  {username ? username : 'Unknown'}
                </Box>
                <NoticeBox
                  success={has_access}
                  danger={!has_access}
                  textAlign="center"
                  mt="1.5rem"
                >
                  {has_access ? 'Access Granted' : 'Access Denied'}
                </NoticeBox>
                <Box textAlign="center">
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
              </Stack.Item>
            </Stack>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
