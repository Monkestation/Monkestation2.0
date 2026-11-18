import { type BooleanLike, classes } from 'tgui-core/react';

/** A sprite from the slimepedia spritesheet. Every sheet entry is 32px, scaled up whole so pixels stay crisp. */
export function SlimepediaSprite(props: {
  id: string;
  scale?: 1 | 2 | 3;
  transparent?: BooleanLike;
}) {
  const { id, scale = 2, transparent } = props;

  return (
    <span
      className={classes([
        'Slimepedia__sprite',
        `Slimepedia__sprite--x${scale}`,
        !!transparent && 'Slimepedia__sprite--transparent',
      ])}
    >
      <span className={`slimepedia32x32 ${id}`} />
    </span>
  );
}
