import { useBackend, useLocalState } from '../../backend';
import {
  PreferencesSelectedPage,
  PreferencesMenuData,
  PreferencesCurrentWindow,
} from './data';
import { CharacterPreferenceWindow } from './CharacterPreferenceWindow';
import { Box, Button, Section, Stack } from '../../components';
import { PageButton } from './PageButton';
import { Window } from '../../layouts';
import { KeybindingsPage } from './KeybindingsPage';
import { GamePreferencesPage } from './GamePreferencesPage';
import { VolumeMixerPage } from './VolumeMixerPage';
import { exhaustiveCheck } from 'common/exhaustive';

export const PreferencesMenu = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const [currentPageLocal, setCurrentPage] = useLocalState(
    'currentPageGamePrefs',
    data.starting_page ?? PreferencesSelectedPage.Settings,
  );

  let currentPage = currentPageLocal;
  let setGamePage = setCurrentPage;

  const window = data.window;
  if (window === PreferencesCurrentWindow.Character) {
    currentPage = PreferencesSelectedPage.Character;

    setGamePage = (page: PreferencesSelectedPage) => {
      setCurrentPage(page);
      act('open_game');
    };
  }

  let pageContents;
  // Having the window size be dynamic causes it to move (if tgui-dev isn't running)
  // this might be worth changing later but for now it's just not worth the hassle
  let window_width = 1415;
  switch (window) {
    case PreferencesCurrentWindow.Character:
      pageContents = <CharacterPreferenceWindow />;
      break;
    case PreferencesCurrentWindow.Game:
      switch (currentPageLocal) {
        case PreferencesSelectedPage.Keybindings:
          // window_width = 970;
          pageContents = <KeybindingsPage />;
          break;
        case PreferencesSelectedPage.Settings:
          // window_width = 1250;
          pageContents = <GamePreferencesPage />;
          break;
        case PreferencesSelectedPage.Volume:
          // window_width = 1290;
          pageContents = <VolumeMixerPage />;
          break;
        case PreferencesSelectedPage.Character:
          pageContents = <Box>Error</Box>;
          break;
        default:
          exhaustiveCheck(currentPageLocal);
      }
      break;
    default:
      exhaustiveCheck(window);
  }

  const settingsCatergories = (
    <Stack vertical width="115px">
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={PreferencesSelectedPage.Character}
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
          page={PreferencesSelectedPage.Settings}
          setPage={setGamePage}
        >
          Settings
        </PageButton>
      </Stack.Item>
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={PreferencesSelectedPage.Keybindings}
          setPage={setGamePage}
        >
          Keybindings
        </PageButton>
      </Stack.Item>
      <Stack.Item>
        <PageButton
          currentPage={currentPage}
          page={PreferencesSelectedPage.Volume}
          setPage={setGamePage}
        >
          Volume Mixer
        </PageButton>
      </Stack.Item>
      <Stack.Divider />
      {window === PreferencesCurrentWindow.Character ? (
        <Stack.Item>
          <Button
            wrap
            onClick={() => {
              act('try_fix_preview');
            }}
          >
            Try Fix Preview
          </Button>
        </Stack.Item>
      ) : (
        ''
      )}
    </Stack>
  );

  return (
    <Window
      title="Preferences"
      width={window_width}
      height={800}
      theme="generic"
    >
      <Window.Content>
        <Stack horizontal height="100%">
          <Stack.Item>
            <Section height="100%" title="Preferences">
              {settingsCatergories}
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow>{pageContents}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
