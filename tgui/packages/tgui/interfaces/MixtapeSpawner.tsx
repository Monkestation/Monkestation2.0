import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import {
  Section,
  Button,
  Stack,
  Tabs,
  Box,
  Collapsible,
  Input,
} from '../components';
import { createSearch } from 'common/string';

type Data = {
  cassettes: Cassette[];
};

type Cassette = {
  id: string;
  name: string;
  desc: string;
  author: CassetteAuthor;
  sides: CassetteSide[];
};

type CassetteSide = {
  design: string;
  songs: Song[];
};

type Song = {
  name: string;
  url: string;
  duration: number;
  artist?: string;
  album?: string;
};

type CassetteAuthor = {
  ckey: string;
  name: string;
};

const CassetteInfo = (props: { cassette: Cassette }) => {
  const { act } = useBackend();
  const cassette = props.cassette;

  return (
    <Stack vertical>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <h2>{cassette.name}</h2>
          </Stack.Item>
          <Stack.Item>Author ckey: {cassette.author.ckey}</Stack.Item>
          <Stack.Item>Author character: {cassette.author.name}</Stack.Item>
          {cassette.sides.map((side, idx) => (
            <Stack.Item key={idx} fill>
              <Collapsible
                title={idx === 0 ? 'Side A' : 'Side B'}
                color="transparent"
                open
              >
                <Stack vertical fill>
                  {side.songs.map((song, i) => (
                    <Stack.Item key={i} className="candystripe">
                      <Stack>
                        <Stack.Item grow>{song.name}</Stack.Item>
                        <Stack.Item>
                          <a href={song.url}>
                            <Button
                              icon="external-link-alt"
                              tooltip="Open in browser"
                            />
                          </a>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  ))}
                </Stack>
              </Collapsible>
            </Stack.Item>
          ))}
        </Stack>
      </Stack.Item>
      <Stack.Item align="center">
        <Button
          onClick={() =>
            act('spawn', {
              id: cassette.id,
            })
          }
        >
          Spawn
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const MixtapeSpawner = (_props) => {
  const {
    act,
    data: { cassettes },
  } = useBackend<Data>();
  const [selected_cassette, setSelectedCassette] =
    useLocalState<Cassette | null>('selected_cassette', null);

  const [searchQuery, setSearchQuery] = useLocalState<string>(
    'searchQuery',
    '',
  );
  const nameSearch = createSearch(
    searchQuery,
    (cassette: Cassette) => cassette.name,
  );

  const filteredCassettes =
    searchQuery.length > 0 ? cassettes.filter(nameSearch) : cassettes;

  return (
    <Window title="Mixtape Spawner" width={500} height={488}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width={'50%'}>
            <Stack vertical fill>
              <Stack.Item>
                <Input
                  placeholder="Search..."
                  fluid
                  value={searchQuery}
                  onInput={(_, value) => setSearchQuery(value)}
                />
              </Stack.Item>
              <Stack.Item grow>
                <Section fill scrollable>
                  <Tabs fluid vertical>
                    {filteredCassettes.map((cassette) => (
                      <Tabs.Tab
                        key={cassette.id}
                        fluid
                        ellipsis
                        color="transparent"
                        selected={cassette.id === selected_cassette?.id}
                        onClick={() => setSelectedCassette(cassette)}
                      >
                        {cassette.name}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item width={'50%'}>
            <Section fill scrollable>
              {(selected_cassette && (
                <CassetteInfo cassette={selected_cassette} />
              )) || <Box>No cassette currently selected.</Box>}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
