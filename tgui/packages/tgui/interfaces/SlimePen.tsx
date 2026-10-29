import type { CSSProperties } from 'react';
import { useState } from 'react';
import { type HsvaColor, hexToHsva, hsvaToHex } from 'tgui-core/color';
import { Box, Button, Modal, ProgressBar } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Hue, SaturationValue } from './ColorPickerModal/Color';
import { HexColorInput } from './ColorPickerModal/TextSetter';
import { SlimeName, SlimePips, SlimePortrait } from './common/SlimeRancher';

type MutationType = {
  color: string;
  color_hex: string;
};

type Slime = {
  ref: string;
  name: string;
  health: number;
  nutrition: number;
  life_stage: string;
  amount_grown: number;
  color: string;
  color_hex: string;
  possible_mutations: {
    type: string;
    progress: 'unfed' | 'partial' | 'ready';
  }[];
  sprite_icon: string;
  sprite_state: string;
  mood_state: string | null;
  transparent: BooleanLike;
};

type Data = {
  slimes: Slime[];
  barrier_color: string;
  mutation_types: Record<string, MutationType>;
  width: number;
  height: number;
  soft_capacity: number;
  max_nutrition: number;
  nutrition_hungry: number;
  nutrition_starving: number;
  growth_threshold: number;
  default_color: string;
};

const PROGRESS_TITLES = {
  unfed: 'Not fed yet',
  partial: 'Partly fed',
  ready: 'Fed and ready',
};

// three full rows, so a small pen isn't mostly empty shell
const TRAY_MIN_SOCKETS = 12;

// the game's default "blue baby slime (123)", a renamed slime won't match
const DEFAULT_NAME = /^.+ (?:baby|adult) slime \((\d+)\)$/;

function slimeNumber(slime: Slime) {
  return DEFAULT_NAME.exec(slime.name)?.[1] ?? null;
}

function SlimeSocket(props: {
  slime: Slime;
  selected: boolean;
  onSelect: () => void;
}) {
  const { data } = useBackend<Data>();
  const { nutrition_hungry, nutrition_starving } = data;
  const { slime, selected, onSelect } = props;
  const number = slimeNumber(slime);

  let status: string | null = null;
  if (slime.nutrition < nutrition_starving || slime.health < 25) {
    status = 'danger';
  } else if (slime.nutrition < nutrition_hungry || slime.health < 50) {
    status = 'caution';
  }

  return (
    <button
      type="button"
      className={`SlimePen__socket${selected ? ' SlimePen__socket--selected' : ''}`}
      aria-pressed={selected}
      onClick={onSelect}
    >
      <SlimePortrait
        icon={slime.sprite_icon}
        state={slime.sprite_state}
        mood={slime.mood_state}
        transparent={slime.transparent}
      />
      <span className="SlimePen__socket-label">
        <span>{number ? capitalizeAll(slime.color) : slime.name}</span>
        <span className="SlimePen__number">
          {number ? `#${number}` : capitalizeAll(slime.color)}
        </span>
      </span>
      {!!status && (
        <span
          className={`SlimePen__status SlimePen__status--${status}`}
          title={
            status === 'danger' ? 'Starving or badly hurt' : 'Hungry or hurt'
          }
        />
      )}
    </button>
  );
}

function SlimeDetails(props: { slime: Slime }) {
  const { data } = useBackend<Data>();
  const {
    mutation_types,
    max_nutrition,
    nutrition_hungry,
    nutrition_starving,
    growth_threshold,
  } = data;
  const { slime } = props;
  const number = slimeNumber(slime);

  let nutritionColor: string | undefined;
  if (slime.nutrition < nutrition_starving) {
    nutritionColor = 'bad';
  } else if (slime.nutrition < nutrition_hungry) {
    nutritionColor = 'average';
  }

  return (
    <Box className="SlimePen__details">
      <Box className="SlimePen__hero">
        <SlimePortrait
          icon={slime.sprite_icon}
          state={slime.sprite_state}
          mood={slime.mood_state}
          transparent={slime.transparent}
        />
      </Box>
      <Box className="SlimePen__details-title">
        <h2>
          {number ? (
            <SlimeName
              color={slime.color}
              hex={slime.color_hex}
              suffix="slime"
            />
          ) : (
            slime.name
          )}{' '}
          <span className="SlimePen__number">
            {number ? `#${number}` : `${capitalizeAll(slime.color)} slime`}
          </span>
        </h2>
        <span className="SlimeRancher__chip">
          {capitalizeAll(slime.life_stage)}
        </span>
      </Box>
      <Box className="SlimePen__meter">
        <span>Health</span>
        <ProgressBar
          value={slime.health}
          maxValue={100}
          ranges={{
            good: [50, Infinity],
            average: [25, 50],
            bad: [-Infinity, 25],
          }}
        >
          {slime.health}%
        </ProgressBar>
      </Box>
      <Box className="SlimePen__meter">
        <span>Nutrition</span>
        <ProgressBar
          value={slime.nutrition}
          maxValue={max_nutrition}
          color={nutritionColor}
        >
          {slime.nutrition} / {max_nutrition}
        </ProgressBar>
      </Box>
      <SlimePips
        label="Growth"
        value={slime.amount_grown}
        maxValue={growth_threshold}
      />
      {slime.possible_mutations.length > 0 && (
        <Box className="SlimePen__meter">
          <span>Can become</span>
          <Box className="SlimePen__mutations">
            {slime.possible_mutations.map(({ type, progress }) => {
              const mutation = mutation_types[type];
              if (!mutation) {
                return null;
              }
              return (
                <span
                  key={type}
                  className={`SlimeRancher__chip SlimePen__mutation SlimePen__mutation--${progress}`}
                  title={PROGRESS_TITLES[progress]}
                  style={
                    { '--slime-color': mutation.color_hex } as CSSProperties
                  }
                >
                  {capitalizeAll(mutation.color)}
                </span>
              );
            })}
          </Box>
        </Box>
      )}
    </Box>
  );
}

/** Picks the fence tint. Built out of the shared color picker pieces so it can live in this window. */
function ColorModal(props: { onClose: () => void }) {
  const { act, data } = useBackend<Data>();
  const { barrier_color, default_color } = data;
  const { onClose } = props;
  const [color, setColor] = useState<HsvaColor>(hexToHsva(barrier_color));

  const handleChange = (params: Partial<HsvaColor>) =>
    setColor((current) => ({ ...current, ...params }));

  return (
    <Modal className="SlimeRancher__card SlimePen__color-modal">
      <h2 className="SlimeRancher__heading">Fence color</h2>
      <div className="react-colorful">
        <SaturationValue hsva={color} onChange={handleChange} />
        <Hue
          hue={color.h}
          onChange={handleChange}
          className="react-colorful__last-control"
        />
      </div>
      <HexColorInput
        fluid
        color={hsvaToHex(color)}
        onChange={(hex) => setColor(hexToHsva(hex))}
      />
      <Box className="SlimePen__color-actions">
        <Button onClick={() => setColor(hexToHsva(default_color))}>
          Reset
        </Button>
        <Button onClick={onClose}>Cancel</Button>
        <Button
          onClick={() => {
            act('set_color', { color: hsvaToHex(color) });
            onClose();
          }}
        >
          Apply
        </Button>
      </Box>
    </Modal>
  );
}

export const SlimePen = () => {
  const { data } = useBackend<Data>();
  const { slimes, barrier_color, width, height, soft_capacity } = data;
  const [pickingColor, setPickingColor] = useState(false);
  const [selectedRef, setSelectedRef] = useState<string | null>(null);
  const selected =
    slimes.find((slime) => slime.ref === selectedRef) ?? slimes[0];
  const emptySockets = Math.max(
    0,
    Math.min(soft_capacity, TRAY_MIN_SOCKETS) - slimes.length,
  );

  return (
    <Window width={720} height={560} theme="slime_rancher">
      {pickingColor && <ColorModal onClose={() => setPickingColor(false)} />}
      <Window.Content scrollable className="SlimePen">
        <Box className="SlimePen__shell">
          {slimes.length === 0 ? (
            <Box className="SlimePen__empty">
              <span className="SlimePen__empty-socket">?</span>
              <h1>Nothing in here but floor.</h1>
              <p>Slimes inside the fence will show up here.</p>
            </Box>
          ) : (
            <Box className="SlimePen__workspace">
              <Box className="SlimePen__tray">
                {slimes.map((slime) => (
                  <SlimeSocket
                    key={slime.ref}
                    slime={slime}
                    selected={slime === selected}
                    onSelect={() => setSelectedRef(slime.ref)}
                  />
                ))}
                {Array.from({ length: emptySockets }, (_, socket) => (
                  <span key={socket} className="SlimePen__socket--empty" />
                ))}
              </Box>
              <SlimeDetails slime={selected} />
            </Box>
          )}
          <Box className="SlimePen__legend">
            <span className="SlimePen__legend-item">
              <strong>
                {width} x {height}
              </strong>{' '}
              pen
            </span>
            <span className="SlimePen__legend-item">
              <strong>
                {slimes.length} / {soft_capacity}
              </strong>{' '}
              slimes
            </span>
            <button
              type="button"
              className="SlimePen__fence"
              onClick={() => setPickingColor(true)}
            >
              Fence color
              <span
                className="SlimePen__fence-swatch"
                style={{ '--slime-color': barrier_color } as CSSProperties}
              />
            </button>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};
