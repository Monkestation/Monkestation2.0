import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { Tabs, Flex, Button, Box, LabeledList } from '../../components';

import RBMKOverview from './overview';
import RBMKControls from './controls';
import RBMKRods from './rods';
import RBMKGraphs from './graphs';

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
  const finalCountdown = Boolean(data?.supermatter_cascade_final_countdown);

  return (
    <Box className="RBMKConsole__CascadeLockout">
      <Box className="RBMKConsole__CascadeLock">🔒</Box>

      <Box className="RBMKConsole__CascadeTitle">
        Syndicate Override Active
      </Box>

      <Box className="RBMKConsole__CascadeSubtitle">
        Supermatter Rod Cascade Control Lockout
      </Box>

      <Box
        className={
          finalCountdown
            ? 'RBMKConsole__CascadeTimer RBMKConsole__CascadeTimer--final'
            : 'RBMKConsole__CascadeTimer'
        }>
        {formatDeciseconds(timeLeft)}
      </Box>

      <Box className="RBMKConsole__CascadeStatus">{status}</Box>

      <Box className="RBMKConsole__CascadeInfo">
        <LabeledList>
          <LabeledList.Item label="Console">
            Remote reactor control disabled
          </LabeledList.Item>
          <LabeledList.Item label="Required Action">
            Manually remove the supermatter fuel rod
          </LabeledList.Item>
          <LabeledList.Item label="Recovery">
            Automatic SCRAM after successful rod removal
          </LabeledList.Item>
        </LabeledList>
      </Box>
    </Box>
  );
};

export const RBMKConsole = () => {
  const { act, data } = useBackend<any>();
  const [tab, setTab] = useLocalState<'overview' | 'controls' | 'rods' | 'graphs'>(
    'rbmk_tab',
    'overview',
  );

  if (data?.supermatter_cascade_active) {
    return (
      <Window theme="soviet" width={560} height={500}>
        <Window.Content className="RBMKConsole">
          <RBMKCascadeLockout />
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window theme="soviet" width={832} height={576}>
      <Window.Content className="RBMKConsole">
        <Flex direction="column" height="100%">
          <Flex.Item grow>
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

              <Flex.Item grow />

              <Tabs.Tab>
                <Button
                  icon="sync"
                  content="Rescan"
                  onClick={() => act('rescan')}
                />
              </Tabs.Tab>
            </Tabs>

            {tab === 'overview' && <RBMKOverview />}
            {tab === 'controls' && <RBMKControls />}
            {tab === 'rods' && <RBMKRods />}
            {tab === 'graphs' && <RBMKGraphs />}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

export default RBMKConsole;
