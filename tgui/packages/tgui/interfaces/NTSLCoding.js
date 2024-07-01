import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import {
  NoticeBox,
  Box,
  Input,
  LabeledList,
  Button,
  TextArea,
} from '../components';
import { Window } from '../layouts';

export const NTSLCoding = (props, context) => {
  const { act, data } = useBackend(context);
  const { Authenticated } = data;

  return (
    <Window
      title="NTSL NT patented transmission console powershell"
      width={500}
      height={500}
    >
      <Window.Content>
        <NoticeBox
          color={Authenticated === 1 ? 'green' : 'red'}
          textAlign="center"
        >
          {Authenticated === 1 ? 'ACCESS GRANTED' : 'ACCESS DENIED'}
        </NoticeBox>
        {Authenticated === 1 ? <GrantedPanel /> : <DeniedPanel />}
      </Window.Content>
    </Window>
  );
};

const DeniedPanel = (props, context) => {
  return (
    <Box textColor="blue">
      PS: Starting session 2952 of user root. <br />
      PS: Starting jobs... <br />
      PS: Finished starting jobs. <br />
      PS: Waiting for jobs to finish... <br />
      PS: Jobs should have finished. <br />
      PS: Disposed job objects. <br />
      PS: Successfully saved &apos;boottime.xml&apos; <br />
      PS: Asking for administrative permission... <br />
      PS: getting parameter &apos;Authentication&apos; <br />
      WARN: Parameter &apos;Authentication&apos; not detected. <br />
      @echo User credential login attempt detected, authentication required.
      Please insert your ID card into the computer <br />
      PS: getting parameter &apos;Required Access&apos; <br />
      @echo Required access needed: ACCESS_TCOMMS_ADMIN <br />
      PS: Process shutdown successfully. <br />
      Exit Code: 0 <br />
    </Box>
  );
};

const GrantedPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    network,
    detected_servers,
    selected_server_name,
    selected_server_autorun,
    code,
    errors,
    warnings,
  } = data;

  // We store code locally until the user manually uses the "save" button, since TextArea will save it every time you press ENTER
  const [NTSLCode, setNTSLCode] = useLocalState(context, code, '');
  // This is made so we have a dynamically changing height of the box, just something to look nice
  const code_lines = NTSLCode.split('\n').length * 1.5 + 1;

  return (
    <Box>
      Currently connected network:
      <Input
        value={network}
        maxLength={15}
        onChange={(_, value) =>
          act('Change Network', {
            network: value,
          })
        }
      />
      {detected_servers.length > 0 && (
        <LabeledList>
          {detected_servers.map((detected_servers) => (
            <LabeledList.Item
              key={detected_servers.name}
              label={
                detected_servers.name + ' (' + detected_servers.frequency + ')'
              }
              buttons={
                <Button
                  content={'Select Server'}
                  color={'green'}
                  onClick={() =>
                    act('Select Server', {
                      server: detected_servers.name,
                    })
                  }
                />
              }
            />
          ))}
        </LabeledList>
      )}
      {selected_server_name !== 0 && (
        <Box>
          Currently Selected Server:
          <img src={resolveAsset('server.png')} />
          {selected_server_name}
          <Button
            content={'Toggle Code Execution'}
            color={selected_server_autorun === 1 ? 'green' : 'red'}
            onClick={() => act('Toggle Autorun')}
          />
          <Button
            content={'Save Code'}
            color={NTSLCode === code ? 'red' : 'green'}
            onClick={() =>
              act('Save Code', {
                code: NTSLCode,
              })
            }
          />
          <Button
            content={'Compile Code'}
            color={'green'}
            onClick={() => act('Compile Code')}
          />
          <TextArea
            width="90%"
            height={code_lines}
            value={code}
            maxLength={4000}
            onInput={(_, new_value) => setNTSLCode(new_value)}
          />
        </Box>
      )}
      {errors !== 0 && (
        <Box textColor="red">
          <pre>
            compiling error detected, current errors:
            {errors}
          </pre>
        </Box>
      )}
      {warnings !== 0 && (
        <Box textColor="yellow">
          <pre>
            compiling warning detected, current warnings:
            {warnings}
          </pre>
        </Box>
      )}
    </Box>
  );
};
