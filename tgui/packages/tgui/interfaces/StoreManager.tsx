import { classes } from 'common/react';
import { useEffect, useState } from 'react';
import { resolveAsset } from 'tgui/assets';
import { logger } from 'tgui/logging';
import { fetchRetry } from 'tgui-core/http';
import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import type { PreferencesMenuData } from './PreferencesMenu/data';

type StoreEntry = {
  name: string;
  path: string;
  cost: number;
  desc: string;
  icon: string;
  icon_state?: string;
  job_restricted?: string;
};

type StoreTab = {
  name: string;
  title: string;
  contents: StoreEntry[];
};

export const StoreManager = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { total_coins, owned_items } = data;

  const [store_tabs, set_store_tabs] = useState<StoreTab[]>([]);
  useEffect(() => {
    fetchRetry(resolveAsset('loadout_store.json'))
      .then((response) => response.json())
      .then((loadout_data: StoreTab[]) => set_store_tabs(loadout_data))
      .catch((error) => {
        logger.log('Failed to fetch loadout_store.json', JSON.stringify(error));
      });
  }, []);

  const [selectedTabName, setSelectedTab] = useSharedState(
    'tabs',
    store_tabs[0]?.name,
  );
  const selectedTab = store_tabs.find(
    (curTab) => curTab.name === selectedTabName,
  );

  return (
    <Window title="Store Manager" width={900} height={500} theme="generic">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section
              title="Store Categories"
              align="center"
              className="StoreManager__Categories__Section"
              buttons={
                <Button
                  icon="fa-solid fa-coins"
                  tooltip="This is your total Monkecoin amount."
                  tooltipPosition="top"
                >
                  {total_coins}
                </Button>
              }
            >
              <Tabs>
                {store_tabs.map((curTab) => (
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
            <Section
              title={selectedTab?.title || 'Store Items'}
              fill
              scrollable
            >
              <Table>
                <Table.Row header>
                  <Table.Cell style={{ width: '5%' }} />
                  <Table.Cell style={{ width: '75%' }}>Name</Table.Cell>
                  <Table.Cell style={{ width: '10%', textAlign: 'right' }}>
                    Cost
                  </Table.Cell>
                  <Table.Cell style={{ width: '10%', textAlign: 'right' }}>
                    Purchase
                  </Table.Cell>
                </Table.Row>
                {selectedTab?.contents ? (
                  selectedTab.contents.map((item, index) => (
                    <Table.Row
                      key={item.name}
                      backgroundColor={index % 2 === 0 ? '#19181e' : '#16151b'}
                    >
                      <Table.Cell>
                        {item.icon && item.icon_state ? (
                          <DmIcon
                            icon={item.icon}
                            icon_state={item.icon_state}
                            verticalAlign="middle"
                            height={'32px'}
                            width={'32px'}
                            fallback={<Icon name="spinner" size={2} spin />}
                          />
                        ) : (
                          <Box
                            inline
                            verticalAlign="middle"
                            width={'32px'}
                            height={'32px'}
                            className={classes([
                              'loadout_store32x32',
                              item.icon,
                            ])}
                          />
                        )}
                      </Table.Cell>
                      <Table.Cell>
                        <Button
                          fluid
                          backgroundColor="transparent"
                          tooltip={item.desc}
                        >
                          {item.name}
                        </Button>
                      </Table.Cell>
                      <Table.Cell style={{ textAlign: 'right' }}>
                        <Box
                          style={{
                            display: 'flex',
                            justifyContent: 'flex-end',
                          }}
                        >
                          <Button
                            icon="fa-solid fa-coins"
                            backgroundColor="transparent"
                            tooltip="This is the cost of the item."
                          >
                            {item.cost}
                          </Button>
                        </Box>
                      </Table.Cell>
                      <Table.Cell style={{ textAlign: 'right' }}>
                        <Box
                          style={{
                            display: 'flex',
                            justifyContent: 'flex-end',
                          }}
                        >
                          <Button.Confirm
                            disabled={
                              owned_items.includes(item.path) ||
                              total_coins < item.cost
                            }
                            onClick={() =>
                              act('select_item', {
                                path: item.path,
                              })
                            }
                          >
                            {owned_items.includes(item.path)
                              ? 'Owned'
                              : 'Purchase'}
                          </Button.Confirm>
                        </Box>
                      </Table.Cell>
                    </Table.Row>
                  ))
                ) : (
                  <Table.Row>
                    <Table.Cell colSpan={4} align="center">
                      <Box>No contents for selected tab.</Box>
                    </Table.Cell>
                  </Table.Row>
                )}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
