import type { ReactNode } from 'react';
import { Box, Icon } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { SlimeName } from '../common/SlimeRancher';
import { SlimepediaSprite } from '../Slimepedia/SlimepediaSprite';
import type { SlimeColor } from '../Slimepedia/types';

/** The art circle that sits half over the top of a details pane. */
export function ItemPreview(props: { sprite: string }) {
  return (
    <Box className="ExtractRequests__preview">
      <SlimepediaSprite id={props.sprite} scale={3} />
    </Box>
  );
}

/** One tank's worth of extracts for the compressor. */
export function Ingredient(props: {
  color: SlimeColor;
  count: number;
  role: string;
  bred: boolean;
  children?: ReactNode;
}) {
  const { color, count, role, bred, children } = props;

  return (
    <Box className="ExtractRequests__ingredient">
      <Box
        className={classes([
          'ExtractRequests__ingredient-art',
          !bred && 'ExtractRequests__dim',
        ])}
      >
        <SlimepediaSprite id={`extract-${color.id}`} scale={1} />
      </Box>
      <Box className="ExtractRequests__ingredient-text">
        <SlimeName
          color={color.name}
          hex={color.hex}
          label={`${count}x ${color.name}`}
        />
        <Box className="ExtractRequests__muted">{role}</Box>
      </Box>
      {children}
    </Box>
  );
}

/** Colors to breed through, from one the round already has to the one wanted. */
export function BreedPath(props: {
  path: string[];
  colors: Map<string, SlimeColor>;
  bred: Set<string>;
}) {
  const { path, colors, bred } = props;

  if (path.length < 2) {
    return null;
  }
  return (
    <Box className="ExtractRequests__path">
      {path.map((id, index) => {
        const color = colors.get(id);
        return (
          color && (
            <Box key={id} className="ExtractRequests__path-step">
              {index > 0 && <Icon name="arrow-right" />}
              <Box
                className={classes([
                  'ExtractRequests__path-color',
                  bred.has(id) && 'ExtractRequests__path-color--bred',
                ])}
              >
                <SlimeName color={color.name} hex={color.hex} />
              </Box>
            </Box>
          )
        );
      })}
    </Box>
  );
}

/** Shortest chain of mutations from any bred color to the target. */
export function breedingPath(
  target: string,
  bred: Set<string>,
  colors: Map<string, SlimeColor>,
) {
  if (bred.has(target)) {
    return [target];
  }
  const from = new Map<string, string | null>(
    [...bred].map((id) => [id, null]),
  );
  const queue = [...bred];
  for (const id of queue) {
    for (const { into } of colors.get(id)?.mutations ?? []) {
      if (from.has(into)) {
        continue;
      }
      from.set(into, id);
      if (into === target) {
        const path = [into];
        for (let step = from.get(into); step; step = from.get(step)) {
          path.unshift(step);
        }
        return path;
      }
      queue.push(into);
    }
  }
  return [target];
}
