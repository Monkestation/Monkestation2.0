import { useLocalState } from '../backend';
import { Divider, Section, Stack } from '../components';
import { Window } from '../layouts';

const allystyle = {
  color: 'yellow',
  fontWeight: 'bold',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const goalstyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const IntroductionSection = () => {
  return (
    <Stack vertical fill>
      <Stack.Item height="40%">
        <Section fill title="Info">
          You are a <span style={allystyle}>Abandoned IPC</span>, a mechanical
          construct leftover from the{' '}
          <span style={badstyle}>previous shift.</span>
          <Divider />
          Your autorepair systems have brought you back online, but were
          <span style={badstyle}> unable to repair you fully.</span> As a
          result, you have recieved some prime{' '}
          <span style={goalstyle}>directives</span> from passing ion storms.
          <br />
          <span style={allystyle}>Follow them at all costs</span>
        </Section>
        <Stack.Item>
          <Section fill title="Diagnostics">
            <span style={badstyle}>
              Overall Status: LOW.
              <br />
            </span>
            &gt;CHASSIS CONDITION: <span style={allystyle}>MEDIUM</span>
            <br />
            &gt;ION STORM REJECTION FIREWALL:{' '}
            <span style={badstyle}>OFFLINE</span>
            <br />
            &gt;SOFTWARE AUTO-REPAIR: <span style={badstyle}>OFFLINE</span>
            <br />
            &gt;Report to <span style={goalstyle}>^%^#D%^!@? </span>
            <br />
            &gt;&gt;<span style={badstyle}>N</span>
          </Section>
          <Section fill title="Logging">
            <span style={goalstyle}>EXTERNAL REPAIR ATTEMPT DETECTED</span>
            <br />
            &gt; PROGRESS TO COMPLETION: <span style={badstyle}>46%</span>
            <br />
            &gt; SELF REPAIR PROTOCOL: <span style={goalstyle}>ACTIVE</span>
            <br />
            &gt; CHASSIS REPAIR NANOMACHINES:{' '}
            <span style={goalstyle}>ACTIVE</span>
          </Section>
        </Stack.Item>
      </Stack.Item>
    </Stack>
  );
};

const LawsSection = () => {
  return (
    <Section fill title="Diagnostics">
      <Stack vertical fill>
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item grow style={{ backgroundColor: 'black' }}>
              <span style={goalstyle}>
                Accepted External Law Modules:
                <br />
              </span>
              &gt;
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

enum Screen {
  Intro,
  Modules,
}

export const AntagInfoAIPC = () => {
  const [antagInfoTab] = useLocalState<Screen>('antagInfoTab', Screen.Intro);

  return (
    <Window
      width={660}
      height={530}
      theme={antagInfoTab === Screen.Intro ? 'hackerman' : 'malfunction'}
    >
      <Window.Content style={{ fontFamily: 'Consolas, monospace' }}>
        <Stack vertical fill>
          {antagInfoTab === Screen.Intro ? (
            <>
              <Stack.Item grow>
                <Stack fill>
                  <Stack.Item width="40%">
                    <IntroductionSection />
                  </Stack.Item>
                  <Stack.Item width="60%">
                    <LawsSection />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item />
            </>
          ) : (
            <Stack.Item grow />
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
