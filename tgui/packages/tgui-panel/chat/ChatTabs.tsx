/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Box, Tabs, Button, Stack } from 'tgui/components';
import { useChatPages } from './use-chat-pages';
import { useSetAtom } from 'jotai';
import { settingsVisibleAtom } from 'tgui-panel/settings/atoms';

const UnreadCountWidget = ({ value }) => (
  <Box className="UnreadCount">{Math.min(value, 99)}</Box>
);

export const ChatTabs = (props) => {
  const { addChatPage, changeChatPage, pages, pagesRecord, currentPageId } =
    useChatPages();

  const setSettingsVisible = useSetAtom(settingsVisibleAtom);

  return (
    <Stack align="center">
      <Stack.Item>
        <Tabs scrollable textAlign="center">
          {pages.map((page) => {
            const actual = pagesRecord[page];
            return (
              <Tabs.Tab
                key={page.id}
                selected={page === currentPageId}
                onClick={() => changeChatPage(actual)}
              >
                {actual.name}
                {!actual.hideUnreadCount && actual.unreadCount > 0 && (
                  <UnreadCountWidget value={actual.unreadCount} />
                )}
              </Tabs.Tab>
            );
          })}
        </Tabs>
      </Stack.Item>
      <Stack.Item ml={1}>
        <Button
          color="transparent"
          icon="plus"
          onClick={() => {
            addChatPage();
            setSettingsVisible(true);
          }}
        />
      </Stack.Item>
    </Stack>
  );
};
