import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import {
  Tabs,
  Flex,
  Button,
  Box,
  LabeledList,
  ProgressBar,
} from '../../components';

import RBMKOverview from './overview';
import RBMKControls from './controls';
import RBMKRods from './rods';
import RBMKGraphs from './graphs';
import RBMKGenerators from './generators';

const formatDeciseconds = (timeLeft: number) => {
  const totalSeconds = Math.max(Math.ceil(timeLeft / 10), 0);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;

  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
};

const RBMKCascadeLockout = () => {
  const { data } = useBackend<any>();

  const status = data?.supermatter_cascade_status || 'CONTROL LOCKOUT';
  const timeLeft = Number(data?.supermatter_cascade_time_left ?? 0);
  const maxTime = Math.max(
    Number(data?.supermatter_cascade_time_total ?? 600),
    timeLeft,
    1,
  );
  const finalCountdown = Boolean(data?.supermatter_cascade_final_countdown);
  const countdownPercent = Math.max(
    0,
    Math.min(100, Math.round((timeLeft / maxTime) * 100)),
  );

  return (
    <Box className="RBMKConsole__CascadeLockout">
      <Box className="RBMKConsole__CascadeHeader">
        <Box className="RBMKConsole__CascadeSeal">☭</Box>

        <Box className="RBMKConsole__CascadeHeaderText">
          <Box className="RBMKConsole__CascadeTitle">
            SYNDICATE OVERRIDE ACTIVE
          </Box>

          <Box className="RBMKConsole__CascadeSubtitle">
            Supermatter Rod Cascade Control Lockout
          </Box>
        </Box>

        <Box className="RBMKConsole__CascadeLock">🔒</Box>
      </Box>

      <Box
        className={
          finalCountdown
            ? 'RBMKConsole__CascadeWarning RBMKConsole__CascadeWarning--final'
            : 'RBMKConsole__CascadeWarning'
        }>
        REMOTE REACTOR CONTROL HAS BEEN FORCIBLY DISABLED
      </Box>

      <Box
        className={
          finalCountdown
            ? 'RBMKConsole__CascadeTimer RBMKConsole__CascadeTimer--final'
            : 'RBMKConsole__CascadeTimer'
        }>
        {formatDeciseconds(timeLeft)}
      </Box>

      <ProgressBar
        value={countdownPercent}
        maxValue={100}
        ranges={{
          good: [66, 100],
          yellow: [33, 66],
          bad: [12, 33],
          purple: [0, 12],
        }}>
        Cascade lockout timer
      </ProgressBar>

      <Box className="RBMKConsole__CascadeStatus">{status}</Box>

      <Box className="RBMKConsole__CascadeInfo">
        <LabeledList>
          <LabeledList.Item label="Console Status">
            Remote operation locked out
          </LabeledList.Item>

          <LabeledList.Item label="Required Action">
            Manually extract the supermatter fuel rod
          </LabeledList.Item>

          <LabeledList.Item label="Access Method">
            Fuel rod extraction tool required
          </LabeledList.Item>

          <LabeledList.Item label="Recovery">
            Automatic AZ-5 shutdown after successful rod removal
          </LabeledList.Item>
        </LabeledList>
      </Box>

      <Box className="RBMKConsole__CascadeFooter">
        WARNING: Cascade progression cannot be halted from this console.
      </Box>
    </Box>
  );
};

export const RBMKConsole = () => {
  const { act, data } = useBackend<any>();
  const [tab, setTab] = useLocalState<
    'overview' | 'controls' | 'rods' | 'graphs' | 'generators'
  >('rbmk_tab', 'overview');

  if (data?.supermatter_cascade_active) {
    return (
      <Window theme="soviet" width={560} height={500}>
        <Window.Content className="RBMKConsole" scrollable>
          <RBMKCascadeLockout />
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window theme="soviet" width={832} height={576}>
      <Window.Content className="RBMKConsole" scrollable>
        <Flex direction="column" gap={1}>
          <Flex.Item>
            <Tabs>
              <Tabs.Tab
                selected={tab === 'overview'}
                onClick={() => setTab('overview')}
                icon="gauge">
                Overview
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'controls'}
                onClick={() => setTab('controls')}
                icon="sliders">
                Controls
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'rods'}
                onClick={() => setTab('rods')}
                icon="grip-vertical">
                Rods
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'graphs'}
                onClick={() => setTab('graphs')}
                icon="chart-line">
                Graphs
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'generators'}
                onClick={() => setTab('generators')}
                icon="bolt">
                Generators
              </Tabs.Tab>

              <Flex.Item grow />

              <Tabs.Tab>
                <Button
                  icon="sync"
                  content="Rescan"
                  onClick={() => act('rescan')}
                />
              </Tabs.Tab>
            </Tabs>
          </Flex.Item>

          <Flex.Item>
            {tab === 'overview' && <RBMKOverview />}
            {tab === 'controls' && <RBMKControls />}
            {tab === 'rods' && <RBMKRods />}
            {tab === 'graphs' && <RBMKGraphs />}
            {tab === 'generators' && <RBMKGenerators />}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

export default RBMKConsole;
