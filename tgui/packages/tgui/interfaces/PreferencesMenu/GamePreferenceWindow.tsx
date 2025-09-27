import { Button, Stack } from '../../components';
import { KeybindingsPage } from './KeybindingsPage';
import { GamePreferencesPage } from './GamePreferencesPage';
import { PageButton } from './PageButton';
import { useBackend, useLocalState } from '../../backend';
import { GamePreferencesSelectedPage, PreferencesMenuData } from './data';
import { exhaustiveCheck } from 'common/exhaustive';
import { Window } from '../../layouts';
import { VolumeMixerPage } from '../VolumeMixer';

export const GamePreferenceWindow = (props: {
  startingPage?: GamePreferencesSelectedPage;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();

  const [currentPage, setCurrentPage] = useLocalState(
    'currentPage',
    props.startingPage ?? GamePreferencesSelectedPage.Settings,
  );

  let pageContents;

  switch (currentPage) {
    case GamePreferencesSelectedPage.Keybindings:
      pageContents = <KeybindingsPage />;
      break;
    case GamePreferencesSelectedPage.Settings:
      pageContents = <GamePreferencesPage />;
      break;
    case GamePreferencesSelectedPage.Volume:
      pageContents = <VolumeMixerPage />;
      break;
    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Window width={950} height={800} theme="generic">
      <Window.Content>
        <Stack horizontal height="100%">
          <Stack.Item>
            {currentPage}
            <SettingsCatergories />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item>{pageContents}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Stack fill>
          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={GamePreferencesSelectedPage.Settings}
              setPage={setCurrentPage}
            >
              Settings
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={GamePreferencesSelectedPage.Keybindings}
              setPage={setCurrentPage}
            >
              Keybindings
            </PageButton>
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Divider />

      <Stack.Item grow shrink basis="1px">
        {pageContents}
      </Stack.Item>
    </Stack>
  );
};

const SettingsCatergories = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const [currentPage, setCurrentPage] = useLocalState(
    'currentPage',
    GamePreferencesSelectedPage.Settings,
  );

  return (
    <Stack vertical>
      <Stack.Item>
        <Button
          onClick={() => {
            act('character');
          }}
        >
          FUCK ME
        </Button>
        <PageButton
          currentPage={currentPage}
          page={GamePreferencesSelectedPage.Settings}
          setPage={setCurrentPage}
        >
          Settings
        </PageButton>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={GamePreferencesSelectedPage.Keybindings}
          setPage={setCurrentPage}
        >
          Keybindings
        </PageButton>
      </Stack.Item>
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={GamePreferencesSelectedPage.Volume}
          setPage={setCurrentPage}
        >
          Settings
        </PageButton>
      </Stack.Item>
      <Stack.Divider />
      {/* <Stack.Item>
        <Button
          onClick={() => {
            setWindow(WindowE.Keybindings);
          }}
        >
          Key Bindings
        </Button>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Button
          onClick={() => {
            setWindow(WindowE.Volume);
          }}
        >
          Volume Mixer
        </Button>
      </Stack.Item> */}
    </Stack>
  );
};
