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

  let pageContents: any;
  switch (window) {
    case PreferencesCurrentWindow.Character:
      pageContents = <CharacterPreferenceWindow />;
      break;
    case PreferencesCurrentWindow.Game:
      switch (currentPageLocal) {
        case PreferencesSelectedPage.Settings:
          pageContents = <GamePreferencesPage />;
          break;
        case PreferencesSelectedPage.Keybindings:
          pageContents = <KeybindingsPage />;
          break;
        case PreferencesSelectedPage.Volume:
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
          align="center"
          fontSize="1em"
          fluid
          onClick={() => {
            act('open_store');
          }}
        >
          Loadout Store
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
            align="center"
            fontSize="1em"
            fluid
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
    <Window title="Preferences" width={1215} height={850} theme="generic">
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
