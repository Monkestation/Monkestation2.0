import { capitalizeAll } from 'tgui-core/string';

import type { SlimeColor } from '../Slimepedia/types';

/** What gets ordered: a plain extract, or a crossbreed when there's a family. */
export type Item = {
  family: string | null;
  color: string;
};

export function parseItem(id: string): Item {
  const [first, second] = id.split('|');
  return second === undefined
    ? { family: null, color: first }
    : { family: first, color: second };
}

export function itemId(item: Item) {
  return item.family ? `${item.family}|${item.color}` : item.color;
}

export function spriteId(item: Item) {
  return item.family
    ? `cross-${item.family}-${item.color}`
    : `extract-${item.color}`;
}

export function itemName(item: Item, colors: Map<string, SlimeColor>) {
  const color = colors.get(item.color)?.name ?? item.color;
  return capitalizeAll(item.family ? `${item.family} ${color}` : color);
}

export function tierLabel(tier: number | null) {
  return tier === null ? 'Special' : `Tier ${tier}`;
}
