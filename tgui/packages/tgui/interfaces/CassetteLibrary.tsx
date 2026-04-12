import { useMemo, useState } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  DmIcon,
  Dropdown,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type CassetteData = {
  id: string;
  name: string;
  desc: string;
  author_name: string;
  author_ckey: string;
  submitted_time: string;
  approved_time: string;
  icon: string;
  icon_state: string;
};

type PurchaseRecord = {
  buyer: string;
  cassette_id: string;
  cassette_name: string;
  cassette_author: string;
  cassette_author_ckey: string;
  cassette_icon: string;
  cassette_icon_state: string;
  time: number;
};

type TopCassetteData = {
  cassette_id: string;
  cassette_name: string;
  cassette_author: string;
  cassette_author_ckey: string;
  cassette_desc: string;
  cassette_icon: string;
  cassette_icon_state: string;
  cassette_ref: string;
  purchase_count: number;
  cassette_removed?: boolean;
};

type CassetteLibraryData = {
  stored_credits: number;
  cassette_cost: number;
  busy: boolean;
  cassettes: CassetteData[];
  user_id: string | null;
  purchase_history: PurchaseRecord[];
  top_cassettes: TopCassetteData[];
};

const SortOptions: { displayText: string; value: keyof CassetteData }[] = [
  { displayText: 'Name', value: 'name' },
  { displayText: 'Author', value: 'author_name' },
  { displayText: 'Author (Ckey)', value: 'author_ckey' },
  { displayText: 'Description', value: 'desc' },
  { displayText: 'Date', value: 'approved_time' },
];

export const CassetteLibrary = (props) => {
  const { act, data } = useBackend<CassetteLibraryData>();
  const {
    stored_credits,
    cassette_cost,
    busy,
    cassettes,
    user_id,
    purchase_history,
    top_cassettes,
  } = data;

  enum MainTab {
    Search = 'search',
    History = 'history',
    Ranking = 'ranking',
  }
  enum HistoryTab {
    Personal = 'personal',
    General = 'general',
  }

  const [searchQuery, setSearchQuery] = useState('');
  const [activeTab, setActiveTab] = useState<MainTab>(MainTab.Search);
  const [historyTab, setHistoryTab] = useState<HistoryTab>(HistoryTab.Personal);

  const [sortBy, setSortBy] = useState<keyof CassetteData>('approved_time');
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('desc');

  const lowerCassettes = useMemo(() => {
    return cassettes.map((cassette) => ({
      ...cassette,
      _lcName: cassette.name.toLowerCase(),
      _lcAuthorName: cassette.author_name.toLowerCase(),
      _lcAuthorCkey: cassette.author_ckey.toLowerCase(),
      _lcDesc: cassette.desc.toLowerCase(),
      // prefer approved time over submitted time if possible
      // cause of how our cassette data was originally
      approved_time: cassette.approved_time
        ? new Date(Number.parseFloat(cassette.approved_time)).getTime()
        : cassette.submitted_time
          ? new Date(Number.parseFloat(cassette.submitted_time)).getTime()
          : 0,
    }));
  }, [cassettes]);

  const filteredCassettes = useMemo(() => {
    let result = [...lowerCassettes];

    // filter
    if (searchQuery && searchQuery.trim().length >= 2) {
      const query = searchQuery.toLowerCase();
      result = result.filter(
        (cassette) =>
          cassette._lcName.includes(query) ||
          cassette._lcAuthorName.includes(query) ||
          cassette._lcAuthorCkey.includes(query) ||
          cassette._lcDesc.includes(query),
      );
    }

    // sort
    return result.sort((a, b) => {
      let valA, valB;

      switch (sortBy) {
        case 'name':
          valA = a._lcName;
          valB = b._lcName;
          break;
        case 'author_name':
          valA = a._lcAuthorName;
          valB = b._lcAuthorName;
          break;
        case 'desc':
          valA = a._lcDesc;
          valB = b._lcDesc;
          break;
        default:
          valA = a.approved_time || a.submitted_time;
          valB = b.approved_time || b.submitted_time;
          break;
      }

      if (valA === valB) return 0;

      const comparison = valA > valB ? 1 : -1;
      return sortDir === 'asc' ? comparison : -comparison;
    });
  }, [lowerCassettes, searchQuery, sortBy, sortDir]);

  // if no search is active, show the latest 20 approved cassettes
  const displayedCassettes = searchQuery
    ? filteredCassettes
    : filteredCassettes.slice(0, 20);

  return (
    <Window title="Cassette Library" width={650} height={950}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item grow>
                  <Box fontSize="16px" bold>
                    Credits: {stored_credits} cr
                  </Box>
                  <Box fontSize="14px" color="label" mt={0.5}>
                    Cost per cassette:{' '}
                    <Box as="span" bold>
                      {cassette_cost} cr
                    </Box>
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Box
                        textAlign="right"
                        fontSize="11px"
                        color="label"
                        mr={1}
                        style={{ lineHeight: '10px' }}
                      >
                        <Box>Space Board</Box>
                        <Box>of Music</Box>
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Icon name="music" size={1.5} color="grey" />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === MainTab.Search}
                onClick={() => setActiveTab(MainTab.Search)}
              >
                Search
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === MainTab.History}
                onClick={() => setActiveTab(MainTab.History)}
              >
                Purchase History
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === MainTab.Ranking}
                onClick={() => setActiveTab(MainTab.Ranking)}
                color="yellow"
                icon="trophy"
              >
                TOP CASSETTES
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          {activeTab === MainTab.Search ? (
            <>
              <Stack.Item>
                <Section title="Search Cassettes">
                  <Stack>
                    <Stack.Item grow>
                      <Input
                        fluid
                        placeholder="Search..."
                        value={searchQuery}
                        onChange={(value) => setSearchQuery(value)}
                        expensive
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Stack align="center">
                        <Stack.Item>
                          <Dropdown
                            selected={sortBy}
                            options={SortOptions}
                            displayText={(() => {
                              const option = SortOptions.find(
                                (opt) => opt.value === sortBy,
                              );
                              return `Sort by: ${
                                option ? option.displayText : (sortBy as string)
                              }`;
                            })()}
                            onSelected={(value) => setSortBy(value)}
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon={
                              sortDir === 'asc'
                                ? 'sort-amount-up'
                                : 'sort-amount-down'
                            }
                            onClick={() =>
                              setSortDir(sortDir === 'asc' ? 'desc' : 'asc')
                            }
                          >
                            {sortDir.toUpperCase()}
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>

              <Stack.Item grow>
                <Section
                  fill
                  scrollable
                  title={
                    searchQuery
                      ? 'Search Results'
                      : 'Latest 20 Approved Cassettes'
                  }
                >
                  {displayedCassettes.length === 0 ? (
                    <Box color="label" textAlign="center" mt={2}>
                      No cassettes found.
                      {!searchQuery && cassettes.length === 0 && (
                        <Box mt={1}>
                          The cassette database is empty. Submit some cassettes!
                        </Box>
                      )}
                    </Box>
                  ) : (
                    <Stack vertical>
                      {displayedCassettes.map((cassette) => (
                        <Stack.Item key={cassette.id}>
                          <Box
                            style={{
                              border: '1px solid rgba(255, 255, 255, 0.2)',
                              borderRadius: '4px',
                              padding: '8px',
                              marginBottom: '8px',
                            }}
                          >
                            <Stack>
                              <Stack.Item>
                                <Box
                                  width="68px"
                                  height="68px"
                                  style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                    lineHeight: 0,
                                    overflow: 'hidden',
                                  }}
                                >
                                  <DmIcon
                                    icon={cassette.icon}
                                    icon_state={cassette.icon_state}
                                    width="68px"
                                    height="68px"
                                    style={{ verticalAlign: 'middle' }}
                                    fallback={
                                      <Icon name="cassette-tape" size={3} />
                                    }
                                  />
                                </Box>
                              </Stack.Item>
                              <Stack.Item grow>
                                <Stack vertical>
                                  <Stack.Item>
                                    <Box fontSize="16px" bold>
                                      Name: {cassette.name}
                                    </Box>
                                  </Stack.Item>
                                  <Stack.Item>
                                    <Box>
                                      <Box as="span" bold>
                                        Author:
                                      </Box>{' '}
                                      <Tooltip content={cassette.author_ckey}>
                                        <Box
                                          as="span"
                                          style={{
                                            textDecorationLine: 'underline',
                                            textDecorationStyle: 'dotted',
                                            cursor: 'help',
                                          }}
                                        >
                                          {cassette.author_name}
                                        </Box>
                                      </Tooltip>
                                    </Box>
                                  </Stack.Item>
                                  <Stack.Item>
                                    <Box>
                                      <Box as="span" bold>
                                        Description:
                                      </Box>{' '}
                                      {cassette.desc}
                                    </Box>
                                  </Stack.Item>
                                  <Stack.Item>
                                    <Button
                                      icon="shopping-cart"
                                      content={`${cassette_cost} cr`}
                                      disabled={
                                        busy || stored_credits < cassette_cost
                                      }
                                      onClick={() =>
                                        act('purchase_cassette', {
                                          cassette_id: cassette.id,
                                        })
                                      }
                                      tooltip={
                                        stored_credits < cassette_cost
                                          ? 'Insufficient credits'
                                          : 'Purchase this cassette'
                                      }
                                    />
                                  </Stack.Item>
                                </Stack>
                              </Stack.Item>
                            </Stack>
                          </Box>
                        </Stack.Item>
                      ))}
                    </Stack>
                  )}
                </Section>
              </Stack.Item>
            </>
          ) : activeTab === MainTab.History ? (
            <>
              <Stack.Item>
                <Tabs>
                  <Tabs.Tab
                    selected={historyTab === HistoryTab.Personal}
                    onClick={() => setHistoryTab(HistoryTab.Personal)}
                  >
                    Personal History
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={historyTab === HistoryTab.General}
                    onClick={() => setHistoryTab(HistoryTab.General)}
                  >
                    General History
                  </Tabs.Tab>
                </Tabs>
              </Stack.Item>

              <Stack.Item grow>
                {historyTab === HistoryTab.Personal ? (
                  <PersonalHistory
                    act={act}
                    purchase_history={purchase_history}
                    user_id={user_id}
                    cassette_cost={cassette_cost}
                    busy={busy}
                    stored_credits={stored_credits}
                  />
                ) : (
                  <GeneralHistory purchase_history={purchase_history} />
                )}
              </Stack.Item>
            </>
          ) : (
            <Stack.Item grow>
              <TopCassettes top_cassettes={top_cassettes} />
            </Stack.Item>
          )}

          {busy && (
            <Stack.Item>
              <Section>
                <Box
                  textAlign="center"
                  fontSize="16px"
                  bold
                  color="good"
                  style={{ animation: 'pulse 1s infinite' }}
                >
                  Printing cassette...
                </Box>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PersonalHistory = (props) => {
  const {
    act,
    purchase_history,
    user_id,
    cassette_cost,
    busy,
    stored_credits,
  } = props;

  // filter purchases by current user
  const personalPurchases = purchase_history.filter(
    (purchase) => purchase.buyer === user_id,
  );

  return (
    <Section
      fill
      scrollable
      title={`Your Purchases (${personalPurchases.length})`}
    >
      {personalPurchases.length === 0 ? (
        <Box color="label" textAlign="center" mt={2}>
          You haven&apos;t purchased any cassettes yet.
        </Box>
      ) : (
        <Stack vertical>
          {personalPurchases.map((purchase, index) => (
            <Stack.Item key={index}>
              <Box
                style={{
                  border: '1px solid rgba(255, 255, 255, 0.2)',
                  borderRadius: '4px',
                  padding: '8px',
                  marginBottom: '8px',
                }}
              >
                <Stack>
                  <Stack.Item>
                    <Box
                      width="68px"
                      height="68px"
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        lineHeight: 0,
                        overflow: 'hidden',
                      }}
                    >
                      <DmIcon
                        icon={purchase.cassette_icon}
                        icon_state={purchase.cassette_icon_state}
                        width="68px"
                        height="68px"
                        style={{ verticalAlign: 'middle' }}
                        fallback={<Icon name="cassette-tape" size={3} />}
                      />
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Stack vertical>
                      <Stack.Item>
                        <Box fontSize="16px" bold>
                          Name: {purchase.cassette_name}
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box>
                          <Box as="span" bold>
                            Author:
                          </Box>{' '}
                          <Tooltip content={purchase.cassette_author_ckey}>
                            <Box
                              as="span"
                              style={{
                                textDecorationLine: 'underline',
                                textDecorationStyle: 'dotted',
                                cursor: 'help',
                              }}
                            >
                              {purchase.cassette_author}
                            </Box>
                          </Tooltip>
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box color="label" fontSize="12px">
                          Purchased for {cassette_cost} cr
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="shopping-cart"
                          content="Buy Again"
                          disabled={busy || stored_credits < cassette_cost}
                          onClick={() =>
                            act('purchase_cassette', {
                              cassette_id: purchase.cassette_id,
                            })
                          }
                          tooltip={
                            stored_credits < cassette_cost
                              ? 'Insufficient credits'
                              : 'Purchase this cassette again'
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Box>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const GeneralHistory = (props) => {
  const { purchase_history } = props;

  return (
    <Section
      fill
      scrollable
      title={`All Purchases (${purchase_history.length})`}
    >
      {purchase_history.length === 0 ? (
        <Box color="label" textAlign="center" mt={2}>
          No purchases have been made from this terminal yet.
        </Box>
      ) : (
        <Stack vertical>
          {purchase_history.map((purchase, index) => (
            <Stack.Item key={index}>
              <Box
                style={{
                  border: '1px solid rgba(255, 255, 255, 0.2)',
                  borderRadius: '4px',
                  padding: '8px',
                  marginBottom: '8px',
                }}
              >
                <Stack>
                  <Stack.Item>
                    <Box
                      width="38px"
                      height="38px"
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        lineHeight: 0,
                        overflow: 'hidden',
                      }}
                    >
                      <DmIcon
                        icon={purchase.cassette_icon}
                        icon_state={purchase.cassette_icon_state}
                        width="38px"
                        height="38px"
                        style={{ verticalAlign: 'middle' }}
                        fallback={<Icon name="cassette-tape" size={2} />}
                      />
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Stack vertical>
                      <Stack.Item>
                        <Box>
                          <Box as="span" bold>
                            Buyer:
                          </Box>{' '}
                          {purchase.buyer}
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box>
                          <Box as="span" bold>
                            Cassette:
                          </Box>{' '}
                          {purchase.cassette_name}
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box>
                          <Box as="span" bold>
                            Author:
                          </Box>{' '}
                          <Tooltip content={purchase.cassette_author_ckey}>
                            <Box
                              as="span"
                              style={{
                                textDecorationLine: 'underline',
                                textDecorationStyle: 'dotted',
                                cursor: 'help',
                              }}
                            >
                              {purchase.cassette_author}
                            </Box>
                          </Tooltip>
                        </Box>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Box>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const TopCassettes = ({ top_cassettes }) => {
  const getRankBorderColor = (index: number) => {
    if (index === 0) return 'rgba(255, 215, 0, 1)'; // top ONE! gold. SBM is very proud of you
    if (index === 1) return 'rgba(192, 192, 192, 1)'; // top TWO! silver. SBM is proud of you
    if (index === 2) return 'rgba(184, 115, 51, 1)'; // top THREE! bronze. SBM is somewhat proud of you
    return 'rgba(255, 255, 255, 0.3)';
  };

  const getRankTrophyColor = (index: number) => {
    if (index === 0) return 'rgb(255, 215, 0)'; // gold
    if (index === 1) return 'rgb(192, 192, 192)'; // silver
    if (index === 2) return 'rgb(184, 115, 51)'; // bronze
    return null;
  };

  return (
    <Section fill scrollable title="The Most Purchased Cassettes of ALL TIME">
      {top_cassettes.length === 0 ? (
        <Box color="label" textAlign="center" py={2}>
          This ranking is empty. The Space Board of Music is very disappointed.
        </Box>
      ) : (
        <Stack vertical>
          {top_cassettes.map((cassette, index) => (
            <Stack.Item key={cassette.cassette_id}>
              <Box
                style={{
                  border: `2px solid ${getRankBorderColor(index)}`,
                  padding: '10px',
                  borderRadius: '4px',
                  background: cassette.cassette_removed
                    ? 'repeating-linear-gradient(45deg, rgba(139, 0, 0, 0.3), rgba(139, 0, 0, 0.3) 10px, rgba(139, 0, 0, 0.5) 10px, rgba(139, 0, 0, 0.5) 20px)'
                    : 'none',
                  position: 'relative',
                }}
              >
                {cassette.cassette_removed ? (
                  <Stack vertical>
                    <Stack.Item>
                      <Stack align="center">
                        <Stack.Item>
                          <Box
                            width="64px"
                            height="64px"
                            style={{
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                            }}
                          >
                            <Icon name="times" size={4} color="#8b0000" />
                          </Box>
                        </Stack.Item>
                        <Stack.Item grow>
                          <Stack vertical>
                            <Stack.Item>
                              <Box fontSize="14px" bold color="#ff4444" mt={1}>
                                THIS CASSETTE ENTRY HAS BEEN REMOVED BY THE
                                SPACE BOARD OF MUSIC
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box>
                                <Box as="span" bold>
                                  Total Purchases:
                                </Box>{' '}
                                {cassette.purchase_count}
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                ) : (
                  <Stack vertical>
                    <Stack.Item>
                      <Stack>
                        <Stack.Item>
                          <Box
                            width="68px"
                            height="68px"
                            style={{
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                              lineHeight: 0,
                              overflow: 'hidden',
                            }}
                          >
                            <DmIcon
                              icon={cassette.cassette_icon}
                              icon_state={cassette.cassette_icon_state}
                              width="68px"
                              height="68px"
                              style={{ verticalAlign: 'middle' }}
                              fallback={<Icon name="cassette-tape" size={4} />}
                            />
                          </Box>
                        </Stack.Item>
                        <Stack.Item grow>
                          <Stack vertical>
                            <Stack.Item>
                              <Box fontSize="16px" bold>
                                #{index + 1} - {cassette.cassette_name}
                              </Box>
                              {getRankTrophyColor(index) && (
                                <Box mt={0.5}>
                                  <Icon
                                    name="trophy"
                                    size={1}
                                    color={getRankTrophyColor(index)}
                                  />
                                </Box>
                              )}
                            </Stack.Item>
                            <Stack.Item>
                              <Box>
                                <Box as="span" bold>
                                  Author:
                                </Box>{' '}
                                <Tooltip
                                  content={cassette.cassette_author_ckey}
                                >
                                  <Box
                                    as="span"
                                    style={{
                                      textDecorationLine: 'underline',
                                      textDecorationStyle: 'dotted',
                                      cursor: 'help',
                                    }}
                                  >
                                    {cassette.cassette_author}
                                  </Box>
                                </Tooltip>
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box>
                                <Box as="span" bold>
                                  Description:
                                </Box>{' '}
                                {cassette.cassette_desc}
                              </Box>
                            </Stack.Item>
                            <Stack.Item>
                              <Box>
                                <Box as="span" bold>
                                  Total Purchases:
                                </Box>{' '}
                                {cassette.purchase_count}
                              </Box>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                )}
              </Box>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};
