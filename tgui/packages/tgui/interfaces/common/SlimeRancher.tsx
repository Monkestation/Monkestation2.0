import type { CSSProperties } from 'react';
import { Box, DmIcon, Icon } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';

/** A slime's color as a dot plus its name. Shared by every window in the slime_rancher theme. */
export function SlimeName(props: {
  color: string;
  hex: string;
  suffix?: string;
}) {
  const { color, hex, suffix } = props;

  return (
    <Box className="SlimeRancher__name">
      <Box
        className={`SlimeRancher__swatch${color === 'rainbow' ? ' SlimeRancher__swatch--rainbow' : ''}`}
        style={{ '--slime-color': hex } as CSSProperties}
      />
      <span>
        {capitalizeAll(color)}
        {suffix && ` ${suffix}`}
      </span>
    </Box>
  );
}

const SPRITE_SIZE = '64px';

/** The face is its own overlay in-game, so it gets its own layer sat on top of the body. */
export function SlimePortrait(props: {
  icon: string;
  state: string;
  mood: string | null;
  transparent: BooleanLike;
}) {
  const { icon, state, mood, transparent } = props;
  return (
    <Box
      className={`SlimeRancher__portrait${transparent ? ' SlimeRancher__portrait--transparent' : ''}`}
    >
      <DmIcon
        icon={icon}
        icon_state={state}
        fallback={<Icon name="circle" size={3} />}
        width={SPRITE_SIZE}
        height={SPRITE_SIZE}
        className="SlimeRancher__sprite"
      />
      {!!mood && (
        <DmIcon
          icon={icon}
          icon_state={mood}
          fallback={null}
          width={SPRITE_SIZE}
          height={SPRITE_SIZE}
          className="SlimeRancher__sprite"
        />
      )}
    </Box>
  );
}

export function SlimePips(props: {
  label: string;
  value: number;
  maxValue: number;
}) {
  const { label, value, maxValue } = props;

  return (
    <Box className="SlimeRancher__pips">
      <Box className="SlimeRancher__pips-label">
        <strong>{label}</strong>
        <span>
          {value} / {maxValue}
        </span>
      </Box>
      <div
        className="SlimeRancher__pips-track"
        role="meter"
        aria-label={label}
        aria-valuenow={value}
        aria-valuemin={0}
        aria-valuemax={maxValue}
      >
        {Array.from({ length: maxValue }, (_, pip) => (
          <span
            key={pip}
            className={pip < value ? 'SlimeRancher__pip--on' : undefined}
          />
        ))}
      </div>
    </Box>
  );
}
