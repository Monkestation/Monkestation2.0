import { useBackend } from '../backend';
import {
  Box,
  Button,
  Image,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { formatTime } from '../format';
import { Window } from '../layouts';
import { getThumbnailUrl } from '../../common/other';
import { Component } from 'inferno';
import { BooleanLike } from 'common/react';
import { LoadingScreen } from './common/LoadingToolbox';

export enum CassetteDesign {
  Flip = 'cassette_flip',
  Blue = 'cassette_blue',
  Gray = 'cassette_gray',
  Green = 'cassette_green',
  Orange = 'cassette_orange',
  PinkStripe = 'cassette_pink_stripe',
  Purple = 'cassette_purple',
  Rainbow = 'cassette_rainbow',
  RedBlack = 'cassette_red_black',
  RedStripe = 'cassette_red_stripe',
  Camo = 'cassette_camo',
  RisingSun = 'cassette_rising_sun',
  OrangeBlue = 'cassette_orange_blue',
  Ocean = 'cassette_ocean',
  Aesthetic = 'cassette_aesthetic',
  Solaris = 'cassette_solaris',
  Ice = 'cassette_ice',
  Lz = 'cassette_lz',
  Dam = 'cassette_dam',
  Worstmap = 'cassette_worstmap',
  Wy = 'cassette_wy',
  Ftl = 'cassette_ftl',
  Eighties = 'cassette_eighties',
  Synth = 'cassette_synth',
  WhiteStripe = 'cassette_white_stripe',
  Friday = 'cassette_friday',
}

type Song = {
  name: string;
  url: string;
  length: number; // in deciseconds
  artist?: string;
  album?: string;
};

type Cassette = {
  name: string;
  desc: string;
  author: string;
  design: CassetteDesign;
  songs: Song[];
};

enum CassetteSide {
  A = 0,
  B,
}

type Data = {
  broadcasting: BooleanLike;
  song_cooldown: number;
  progress: number;
  cassette: Cassette;
  side: CassetteSide;
  current_song: number;
  switching_tracks: BooleanLike;
};

class Controls extends Component<{ data: Data }> {
  state: {
    thumbnailUrl: string | null;
  };
  constructor(props: { data: Data }) {
    super(props);
    this.state = { thumbnailUrl: null };
  }

  componentDidMount() {
    this.fetchThumbnail();
  }

  componentDidUpdate(prevProps: { data: Data }) {
    const { current_song, cassette } = this.props.data;
    const { current_song: prev_current_song, cassette: prev_cassette } =
      prevProps.data;

    if (
      getSong(current_song, cassette)?.url !==
      getSong(prev_current_song, prev_cassette)?.url
    ) {
      this.fetchThumbnail();
    }
  }

  private fetchToken = 0;

  async fetchThumbnail() {
    const token = ++this.fetchToken;
    const { current_song: current_songId } = this.props.data;
    if (current_songId === null) return this.setState({ thumbnailUrl: null });
    const current_song = getSong(current_songId, this.props.data.cassette);
    if (!current_song?.url) return this.setState({ thumbnailUrl: null });
    const thumb = await getThumbnailUrl(current_song.url);
    if (token === this.fetchToken) {
      this.setState({ thumbnailUrl: thumb });
    }
  }

  render() {
    const { act } = useBackend();
    const {
      progress,
      broadcasting,
      current_song: current_songId,
      song_cooldown,
    } = this.props.data;
    const cassette = this.props.data?.cassette;

    const current_song = getSong(current_songId, cassette);

    const { thumbnailUrl } = this.state;
    if (current_song === null && thumbnailUrl !== null) {
      this.setState({ thumbnailUrl: null });
    }

    return (
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Title">
              <Box>{current_song?.name || 'N/A'}</Box>
            </LabeledList.Item>
            {current_song?.artist && (
              <LabeledList.Item label="Artist">
                {current_song.artist}
              </LabeledList.Item>
            )}
            {current_song?.album && (
              <LabeledList.Item label="Album">
                {current_song.album}
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Controls">
              <Button
                icon="play"
                disabled={broadcasting || !!song_cooldown}
                onClick={() => act('play')}
                tooltip={
                  broadcasting
                    ? null
                    : song_cooldown
                      ? `The DJ station needs time to cool down after playing the last song. Time left: ${formatTime(song_cooldown, 'short')}`
                      : null
                }
              >
                Play
              </Button>
              <Button
                icon="stop"
                disabled={!broadcasting}
                onClick={() => act('stop')}
              >
                Stop
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Progress">
              <ProgressBar value={progress} maxValue={1} color="good">
                {broadcasting && current_song
                  ? `${formatTime(progress * current_song.length, 'short')} / ${formatTime(
                      current_song.length,
                      'short',
                    )}`
                  : 'N/A'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Item>
          {thumbnailUrl && (
            <Box mt={2} textAlign="center">
              <Image
                src={thumbnailUrl}
                alt="Track thumbnail"
                style={{ maxWidth: '50%' }}
              />
            </Box>
          )}
        </Stack.Item>
      </Stack>
    );
  }
}

const AvailableTracks = ({
  songs,
  currentSong,
}: {
  songs: Song[];
  currentSong: Song | null;
}) => {
  const { act } = useBackend<Data>();

  return (
    <Stack vertical fill>
      {songs.map((song, i) => (
        <Stack.Item key={i}>
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                icon="play"
                selected={currentSong?.name === song.name}
                onClick={() => act('set_track', { index: i })}
              >
                {song.name}
              </Button>
            </Stack.Item>
            <Stack.Item>
              <a href={song.url}>
                <Button icon="external-link-alt" tooltip="Open in browser" />
              </a>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const DjStation = () => {
  const { act, data } = useBackend<Data>();
  const { side, cassette } = data;
  const songs = cassette?.songs ?? [];

  const currentSong = getSong(data.current_song, cassette);

  return (
    <Window title="DJ Station" width={1000} height={650}>
      <Window.Content>
        {!!data.switching_tracks && (
          <LoadingScreen CustomIcon="spinner" CustomText="Selecting track..." />
        )}
        <Stack horizontal fill>
          <Stack.Item grow={1}>
            <Stack vertical fill>
              <Section
                title={
                  cassette
                    ? cassette.name || 'Untitled Cassette'
                    : 'No Tape Inserted'
                }
                buttons={
                  <Button fluid icon="eject" onClick={() => act('eject')}>
                    Eject
                  </Button>
                }
              >
                <LabeledList>
                  <LabeledList.Item label="Tape Author">
                    {cassette?.author || 'Unknown'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Description">
                    {cassette?.desc || 'No description'}
                  </LabeledList.Item>
                  <LabeledList.Item label="Total Tracks">
                    {songs.length}
                  </LabeledList.Item>
                  <LabeledList.Item label="Total Duration">
                    {songs.length
                      ? formatTime(
                          songs.reduce((sum, s) => sum + s.length, 0),
                          'default',
                        )
                      : 'N/A'}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
              <Section
                fill
                scrollable
                title={`Track list - Side ${side !== null ? (side === 0 ? 'A' : 'B') : '?'}`}
              >
                {songs?.length ? (
                  <AvailableTracks songs={songs} currentSong={currentSong} />
                ) : (
                  <Box color="bad">
                    {cassette ? 'No songs on this side.' : 'No tape inserted'}
                  </Box>
                )}
              </Section>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={1}>
            <Section
              title={
                data.broadcasting
                  ? 'Currently Playing'
                  : data.current_song
                    ? 'Selected Track'
                    : 'No Track Selected'
              }
              fill
            >
              <Controls data={data} />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const getSong = (index: number, cassette?: Cassette): Song | null => {
  return cassette ? cassette.songs[index] : null;
};
