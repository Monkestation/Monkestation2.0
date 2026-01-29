/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { toFixed } from 'common/math';
import { capitalize } from 'common/string';
import {
  Box,
  Button,
  Collapsible,
  ColorBox,
  Divider,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Tabs,
  TextArea,
  Slider,
  NoticeBox,
} from 'tgui/components';
import { THEMES } from '../themes';

import { SETTINGS_TABS, FONTS, WARN_AFTER_HIGHLIGHT_AMT } from './constants';
import { setEditPaneSplitters } from './scaling';
import { exportChatSettings, importChatSettings } from './settingsImExport';
import { chatRenderer } from '../chat/renderer';
import { useSettings } from './use-settings';
import { useState } from 'react';
import { useHighlights } from './use-highlights';
import {
  wsDisconnect,
  wsReconnect,
  wsUpdate,
} from 'tgui-panel/websocket/helpers';
import { ChatPageSettings } from 'tgui-panel/chat/ChatPageSettings';

export const SettingsPanel = (props) => {
  const {
    settings: { view },
    updateSettings,
  } = useSettings();
  const { activeTab } = view;

  return (
    <Stack fill>
      <Stack.Item>
        <Section fitted fill minHeight="8em">
          <Tabs vertical>
            {SETTINGS_TABS.map((tab) => (
              <Tabs.Tab
                key={tab.id}
                selected={tab.id === activeTab}
                onClick={() =>
                  updateSettings({
                    view: {
                      ...view,
                      activeTab: tab.id,
                    },
                  })
                }
              >
                {tab.name}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow={1} basis={0}>
        {activeTab === 'general' && <SettingsGeneral />}
        {activeTab === 'chatPage' && <ChatPageSettings />}
        {activeTab === 'textHighlight' && <TextHighlightSettings />}
        {activeTab === 'statPanel' && <SettingsStatPanel />}
        {activeTab === 'experimental' && <ExperimentalSettings />}
      </Stack.Item>
    </Stack>
  );
};

export const SettingsGeneral = (props) => {
  const { settings, updateSettings } = useSettings();
  const [freeFont, setFreeFont] = useState(false);

  const [editingPanes, setEditingPanes] = useState(false);

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Theme">
          {THEMES.map((THEME) => (
            <Button
              key={THEME}
              content={capitalize(THEME)}
              selected={settings.theme === THEME}
              color="transparent"
              onClick={() =>
                updateSettings({
                  theme: THEME,
                })
              }
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="UI sizes">
          <Button
            onClick={() =>
              setEditingPanes((val) => {
                setEditPaneSplitters(!val);
                return !val;
              })
            }
            color={editingPanes ? 'red' : undefined}
            icon={editingPanes ? 'save' : undefined}
          >
            {editingPanes ? 'Save' : 'Adjust UI Sizes'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Font style">
          <Stack.Item>
            {(!freeFont && (
              <Collapsible
                title={settings.fontFamily}
                width={'100%'}
                buttons={
                  <Button
                    content="Custom font"
                    icon={freeFont ? 'lock-open' : 'lock'}
                    color={freeFont ? 'good' : 'bad'}
                    onClick={() => {
                      setFreeFont(!freeFont);
                    }}
                  />
                }
              >
                {FONTS.map((FONT) => (
                  <Button
                    key={FONT}
                    content={FONT}
                    fontFamily={FONT}
                    selected={settings.fontFamily === FONT}
                    color="transparent"
                    onClick={() =>
                      updateSettings({
                        fontFamily: FONT,
                      })
                    }
                  />
                ))}
              </Collapsible>
            )) || (
              <Stack>
                <Input
                  width={'100%'}
                  value={settings.fontFamily}
                  onChange={(value) =>
                    updateSettings({
                      fontFamily: value,
                    })
                  }
                />
                <Button
                  ml={0.5}
                  content="Custom font"
                  icon={freeFont ? 'lock-open' : 'lock'}
                  color={freeFont ? 'good' : 'bad'}
                  onClick={() => {
                    setFreeFont(!freeFont);
                  }}
                />
              </Stack>
            )}
          </Stack.Item>
        </LabeledList.Item>
        <LabeledList.Item label="High Contrast">
          <Button.Checkbox
            content="Colored Names"
            checked={settings.coloredNames}
            onClick={() =>
              updateSettings({
                coloredNames: !settings.coloredNames,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Font size" verticalAlign="middle">
          <Stack textAlign="center">
            <Stack.Item grow>
              <Slider
                width="100%"
                step={1}
                stepPixelSize={20}
                minValue={8}
                maxValue={32}
                value={settings.fontSize}
                unit="px"
                format={(value) => toFixed(value)}
                tickWhileDragging
                onChange={(_, value) => updateSettings({ fontSize: value })}
              />
            </Stack.Item>
          </Stack>
        </LabeledList.Item>
        <LabeledList.Item label="Line height">
          <Slider
            width="100%"
            step={0.01}
            stepPixelSize={2}
            minValue={0.8}
            maxValue={5}
            value={settings.lineHeight}
            format={(value) => toFixed(value, 2)}
            tickWhileDragging
            onChange={(_, value) =>
              updateSettings({
                lineHeight: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Stack fill>
        <Stack.Item mt={0.15}>
          <Button
            icon="compact-disc"
            tooltip="Export chat settings"
            onClick={exportChatSettings}
          >
            Export settings
          </Button>
        </Stack.Item>
        <Stack.Item mt={0.15}>
          <Button.File
            accept=".json"
            tooltip="Import chat settings"
            icon="arrow-up-from-bracket"
            onSelectFiles={importChatSettings}
          >
            Import settings
          </Button.File>
        </Stack.Item>
        <Stack.Item grow mt={0.15}>
          <Button
            content="Save chat log"
            icon="save"
            tooltip="Export current tab history into HTML file"
            onClick={() => chatRenderer.saveToDisk()}
          />
        </Stack.Item>
        <Stack.Item mt={0.15}>
          <Button.Confirm
            content="Clear chat"
            icon="trash"
            tooltip="Erase current tab history"
            onClick={() => chatRenderer.clearChat()}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const TextHighlightSettings = (props) => {
  const {
    highlights: { highlightSettings },
    addHighlight,
  } = useHighlights();

  return (
    <Section fill scrollable height="250px">
      <Stack vertical>
        {highlightSettings.map((id, i) => (
          <TextHighlightSetting
            key={i}
            id={id}
            mb={i + 1 === highlightSettings.length ? 0 : '10px'}
          />
        ))}
        <Stack.Item>
          <Box>
            <Button
              color="transparent"
              icon="plus"
              content="Add Highlight Setting"
              onClick={() => {
                addHighlight();
              }}
            />
            {highlightSettings.length >= WARN_AFTER_HIGHLIGHT_AMT && (
              <Box inline fontSize="0.9em" ml={1} color="red">
                <Icon mr={1} name="triangle-exclamation" />
                Large amounts of highlights can potentially cause performance
                issues!
              </Box>
            )}
          </Box>
        </Stack.Item>
      </Stack>
      <Divider />
      <Box>
        <Button icon="check" onClick={() => chatRenderer.rebuildChat()}>
          Apply now
        </Button>
        <Box inline fontSize="0.9em" ml={1} color="label">
          Can freeze the chat for a while.
        </Box>
      </Box>
    </Section>
  );
};

const TextHighlightSetting = (props) => {
  const { id, ...rest } = props;
  const {
    highlights: { highlightSettingById },
    updateHighlight,
    removeHighlight,
  } = useHighlights();
  const {
    enabled,
    highlightColor,
    highlightWholeMessage,
    matchWord,
    matchCase,
  } = highlightSettingById[id];

  return (
    <Stack.Item {...rest}>
      <Stack mb={1} color="label" align="baseline">
        <Stack.Item grow>
          <Button.Checkbox
            checked={!!enabled}
            content="Enabled"
            mr="5px"
            onClick={() =>
              updateHighlight({
                id: id,
                enabled: !enabled,
              })
            }
          />
          <Button
            content="Delete"
            color="transparent"
            icon="times"
            onClick={() => removeHighlight(id)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            checked={highlightWholeMessage}
            content="Whole Message"
            tooltip="If this option is selected, the entire message will be highlighted in yellow."
            mr="5px"
            onClick={() =>
              updateHighlight({
                id: id,
                highlightWholeMessage: !highlightWholeMessage,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            content="Exact"
            checked={matchWord}
            tooltipPosition="bottom-start"
            tooltip="If this option is selected, only exact matches (no extra letters before or after) will trigger. Not compatible with punctuation. Overriden if regex is used."
            onClick={() =>
              updateHighlight({
                id: id,
                matchWord: !matchWord,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <Button.Checkbox
            content="Case"
            tooltip="If this option is selected, the highlight will be case-sensitive."
            checked={matchCase}
            onClick={() =>
              updateHighlight({
                id: id,
                matchCase: !matchCase,
              })
            }
          />
        </Stack.Item>
        <Stack.Item>
          <ColorBox mr={1} color={highlightColor} />
          <Input
            width="5em"
            monospace
            placeholder="#ffffff"
            value={highlightColor}
            onChange={(value) =>
              updateHighlight({
                id: id,
                highlightColor: value,
              })
            }
          />
        </Stack.Item>
      </Stack>
      <TextArea
        height="3em"
        placeholder="Put words to highlight here. Separate terms with commas, i.e. (term1, term2, term3)"
        style={{
          width: '100%',
        }}
        onChange={(value) =>
          updateHighlight({
            id: id,
            highlightText: value,
          })
        }
      />
    </Stack.Item>
  );
};

const ExperimentalSettings = (props) => {
  const { settings, updateSettings } = useSettings();

  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Websocket Client">
              <Button.Checkbox
                content={'Enabled'}
                checked={settings.websocketEnabled}
                color="transparent"
                onClick={() => {
                  const websocketEnabled = !settings.websocketEnabled;
                  updateSettings({ websocketEnabled });
                  wsUpdate(websocketEnabled);
                }}
              />
              <Button
                icon={'question'}
                onClick={() => {
                  chatRenderer.processBatch([
                    {
                      html:
                        '<div class="boxed_message"><b>Websocket Information</b><br><span class="notice">' +
                        'Quick rundown. This connects to the specified websocket server, and ' +
                        'forwards all data/payloads from the server, to the websocket. Allowing ' +
                        'you to have in-game actions reflect in other services, or the real ' +
                        'world, (ex. Reactive RGB, haptics, play effects/animations in vtubing ' +
                        'software, etc). You can find more information ' +
                        '<a href="https://github.com/Monkestation/Monkestation2.0/pull/5744">here in the pull request.</a></span></div>',
                    },
                  ]);
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Websocket Server">
              <Stack.Item>
                <Stack>
                  <Input
                    width={'100%'}
                    value={settings.websocketServer}
                    placeholder="localhost:1990"
                    onChange={(value) =>
                      updateSettings({
                        websocketServer: value,
                      })
                    }
                  />
                </Stack>
              </Stack.Item>
            </LabeledList.Item>
            <LabeledList.Item label="Websocket Controls">
              <Button
                ml={0.5}
                content="Force Reconnect"
                icon={'globe'}
                color={'good'}
                onClick={wsReconnect}
              />
              <Button
                ml={0.5}
                content="Force Disconnect"
                icon={'globe'}
                color={'bad'}
                onClick={wsDisconnect}
              />
            </LabeledList.Item>
            <Divider />
            <LabeledList.Item
              label="ScrollTT"
              tooltip="Scroll Tracking Tolerance: The smallest possible scroll offset that is still trackable. Mess with this if your chat sucks at autoscrolling."
            >
              <Slider
                width="100%"
                step={1}
                stepPixelSize={2}
                minValue={12}
                maxValue={64}
                value={settings.scrollTrackingTolerance}
                format={(value) => toFixed(value)}
                tickWhileDragging
                onChange={(_, value) =>
                  updateSettings({
                    scrollTrackingTolerance: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const TabsViews = ['default', 'classic', 'scrollable'];
const LinkedToChat = () => (
  <NoticeBox color="red">Unlink Stat Panel from chat!</NoticeBox>
);

const SettingsStatPanel = (props) => {
  const { settings, updateSettings } = useSettings();

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Tabs" verticalAlign="middle">
              {TabsViews.map((view) => (
                <Button
                  key={view}
                  color="transparent"
                  selected={settings.statTabsStyle === view}
                  onClick={() => updateSettings({ statTabsStyle: view })}
                >
                  {capitalize(view)}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Font size">
              <Stack.Item grow>
                {settings.statLinked ? (
                  <LinkedToChat />
                ) : (
                  <Slider
                    width="100%"
                    step={1}
                    stepPixelSize={20}
                    minValue={8}
                    maxValue={32}
                    value={settings.statFontSize}
                    unit="px"
                    format={(value) => toFixed(value)}
                    tickWhileDragging
                    onChange={(_, value) =>
                      updateSettings({ statFontSize: value })
                    }
                  />
                )}
              </Stack.Item>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Divider mt={2.5} />
        <Stack.Item textAlign="center">
          <Button
            fluid
            icon={settings.statLinked ? 'unlink' : 'link'}
            color={settings.statLinked ? 'bad' : 'good'}
            onClick={() => updateSettings({ statLinked: !settings.statLinked })}
          >
            {settings.statLinked ? 'Unlink from chat' : 'Link to chat'}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
