import { useBackend, useLocalState } from '../../backend';
import {
  GamePreferencesSelectedPage,
  PreferencesMenuData,
  WindowE,
} from './data';
import { CharacterPreferenceWindow } from './CharacterPreferenceWindow';
import { Box, Button, Stack } from '../../components';
import { PageButton } from './PageButton';
import { Window } from '../../layouts';
import { KeybindingsPage } from './KeybindingsPage';
import { GamePreferencesPage } from './GamePreferencesPage';
import { VolumeMixerPage } from '../VolumeMixer';
import { exhaustiveCheck } from 'common/exhaustive';

export const PreferencesMenu = () => {
  const { data } = useBackend<PreferencesMenuData>();
  const [currentPageLocal, setCurrentPage] = useLocalState(
    'currentPageGamePrefs',
    data.startingPage ?? GamePreferencesSelectedPage.Settings,
  );

  const window = data.window;

  let pageContents;
  switch (window) {
    case WindowE.Character:
      pageContents = <CharacterPreferenceWindow />;
      break;
    case WindowE.Game:
      switch (currentPageLocal) {
        case GamePreferencesSelectedPage.Keybindings:
          pageContents = <KeybindingsPage />;
          break;
        case GamePreferencesSelectedPage.Settings:
          pageContents = <GamePreferencesPage />;
          break;
        case GamePreferencesSelectedPage.Volume:
          pageContents = <VolumeMixerPage />;
          break;
        case GamePreferencesSelectedPage.Character:
          pageContents = <Box>Error</Box>;
          break;
        default:
          exhaustiveCheck(currentPageLocal);
      }
      break;
    default:
      exhaustiveCheck(window);
  }

  return (
    <Window title="Preferences" width={1400} height={800} theme="generic">
      <Window.Content>
        <Stack horizontal height="100%">
          <Stack.Item>
            <SettingsCatergories window={window} />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow>{pageContents}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SettingsCatergories = (props: { window: WindowE }) => {
  const { window } = props;
  const { act, data } = useBackend<PreferencesMenuData>();
  const [currentPageLocal, setCurrentPage] = useLocalState(
    'currentPageGamePrefs',
    GamePreferencesSelectedPage.Settings,
  );

  let currentPage = currentPageLocal;
  let setGamePage = setCurrentPage;
  if (window === WindowE.Character) {
    currentPage = GamePreferencesSelectedPage.Character;

    setGamePage = (page: GamePreferencesSelectedPage) => {
      setCurrentPage(page);
      act('open_game');
    };
  }

  return (
    <Stack vertical width="150px">
      <Stack.Item>
        <Box align="center" fontSize="1.5em">
          Hehe Monke
        </Box>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={GamePreferencesSelectedPage.Character}
          setPage={(_) => {
            act('open_character');
          }}
        >
          Characters
        </PageButton>
        <Button
          onClick={() => {
            act('open_store');
          }}
        >
          Store
        </Button>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={GamePreferencesSelectedPage.Settings}
          setPage={setGamePage}
        >
          Settings
        </PageButton>
      </Stack.Item>
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={GamePreferencesSelectedPage.Keybindings}
          setPage={setGamePage}
        >
          Keybindings
        </PageButton>
      </Stack.Item>
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={GamePreferencesSelectedPage.Volume}
          setPage={setGamePage}
        >
          Volume Mixer
        </PageButton>
      </Stack.Item>
      <Stack.Divider />
    </Stack>
  );
};
