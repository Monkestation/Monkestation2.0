import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  NoticeBox,
  ProgressBar,
  Tabs,
} from '../../components';
import { Window } from '../../layouts';
import RBMKControls from './controls';
import RBMKGenerators from './generators';
import RBMKGraphs from './graphs';
import RBMKOverview from './overview';
import RBMKRods from './rods';

const RBMKCascadeLockout = () => {
  const { data } = useBackend<any>();

  const timeLeft = Number(data?.supermatter_cascade_time_left ?? 0);
  const totalTime = Math.max(
    Number(data?.supermatter_cascade_time_total ?? 50),
    1,
  );
  const finalCountdown = Boolean(data?.supermatter_cascade_final_countdown);
  const totalSeconds = Math.max(Math.ceil(timeLeft / 10), 0);
  const countdownMinutes = Math.floor(totalSeconds / 60);
  const countdownSeconds = totalSeconds % 60;
  const formattedCountdown = `${countdownMinutes}:${countdownSeconds
    .toString()
    .padStart(2, '0')}`;
  const countdownPercent = Math.max(0, Math.min(100, (timeLeft / totalTime) * 100));

  return (
    <Box className="RBMKConsole__CascadeLockout">
      <Box className="RBMKConsole__CascadeHeader">
        <Box className="RBMKConsole__CascadeBrand">
          <Box className="RBMKConsole__CascadeBrandMark">
            <Icon name="radiation" />
          </Box>
          <Box>
            <Box className="RBMKConsole__CascadeEyebrow">
              Reactor Protection System / Unit 04
            </Box>
            <Box className="RBMKConsole__CascadeTitle">
              Remote Safety Interlock
            </Box>
          </Box>
        </Box>

        <Box className="RBMKConsole__CascadeFaultCode">
          <Box className="RBMKConsole__CascadeFaultCodeLabel">FAULT CODE</Box>
          <Box className="RBMKConsole__CascadeFaultCodeValue">RPS-C5</Box>
        </Box>
      </Box>

      <Box className="RBMKConsole__CascadeStatusRail">
        <Box className="RBMKConsole__CascadeStatusCell RBMKConsole__CascadeStatusCell--failed">
          <Icon name="lock" /> CONTROL LINK INHIBITED
        </Box>
        <Box className="RBMKConsole__CascadeStatusCell RBMKConsole__CascadeStatusCell--failed">
          <Icon name="power-off" /> AZ-5 UNAVAILABLE
        </Box>
        <Box className="RBMKConsole__CascadeStatusCell RBMKConsole__CascadeStatusCell--live">
          <Icon name="tower-broadcast" /> LOCAL ANNUNCIATOR ACTIVE
        </Box>
      </Box>

      <Box
        className={
          finalCountdown
            ? 'RBMKConsole__CascadePrimary RBMKConsole__CascadePrimary--terminal'
            : 'RBMKConsole__CascadePrimary'
        }
      >
        <Box className="RBMKConsole__CascadeHazardIcon">
          <Icon name="triangle-exclamation" />
        </Box>
        <Box className="RBMKConsole__CascadePrimaryContent">
          <Box className="RBMKConsole__CascadeKicker">
            {finalCountdown ? 'Terminal failure sequence' : 'Priority one hazard'}
          </Box>
          <Box className="RBMKConsole__CascadeHazardTitle">
            Supermatter Resonance Cascade
          </Box>
          <Box className="RBMKConsole__CascadeHazardCopy">
            Remote shutdown commands are being rejected by the reactor control
            bus. Manual removal of the anomalous fuel assembly is the only
            authorized recovery action.
          </Box>
        </Box>
      </Box>

      {!finalCountdown ? (
        <Box className="RBMKConsole__CascadeTerminal">
          <Flex align="end" justify="space-between">
            <Box>
              <Box className="RBMKConsole__CascadeTerminalLabel">
                Terminal cascade threshold
              </Box>
              <Box className="RBMKConsole__CascadeTerminalValue">
                {formattedCountdown}
              </Box>
            </Box>
            <Box className="RBMKConsole__CascadeTerminalFlag">EXTRACT ROD</Box>
          </Flex>
          <ProgressBar
            className="RBMKConsole__CascadeTerminalBar"
            value={countdownPercent}
            maxValue={100}
            color="bad"
          />
        </Box>
      ) : (
        <Box className="RBMKConsole__CascadeClockNotice">
          <Icon name="volume-up" />
          <Box>
            <Box className="RBMKConsole__CascadeClockNoticeTitle">
              Terminal countdown transferred to reactor annunciator
            </Box>
            <Box className="RBMKConsole__CascadeClockNoticeCopy">
              Remote timing has ended. Follow the final audible countdown issued
              directly from the reactor vessel and evacuate immediately.
            </Box>
          </Box>
        </Box>
      )}

      <Box className="RBMKConsole__CascadeProcedure">
        <Box className="RBMKConsole__CascadeProcedureHeader">
          Emergency response procedure
          <Box as="span">RPS-77 / REV. C</Box>
        </Box>
        <Box className="RBMKConsole__CascadeSteps">
          <Box className="RBMKConsole__CascadeStep">
            <Box className="RBMKConsole__CascadeStepNumber">01</Box>
            <Box>
              <Box className="RBMKConsole__CascadeStepTitle">
                Obtain extraction assembly
              </Box>
              <Box className="RBMKConsole__CascadeStepCopy">
                RBMK fuel-rod extraction tool required.
              </Box>
            </Box>
          </Box>
          <Box className="RBMKConsole__CascadeStep">
            <Box className="RBMKConsole__CascadeStepNumber">02</Box>
            <Box>
              <Box className="RBMKConsole__CascadeStepTitle">
                Remove supermatter fuel rod
              </Box>
              <Box className="RBMKConsole__CascadeStepCopy">
                Approach the reactor and perform manual extraction.
              </Box>
            </Box>
          </Box>
          <Box className="RBMKConsole__CascadeStep">
            <Box className="RBMKConsole__CascadeStepNumber">03</Box>
            <Box>
              <Box className="RBMKConsole__CascadeStepTitle">
                Confirm automatic insertion
              </Box>
              <Box className="RBMKConsole__CascadeStepCopy">
                Clear the chamber if rod insertion does not begin immediately.
              </Box>
            </Box>
          </Box>
        </Box>
      </Box>

      <Box className="RBMKConsole__CascadeFooter">
        <Box>
          <Icon name="shield-halved" /> HARDWARE INTERLOCK / LOCAL ACTION ONLY
        </Box>
        <Box>REMOTE COMMAND PATH: ISOLATED</Box>
      </Box>
    </Box>
  );
};

const RBMKAlarmStrip = () => {
  const { data } = useBackend<any>();
  const alarms: string[] = [];
  const temperature = Number(data?.temperature ?? 0);
  const pressure = Number(data?.pressure_current ?? 0);
  const integrity = Number(data?.integrity ?? 100);
  const maxIntegrity = Math.max(Number(data?.max_integrity ?? 100), 1);
  const voidCoefficient = Number(data?.void_coefficient ?? 0);
  const coolantMoles = Number(data?.coolant_moles ?? 0);

  if (temperature >= Number(data?.temp_max_safe ?? 6000)) {
    alarms.push('CORE OVER TEMPERATURE');
  }
  if (pressure >= Number(data?.pressure_critical ?? 7200)) {
    alarms.push('PRIMARY PRESSURE CRITICAL');
  }
  if ((integrity / maxIntegrity) * 100 <= 50) {
    alarms.push('VESSEL INTEGRITY DEGRADED');
  }
  if (voidCoefficient >= 1.5) {
    alarms.push('POSITIVE VOID FEEDBACK HIGH');
  }
  if (data?.running && coolantMoles < 225) {
    alarms.push('PRIMARY COOLANT INVENTORY LOW');
  }

  if (!alarms.length) {
    return null;
  }

  return (
    <NoticeBox danger className="RBMKConsole__AlarmStrip">
      <Icon name="triangle-exclamation" /> {alarms.join('  /  ')}
    </NoticeBox>
  );
};

export const RBMKConsole = () => {
  const { act, data } = useBackend<any>();
  const [tab, setTab] = useLocalState<
    'overview' | 'controls' | 'rods' | 'graphs' | 'generators'
  >('rbmk_tab', 'overview');

  if (data?.supermatter_cascade_active) {
    return (
      <Window theme="soviet" width={680} height={620}>
        <Window.Content className="RBMKConsole">
          <RBMKCascadeLockout />
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window theme="soviet" width={832} height={660}>
      <Window.Content className="RBMKConsole" scrollable>
        <Flex direction="column" gap={1}>
          <RBMKAlarmStrip />
          <Flex.Item>
            <Tabs>
              <Tabs.Tab
                selected={tab === 'overview'}
                onClick={() => setTab('overview')}
                icon="gauge"
              >
                Overview
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'controls'}
                onClick={() => setTab('controls')}
                icon="sliders"
              >
                Controls
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'rods'}
                onClick={() => setTab('rods')}
                icon="grip-vertical"
              >
                Rods
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'graphs'}
                onClick={() => setTab('graphs')}
                icon="chart-line"
              >
                Graphs
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'generators'}
                onClick={() => setTab('generators')}
                icon="bolt"
              >
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
