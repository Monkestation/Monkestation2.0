import { useBackend, useLocalState } from '../../backend';
import { Window } from '../../layouts';
import { Tabs, Flex, Button } from '../../components';

import RBMKOverview from './overview';
import RBMKControls from './controls';
import RBMKRods from './rods';
import RBMKGraphs from './graphs';

export const RBMKConsole = () => {
  const { data, act } = useBackend<any>();
  const [tab, setTab] = useLocalState<'overview' | 'controls' | 'rods' | 'graphs'>(
    'rbmk_tab',
    'overview'
  );

  return (
    <Window theme="soviet" width={832} height={576} resizable>
      <Window.Content>
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
                  disabled={data?.status !== 'No reactor linked' ? false : true}
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
