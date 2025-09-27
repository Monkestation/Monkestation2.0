import { Stack } from '../../components';
import { KeybindingsPage } from './KeybindingsPage';
import { GamePreferencesPage } from './GamePreferencesPage';
import { PageButton } from './PageButton';
import { useBackend, useLocalState } from '../../backend';
import { GamePreferencesSelectedPage, PreferencesMenuData } from './data';
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
    // default:
    //   exhaustiveCheck(currentPage);
  }

  return { pageContents };

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
