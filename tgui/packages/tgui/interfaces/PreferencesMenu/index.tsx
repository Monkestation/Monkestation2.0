import { useBackend, useLocalState } from '../../backend';
import {
  GamePreferencesSelectedPage,
  PreferencesMenuData,
  WindowE,
} from './data';
import { CharacterPreferenceWindow } from './CharacterPreferenceWindow';
import { GamePreferenceWindow } from './GamePreferenceWindow';
import { Box, Button, Stack } from '../../components';
import { PageButton } from './PageButton';
import { Window } from '../../layouts';
import { KeybindingsPage } from './KeybindingsPage';
import { GamePreferencesPage } from './GamePreferencesPage';
import { VolumeMixerPage } from '../VolumeMixer';

export const PreferencesMenu = (props) => {
  const { data } = useBackend<PreferencesMenuData>();
  const [currentPageLocal, setCurrentPage] = useLocalState(
    'currentPageGamePrefs',
    GamePreferencesSelectedPage.Settings,
  );

  const window = data.window;

  let pageContents;
  switch (window) {
    case WindowE.Character:
      pageContents = <CharacterPreferenceWindow />;
      break;
    case WindowE.Game:
      pageContents = <GamePreferenceWindow />;
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
      }
    // default:
    //   exhaustiveCheck(window);
  }

  return (
    <Window width={1350} height={800} theme="generic">
      <Window.Content>
        <Stack horizontal height="100%">
          <Stack.Item>
            <SettingsCatergories window={window} />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item>{pageContents}</Stack.Item>
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
        <Box fontSize="1.2em">Pages</Box>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Button
          align="center"
          fontSize="1.2em"
          fluid
          selected={currentPage === GamePreferencesSelectedPage.Character}
          onClick={() => {
            act('open_character');
          }}
        >
          Characters
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
