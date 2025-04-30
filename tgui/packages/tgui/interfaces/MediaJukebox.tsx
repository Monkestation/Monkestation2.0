import { round } from 'common/math';
import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
} from '../components';
import { formatTime } from '../format';
import { Window } from '../layouts';

enum LoopMode {
  Next = 1,
  Random = 2,
  Repeat = 3,
  Once = 4,
}

type Track = {
  ref: string;
  title: string;
  artist: string;
  genre: string;
  duration: number;
};

type Data = {
  playing: BooleanLike;
  loop_mode: LoopMode;
  volume: number;
  position: number;
  current_track?: Track;
  tracks: Track[];
};

const LoopModeControls = () => {
  const {
    act,
    data: { loop_mode },
  } = useBackend<Data>();
  return (
    <>
      <Button
        icon="play"
        onClick={() => act('set_loop_mode', { mode: LoopMode.Next })}
        selected={loop_mode === LoopMode.Next}
      >
        Next
      </Button>
      <Button
        icon="random"
        onClick={() => act('set_loop_mode', { mode: LoopMode.Random })}
        selected={loop_mode === LoopMode.Random}
      >
        Shuffle
      </Button>
      <Button
        icon="redo"
        onClick={() => act('set_loop_mode', { mode: LoopMode.Repeat })}
        selected={loop_mode === LoopMode.Repeat}
      >
        Repeat
      </Button>
      <Button
        icon="step-forward"
        onClick={() => act('set_loop_mode', { mode: LoopMode.Once })}
        selected={loop_mode === LoopMode.Once}
      >
        Once
      </Button>
    </>
  );
};

const Controls = () => {
  const { act, data } = useBackend<Data>();
  const { current_track, volume, position } = data;

  const playing = !!(data.playing && current_track);
  const progress = playing ? position / current_track.duration : 0;

  return (
    <LabeledList>
      <LabeledList.Item label="Title">
        <Box>
          {playing
            ? `${current_track.title} by ${current_track.artist || 'Unknown'}`
            : 'Stopped'}
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Controls">
        <Button icon="play" disabled={playing} onClick={() => act('play')}>
          Play
        </Button>
        <Button icon="stop" disabled={!playing} onClick={() => act('stop')}>
          Stop
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Loop Mode">
        <LoopModeControls />
      </LabeledList.Item>
      <LabeledList.Item label="Progress">
        <ProgressBar value={progress} maxValue={1} color="good">
          {playing &&
            `${formatTime(position)} / ${formatTime(current_track.duration)}`}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Volume">
        <Slider
          minValue={0}
          step={1}
          value={volume}
          maxValue={100}
          ranges={{
            good: [75, Infinity],
            average: [25, 75],
            bad: [0, 25],
          }}
          format={(val) => round(val, 1) + '%'}
          onChange={(e, volume) => act('set_volume', { volume })}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

const AvailableTracks = () => {
  const { act, data } = useBackend<Data>();
  const { playing, tracks, current_track } = data;

  let genre_songs = tracks.reduce((acc, obj) => {
    let key = obj.genre || 'Uncategorized';
    if (!acc[key]) {
      acc[key] = [];
    }
    acc[key].push(obj);
    return acc;
  }, {});

  let true_genre = !!playing && (current_track?.genre || 'Uncategorized');

  return Object.keys(genre_songs)
    .sort()
    .map((genre) => (
      <Collapsible
        title={genre}
        key={genre}
        color={true_genre === genre ? 'green' : 'default'}
        child_mt={0}
      >
        <div style={{ 'margin-left': '1em' }}>
          {genre_songs[genre].map((track) => (
            <Button
              fluid
              icon="play"
              key={track.ref}
              selected={current_track?.ref === track.ref}
              onClick={() => act('set_track', { ref: track.ref })}
            >
              {track.title}
            </Button>
          ))}
        </div>
      </Collapsible>
    ));
};

export const MediaJukebox = () => {
  const {
    data: { tracks },
  } = useBackend<Data>();

  return (
    <Window width={450} height={600} resizable>
      <Window.Content scrollable>
        <Section title="Currently Playing">
          <Controls />
        </Section>
        <Section title="Available Tracks" scrollable>
          {tracks.length ? (
            <AvailableTracks />
          ) : (
            <Box color="bad">Error: No songs loaded.</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
