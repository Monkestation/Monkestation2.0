import type { BooleanLike } from 'tgui-core/react';

export type Requirement = {
  name: string;
  icon: string;
  icon_state: string;
};

export type Drain = Requirement & {
  amount: number;
};

export type Mutation = {
  into: string;
  items: Requirement[];
  drains: Drain[];
};

export type Reaction = {
  reagents: { name: string; amount: number }[];
  desc: string;
};

export type SlimeColor = {
  id: string;
  name: string;
  hex: string;
  transparent: BooleanLike;
  /** Null for rainbow, which sits outside the breeding tree. */
  tier: number | null;
  mutations: Mutation[];
  parents: string[];
  effect: string;
  reactions: Reaction[];
};

export type Crossbreed = {
  color: string;
  desc: string;
  /** False for crossbreeds that can't be handed over, so can't be ordered. */
  orderable: BooleanLike;
};

export type Family = {
  id: string;
  source: string;
  crossbreeds: Crossbreed[];
};

export type SlimepediaData = {
  colors: SlimeColor[];
  families: Family[];
  effect_extracts: number;
  color_extracts: number;
};

/** Lets either page jump to an entry on the other. */
export type SlimepediaNavigation = {
  colors: Map<string, SlimeColor>;
  showColor: (id: string) => void;
  showFamily: (id: string) => void;
};

export enum SlimepediaPage {
  Slimes = 'slimes',
  Crossbreeds = 'crossbreeds',
}
