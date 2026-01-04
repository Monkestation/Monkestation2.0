import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type CassetteData = {
  id: string;
  name: string;
  desc: string;
  author_name: string;
  author_ckey: string;
  icon: string;
  icon_state: string;
  ref: string;
};

type PurchaseRecord = {
  buyer: string;
  cassette_name: string;
  cassette_author: string;
  cassette_author_ckey: string;
  cassette_icon: string;
  cassette_icon_state: string;
  cassette_ref: string;
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

  const [searchQuery, setSearchQuery] = useLocalState('searchQuery', '');
  const [activeTab, setActiveTab] = useLocalState('activeTab', 'search');
  const [historyTab, setHistoryTab] = useLocalState('historyTab', 'personal');

  const filteredCassettes = cassettes.filter((cassette) => {
    if (!searchQuery) return true;
    const query = searchQuery.toLowerCase();
    return (
      cassette.name.toLowerCase().includes(query) ||
      cassette.author_name.toLowerCase().includes(query) ||
      cassette.author_ckey.toLowerCase().includes(query) ||
      cassette.desc.toLowerCase().includes(query)
    );
  });

  // if no search is active, show the latest 20 approved cassettes
  const displayedCassettes = searchQuery
    ? filteredCassettes
    : filteredCassettes.slice(0, 20);

  return (
    <Window title="Cassette Library" width={700} height={600}>
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
                        Space Board
                        <br />
                        of Music
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
                selected={activeTab === 'search'}
                onClick={() => setActiveTab('search')}
              >
                Search
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'history'}
                onClick={() => setActiveTab('history')}
              >
                Purchase History
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === 'top'}
                onClick={() => setActiveTab('top')}
                color="yellow"
                icon="trophy"
              >
                TOP CASSETTES
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          {activeTab === 'search' ? (
            <>
              <Stack.Item>
                <Section title="Search Cassettes">
                  <Input
                    fluid
                    placeholder="Search by name, author, or description..."
                    value={searchQuery}
                    onInput={(e, value) => setSearchQuery(value)}
                    autoFocus
                  />
                  {searchQuery && (
                    <Box mt={1} color="label">
                      Found {filteredCassettes.length} cassette
                      {filteredCassettes.length !== 1 ? 's' : ''}
                    </Box>
                  )}
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
                        <Stack.Item key={cassette.ref}>
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
                                  width="64px"
                                  height="64px"
                                  style={{
                                    display: 'flex',
                                    alignItems: 'center',
                                    justifyContent: 'center',
                                  }}
                                >
                                  <DmIcon
                                    icon={cassette.icon}
                                    icon_state={cassette.icon_state}
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
                                      {cassette.author_name}{' '}
                                      <Box
                                        as="span"
                                        fontSize="11px"
                                        color="label"
                                      >
                                        (( {cassette.author_ckey} ))
                                      </Box>
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
                                          cassette_ref: cassette.ref,
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
          ) : activeTab === 'history' ? (
            <>
              <Stack.Item>
                <Tabs>
                  <Tabs.Tab
                    selected={historyTab === 'personal'}
                    onClick={() => setHistoryTab('personal')}
                  >
                    Personal History
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={historyTab === 'general'}
                    onClick={() => setHistoryTab('general')}
                  >
                    General History
                  </Tabs.Tab>
                </Tabs>
              </Stack.Item>

              <Stack.Item grow>
                {historyTab === 'personal' ? (
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
                      width="64px"
                      height="64px"
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <DmIcon
                        icon={purchase.cassette_icon}
                        icon_state={purchase.cassette_icon_state}
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
                          {purchase.cassette_author}{' '}
                          <Box as="span" fontSize="11px" color="label">
                            (( {purchase.cassette_author_ckey} ))
                          </Box>
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
                              cassette_ref: purchase.cassette_ref,
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
                      width="32px"
                      height="32px"
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <DmIcon
                        icon={purchase.cassette_icon}
                        icon_state={purchase.cassette_icon_state}
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
                          {purchase.cassette_author}{' '}
                          <Box as="span" fontSize="11px" color="label">
                            (( {purchase.cassette_author_ckey} ))
                          </Box>
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
                            width="64px"
                            height="64px"
                            style={{
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                            }}
                          >
                            <DmIcon
                              icon={cassette.cassette_icon}
                              icon_state={cassette.cassette_icon_state}
                              width="64px"
                              height="64px"
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
                                {cassette.cassette_author}{' '}
                                <Box as="span" fontSize="11px" color="label">
                                  (( {cassette.cassette_author_ckey} ))
                                </Box>
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
