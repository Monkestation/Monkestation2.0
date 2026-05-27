import { useEffect, useMemo, useState } from 'react';
import { resolveAsset } from 'tgui/assets';
import { fetchRetry } from 'tgui-core/http';
import { useBackend, useSharedState } from '../../backend';
import { Box, Button, Section, Stack, Table, Tabs } from '../../components';
import { logger } from '../../logging';
import { CharacterPreview } from '../common/CharacterPreview';
import type { LoadoutData, PreferencesMenuData } from './data';
import { NameInput } from './names';

const CLOTHING_CELL_SIZE = 64;
const CLOTHING_SIDEBAR_ROWS = 10;

const CLOTHING_SELECTION_CELL_SIZE = 64;
const CLOTHING_SELECTION_MULTIPLIER = 5.2;

const CharacterControls = (props: {
  handleRotate?: () => void;
  handleStore?: () => void;
}) => {
  return (
    <Stack>
      {!!props.handleRotate && (
        <Stack.Item>
          <Button
            onClick={props.handleRotate}
            fontSize="22px"
            icon="undo"
            tooltip="Rotate"
            tooltipPosition="top"
          />
        </Stack.Item>
      )}
      {!!props.handleStore && (
        <Stack.Item>
          <Button
            onClick={props.handleStore}
            fontSize="22px"
            icon="sack-dollar"
            tooltip="Show Store Menu"
            tooltipPosition="top"
          />
        </Stack.Item>
      )}
    </Stack>
  );
};

export const LoadoutManager = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    selected_loadout,
    extra_tabs,
    user_is_donator,
    total_coins,
    selected_unusuals,
    available_items,
  } = data;

  const [base_loadout_tabs, set_base_loadout_tabs] = useState<LoadoutData[]>(
    [],
  );
  useEffect(() => {
    fetchRetry(resolveAsset('loadout_items.json'))
      .then((response) => response.json())
      .then((loadout_data: LoadoutData[]) =>
        set_base_loadout_tabs(loadout_data),
      )
      .catch((error) => {
        logger.log('Failed to fetch loadout_items.json', JSON.stringify(error));
      });
  }, []);

  const loadout_tabs = useMemo(
    () => base_loadout_tabs.concat(extra_tabs),
    [base_loadout_tabs, extra_tabs],
  );

  const [_multiNameInputOpen, setMultiNameInputOpen] = useState(false);
  const [selectedTabName, setSelectedTab] = useSharedState(
    'tabs',
    loadout_tabs[0]?.name,
  );
  const selectedTab = loadout_tabs.find((curTab) => {
    return curTab.name === selectedTabName;
  });

  return (
    <Stack height={`${CLOTHING_SIDEBAR_ROWS * CLOTHING_CELL_SIZE}px`}>
      <Stack.Item>
        <Stack vertical fill>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <CharacterControls handleRotate={() => act('rotate')} />
              </Stack.Item>
              <Stack.Item>
                <Button
                  height="37px"
                  fontSize="22px"
                  icon="fa-solid fa-coins"
                  align="center"
                  tooltip="This is your total Monkecoin amount."
                  tooltipPosition="top"
                >
                  {total_coins}
                </Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow>
            <CharacterPreview height="100%" id={data.character_preview_view} />
          </Stack.Item>

          <Stack.Item position="relative">
            <NameInput
              openMultiNameInput={() => setMultiNameInputOpen(false)}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Loadout Categories" align="center">
              <Tabs style={{ flexWrap: 'wrap' }}>
                {loadout_tabs.map((curTab) => (
                  <Tabs.Tab
                    key={curTab.name}
                    selected={selectedTabName === curTab.name}
                    onClick={() => setSelectedTab(curTab.name)}
                  >
                    {curTab.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            {selectedTab?.contents ? (
              <Section
                title={selectedTab.title}
                fill
                scrollable
                buttons={
                  <Button.Confirm
                    icon="times"
                    color="red"
                    align="center"
                    content="Clear All Items"
                    tooltip="Clears ALL selected items from all categories."
                    onClick={() => act('clear_all_items')}
                  />
                }
              >
                <Table>
                  {selectedTab.contents
                    .filter(
                      (item) =>
                        !!item.unusual_placement ||
                        available_items.includes(item.path),
                    )
                    .map((item, index) => (
                      <Table.Row
                        header
                        key={item.name}
                        backgroundColor={
                          index % 2 === 0 ? '#19181e' : '#16151b'
                        }
                      >
                        <Stack fontSize="15px">
                          <Stack.Item grow align="left">
                            {item.name}
                          </Stack.Item>
                          {!!item.is_greyscale && (
                            <Stack.Item>
                              <Button
                                icon="palette"
                                onClick={() =>
                                  act('select_color', {
                                    path: item.path,
                                  })
                                }
                              />
                            </Stack.Item>
                          )}
                          {!!item.is_renamable && (
                            <Stack.Item>
                              <Button
                                icon="pen"
                                onClick={() =>
                                  act('set_name', {
                                    path: item.path,
                                  })
                                }
                              />
                            </Stack.Item>
                          )}
                          {!!item.is_job_restricted && (
                            <Stack.Item>
                              <Button
                                icon="lock"
                                onClick={() =>
                                  act('display_restrictions', {
                                    path: item.path,
                                  })
                                }
                              />
                            </Stack.Item>
                          )}
                          {!!item.is_donator_only && (
                            <Stack.Item>
                              <Button
                                icon="heart"
                                color="pink"
                                onClick={() =>
                                  act('donator_explain', {
                                    path: item.path,
                                  })
                                }
                              />
                            </Stack.Item>
                          )}
                          {!!item.is_ckey_whitelisted && (
                            <Stack.Item>
                              <Button
                                icon="user-lock"
                                onClick={() =>
                                  act('ckey_explain', {
                                    path: item.path,
                                  })
                                }
                              />
                            </Stack.Item>
                          )}
                          <Stack.Item>
                            <Button.Checkbox
                              checked={
                                selected_loadout.includes(item.path) ||
                                (selected_unusuals.includes(
                                  item.unusual_placement,
                                ) &&
                                  item.unusual_spawning_requirements)
                              }
                              content="Select"
                              disabled={
                                item.is_donator_only && !user_is_donator
                              }
                              fluid
                              onClick={() =>
                                act('select_item', {
                                  path: item.path,
                                  unusual_spawning_requirements:
                                    item.unusual_spawning_requirements,
                                  unusual_placement: item.unusual_placement,
                                  deselect: selected_loadout.includes(
                                    item.path,
                                  ),
                                })
                              }
                            />
                          </Stack.Item>
                        </Stack>
                      </Table.Row>
                    ))}
                </Table>
              </Section>
            ) : (
              <Section fill>
                <Box>No contents for selected tab.</Box>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
