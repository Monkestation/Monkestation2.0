import { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Input, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

type CassetteData = {
  id: string;
  name: string;
  desc: string;
  author_name: string;
  author_ckey: string;
  ref: string;
};

type CassetteLibraryData = {
  stored_credits: number;
  cassette_cost: number;
  busy: boolean;
  cassettes: CassetteData[];
};

export const CassetteLibrary = (props) => {
  const { act, data } = useBackend<CassetteLibraryData>();
  const { stored_credits, cassette_cost, busy, cassettes } = data;

  const [searchQuery, setSearchQuery] = useState('');

  // Filter cassettes based on search query
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

  // Show only the latest 20 cassettes if no search is active
  const displayedCassettes = searchQuery
    ? filteredCassettes
    : filteredCassettes.slice(0, 20);

  return (
    <Window title="Cassette Library" width={700} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Box fontSize="16px" bold>
                Credits: {stored_credits} cr
              </Box>
              <Box fontSize="14px" color="label" mt={0.5}>
                Cost per cassette: {cassette_cost} cr
              </Box>
            </Section>
          </Stack.Item>

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
                  : 'Latest 20 Cassettes (search to see more)'
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
                <Table>
                  <Table.Row header>
                    <Table.Cell>Name</Table.Cell>
                    <Table.Cell>Author</Table.Cell>
                    <Table.Cell width="40%">Description</Table.Cell>
                    <Table.Cell collapsing>Action</Table.Cell>
                  </Table.Row>
                  {displayedCassettes.map((cassette) => (
                    <Table.Row key={cassette.ref}>
                      <Table.Cell bold>{cassette.name}</Table.Cell>
                      <Table.Cell>
                        {cassette.author_name}
                        <Box fontSize="11px" color="label">
                          ({cassette.author_ckey})
                        </Box>
                      </Table.Cell>
                      <Table.Cell>
                        <Box
                          style={{
                            maxWidth: '300px',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}
                          title={cassette.desc}
                        >
                          {cassette.desc}
                        </Box>
                      </Table.Cell>
                      <Table.Cell collapsing>
                        <Button
                          icon="shopping-cart"
                          content={`${cassette_cost} cr`}
                          disabled={busy || stored_credits < cassette_cost}
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
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </Stack.Item>

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
