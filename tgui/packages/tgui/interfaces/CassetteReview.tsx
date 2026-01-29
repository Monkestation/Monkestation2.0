import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Section, Button, Stack, Collapsible, Box } from '../components';
import { Window } from '../layouts';

enum CassetteStatus {
  Unapproved = 0,
  Reviewing = 1,
  Approved = 2,
  Denied = 3,
}

type CassetteTrack = {
  title: string;
  url: string;
  duration: number; // deciseconds
  artist?: string;
  album?: string;
};

type CassetteSide = {
  icon: string;
  tracks: CassetteTrack[];
};

type Cassette = {
  id: string;
  name: string;
  desc: string;
  author_ckey: string;
  author_name: string;
  status: CassetteStatus;
  songs: {
    side1?: CassetteSide;
    side2?: CassetteSide;
  };
};

type Data = {
  cassette: Cassette;
  can_approve: BooleanLike;
};

export const CassetteReview = () => {
  const {
    act,
    data: { cassette, can_approve },
  } = useBackend<Data>();

  return (
    <Window width={600} height={313}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section fill scrollable title={cassette.name}>
              <Stack vertical fill>
                <Stack.Item>Author ckey: {cassette.author_ckey}</Stack.Item>
                <Stack.Item>
                  Author character: {cassette.author_name}
                </Stack.Item>
                <Stack.Item>
                  Current Status:{' '}
                  {cassette.status === CassetteStatus.Approved ? (
                    <Box inline textColor="green">
                      APPROVED
                    </Box>
                  ) : cassette.status === CassetteStatus.Denied ? (
                    <Box inline textColor="red">
                      DENIED
                    </Box>
                  ) : (
                    <Box inline textColor="yellow">
                      Reviewing
                    </Box>
                  )}
                </Stack.Item>
                {[cassette.songs.side1, cassette.songs.side2].map(
                  (side, idx) => (
                    <Stack.Item key={idx}>
                      <Collapsible
                        title={idx === 0 ? 'Side A' : 'Side B'}
                        color="transparent"
                        open
                      >
                        <Stack vertical fill>
                          {side?.tracks.map((song, i) => (
                            <Stack.Item key={i} className="candystripe">
                              <Stack>
                                <Stack.Item grow>{song.title}</Stack.Item>
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
                  ),
                )}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item align="center">
            {can_approve ? (
              <Stack>
                <Stack.Item>
                  <Button onClick={() => act('approve')}>Approve</Button>
                </Stack.Item>
                <Stack.Item>
                  <Button onClick={() => act('deny')}>Deny</Button>
                </Stack.Item>
              </Stack>
            ) : (
              <Button disabled>
                Not enough permissions to approve/deny cassettes.
              </Button>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
