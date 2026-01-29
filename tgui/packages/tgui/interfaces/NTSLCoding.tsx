import { useState } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Input,
  Section,
  Stack,
  Tabs,
} from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';
import { AceEditor } from '../components/Ace/Editor';
import { sleep } from 'tgui-core/timer';
import { UI_UPDATE } from 'tgui-core/constants';

// NTSLTextArea component start
// This is literally just TextArea but without ENTER updating anything, for NTSL

type NTSLTextAreaProps = {
  storedNtslCode: [string, (field: string) => void];
};

// NTSLTextArea component end

type Data = {
  admin_view: boolean;
  emagged: boolean;
  stored_code: string;
  user_name: string;
  network: string;
  compiler_output: string[];
  access_log: string[];
  server_data: Server_Data[];
};

type Server_Data = {
  run_code: boolean;
  server: string;
  server_name: string;
};

export const NTSLCoding = (props) => {
  const { act, data } = useBackend<Data>();
  const { emagged, user_name, admin_view } = data;
  // Make sure we don't start larger than 50%/80% of screen width/height.
  const winWidth = Math.min(
    user_name ? 900 : 250,
    window.screen.availWidth * 0.5,
  );
  const winHeight = Math.min(
    user_name ? 600 : 240,
    window.screen.availHeight * 0.8,
  );

  const storedNtslCode = useState('');
  const [tabIndex, setTabIndex] = useState(1);

  return (
    <Window title="Traffic Control Console" width={winWidth} height={winHeight}>
      <Window.Content>
        <Stack fill>
          {user_name && (
            <Stack.Item width={winWidth - 240}>
              <ScriptEditor storedNtslCode={storedNtslCode} />
            </Stack.Item>
          )}
          <Stack.Item>
            {admin_view ? (
              <Button
                icon="power-off"
                color="red"
                onClick={() => act('admin_reset')}
              >
                !(ADMIN) reset code and compile!
              </Button>
            ) : (
              ''
            )}
            <Section width="240px">
              {user_name ? (
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="power-off"
                      color="purple"
                      disabled={emagged}
                      onClick={() => act('log_out')}
                    >
                      Log Out
                    </Button>
                  </Stack.Item>
                  <Stack.Item verticalAlign="middle">{user_name}</Stack.Item>
                </Stack>
              ) : (
                <Button
                  icon="power-off"
                  color="green"
                  onClick={() => act('log_in')}
                >
                  Log In
                </Button>
              )}
            </Section>
            {user_name && (
              <Section width="240px" height="90%" fill>
                <Tabs>
                  <Tabs.Tab
                    selected={tabIndex === 1}
                    onClick={() => setTabIndex(1)}
                  >
                    Compile
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={tabIndex === 2}
                    onClick={() => setTabIndex(2)}
                  >
                    Network
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={tabIndex === 3}
                    onClick={() => setTabIndex(3)}
                  >
                    Logs
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={tabIndex === 4}
                    onClick={() => setTabIndex(4)}
                  >
                    Reference
                  </Tabs.Tab>
                </Tabs>
                {tabIndex === 1 && (
                  <CompilerOutput storedNtslCode={storedNtslCode} />
                )}
                {tabIndex === 2 && <ServerList />}
                {tabIndex === 3 && <LogViewer />}
                {tabIndex === 4 && <Guide />}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ScriptEditor = (props: NTSLTextAreaProps) => {
  const { act, data, config } = useBackend<Data>();
  const { stored_code, user_name } = data;
  const [_ntslCode, setNtslCode] = props.storedNtslCode;

  return (
    <Box width="100%" height="100%">
      <AceEditor
        value={stored_code}
        language="ntsl"
        width="100%"
        height="100%"
        onChange={setNtslCode}
        style={{
          mixBlendMode: 'overlay',
        }}
        onCtrlS={(value) => {
          if (value === '') return false;
          act('save_code', { saved_code: value });
          return true;
        }}
        onCtrlShiftB={(value) => {
          act('save_code', { saved_code: value });
          sleep(150).then(() => act('compile_code'));
          return true;
        }}
        readOnly={!user_name || config.status <= UI_UPDATE}
      />
    </Box>
  );
};

const CompilerOutput = (props: NTSLTextAreaProps) => {
  const { act, data } = useBackend<Data>();
  const { compiler_output } = data;
  const [ntslCode] = props.storedNtslCode;
  return (
    <>
      <Box>
        <Button
          mb={1}
          icon="save"
          disabled={ntslCode === ''}
          tooltip={
            'Must be done before compiling! (Hint: Ctrl-S in the editor to save)'
          }
          onClick={() => act('save_code', { saved_code: ntslCode })}
        >
          Save
        </Button>
      </Box>
      <Box>
        <Button
          mb={1}
          icon="running"
          onClick={() => act('compile_code')}
          tooltip={'Hint: Ctrl-Shift-B in the editor to save & compile'}
        >
          Compile & Run
        </Button>
      </Box>
      <Divider />
      <Section fill scrollable height="87.2%">
        {compiler_output
          ? compiler_output.map((error_message, index) => (
              <Box key={index}>{error_message}</Box>
            ))
          : 'No compile errors.'}
      </Section>
    </>
  );
};

const ServerList = (props) => {
  const { act, data } = useBackend<Data>();
  const { network, server_data } = data;
  return (
    <>
      <Box>
        <Button mb={1} icon="sync" onClick={() => act('refresh_servers')}>
          Reconnect to Network
        </Button>
      </Box>
      <Box>
        <Input
          mb={1}
          value={network}
          onBlur={(value) =>
            act('set_network', {
              new_network: value,
            })
          }
        />
      </Box>
      <Divider />
      <Section fill scrollable height="82%">
        {server_data.map((nt_server, index) => (
          <Box key={index}>
            <Button.Checkbox
              mb={0.5}
              checked={nt_server.run_code}
              onClick={() =>
                act('toggle_code_execution', {
                  selected_server: nt_server.server,
                })
              }
            >
              {nt_server.server_name}
            </Button.Checkbox>
          </Box>
        ))}
      </Section>
    </>
  );
};

const LogViewer = (props) => {
  const { act, data } = useBackend<Data>();
  const { access_log } = data;
  // This is terrible but nothing else will work
  return (
    <>
      <Box>
        <Button mb={1} icon="trash" onClick={() => act('clear_logs')}>
          Clear Logs
        </Button>
      </Box>
      <Divider />
      <Section fill scrollable height="87.2%">
        {access_log
          ? access_log.map((access_message, index) => (
              <Box key={index}>{access_message}</Box>
            ))
          : 'Access log could not be found. Please contact an administrator.'}
      </Section>
    </>
  );
};

// These frequencies wont show up the list of the frequencies in the guide,
// Because you cant use them.
const blacklistedChannels = [
  'Syndicate',
  'Red Team',
  'Blue Team',
  'Green Team',
  'Yellow Team',
];

const Guide = (props) => {
  return (
    <Section fill scrollable height="95.5%">
      NT Recognized Frequencies: <br />
      (var = channels.channel_name) <br />
      {RADIO_CHANNELS.filter(
        (channel) => !blacklistedChannels.includes(channel.name),
      ).map((channel, index) => (
        <div key={index} style={{ color: channel.color }}>
          {channel.name}: {channel.freq}
        </div>
      ))}
      <br />
      Signal flags
      <br />
      source: Name of person.
      <br />
      content: Message being said.
      <br />
      job: Job of the person.
      <br />
      freq: See NT Recognized Frequencies.
      <br />
      pass: Boolean, whether message will go through.
      <br />
      say: Say verb of the person.
      <br />
      ask: Ask verb of the person.
      <br />
      yell: Yell verb of the person.
      <br />
      exclaim: Exclaim verb of the person.
      <br />
      filters: See Radio Filters.
      <br />
      language: See Readable Languages.
      <br />
      <br />
      NT radio filters: <br />
      (var = filter_types.filter_name) <br /># fonts <br />
      &quot;robot&quot; (robot) <br />
      &quot;sans&quot; (wacky) <br /># manipulation <br />
      <i>&quot;italics&quot; (emphasis)</i> <br />
      <b>&quot;yell&quot; (loud)</b> <br />
      &quot;command_headset&quot; (commanding) <br />
      <br /> {/* Btw, clown is also allowed. But we don't tell them that */}
      <br />
      NT Readable languages: <br />
      (var = languages.language_name) <br />1 (human) <br />2 (monkey) <br />3
      (robot) <br />4 (draconic) <br />
      5 (beachtounge) <br />
      6 (sylvan) <br />
      7 (etherean) <br />
      8 (bonespeak) <br />
      9 (mothian) <br />
      10 (cat) <br />
      11 (ash) <br />
      12 (torii) <br />
      13 (uncommon) <br />
      14 (goblin) <br />
      15 (nekomimetic) <br />
      16 (slime) <br />
      <br />
      <br />
      Broadcasted signals will not run itself through Scripts.
    </Section>
  );
};
