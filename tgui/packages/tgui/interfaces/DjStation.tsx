import type { BooleanLike } from 'common/react';
import { useEffect, useRef, useState } from 'react';
import { getThumbnailUrl } from '../../common/other';
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

export function Controls({ data }: { data: Data }) {
  const { act } = useBackend();
  const [thumbnailUrl, setThumbnailUrl] = useState<string | null>(null);

  const fetchTokenRef = useRef(0);

  const {
    current_song: currentSongId,
    cassette,
    progress,
    broadcasting,
    song_cooldown,
  } = data;
  const current_song = getSong(currentSongId, cassette);

  useEffect(() => {
    const fetchThumbnail = async () => {
      const token = ++fetchTokenRef.current;
      if (currentSongId === null) {
        setThumbnailUrl(null);
        return;
      }

      if (!current_song?.url) {
        setThumbnailUrl(null);
        return;
      }

      const thumb = await getThumbnailUrl(current_song.url);
      if (token === fetchTokenRef.current) {
        setThumbnailUrl(thumb);
      }
    };

    fetchThumbnail();
  }, [currentSongId, cassette]);

  useEffect(() => {
    if (current_song === null && thumbnailUrl !== null) {
      setThumbnailUrl(null);
    }
  }, [current_song, thumbnailUrl]);

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
            <Image src={thumbnailUrl} style={{ maxWidth: '50%' }} />
          </Box>
        )}
      </Stack.Item>
    </Stack>
  );
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
            <Stack.Item grow style={{ minWidth: 0 }}>
              <Button
                fluid
                icon="play"
                selected={currentSong?.name === song.name}
                onClick={() => act('set_track', { index: i })}
                style={{
                  whiteSpace: 'nowrap!important',
                  overflow: 'hidden!important',
                  textOverflow: 'ellipsis!important',
                }}
                tooltip={song.name.length > 48 ? song.name : undefined}
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
        <Stack fill>
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
