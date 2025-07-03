import { InfernoNode } from 'inferno';
import { BoxProps } from './Box';
import { Image } from './Image';

export enum Direction {
  NORTH = 1,
  SOUTH = 2,
  EAST = 4,
  WEST = 8,
  NORTHEAST = NORTH | EAST,
  NORTHWEST = NORTH | WEST,
  SOUTHEAST = SOUTH | EAST,
  SOUTHWEST = SOUTH | WEST,
}

type DmIconProps = {
  /** Required: The path of the icon */
  icon: string;
  /** Required: The state of the icon */
  icon_state: string;
} & Partial<{
  /** Facing direction. See direction enum. Default is South */
  direction: Direction;
  /** Fallback icon. */
  fallback: InfernoNode;
  /** Frame number. Default is 1 */
  frame: number;
  /** Movement state. Default is false */
  movement: any;
}> &
  BoxProps;

export const DmIcon = (props: DmIconProps) => {
  const {
    className,
    direction = Direction.SOUTH,
    fallback,
    frame = 1,
    icon,
    icon_state,
    movement = false,
    ...rest
  } = props;

  const query = `${icon}?state=${icon_state}&dir=${direction}&movement=${!!movement}&frame=${frame}`;

  if (!icon) return fallback || null;

  return <Image fixErrors src={query} {...rest} />;
};
