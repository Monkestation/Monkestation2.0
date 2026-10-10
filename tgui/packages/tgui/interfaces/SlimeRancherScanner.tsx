import type { ReactNode } from 'react';
import {
  Box,
  DmIcon,
  Icon,
  NoticeBox,
  ProgressBar,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalizeAll } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SlimeName, SlimePips, SlimePortrait } from './common/SlimeRancher';

type Requirement = {
  name: string;
  icon: string;
  icon_state: string;
};

type WantedItem = Requirement & {
  done: BooleanLike;
};

type WantedDrain = Requirement & {
  total: number;
  drained: number;
};

type Mutation = {
  color: string;
  color_hex: string;
  ready: BooleanLike;
  items: WantedItem[];
  drains: WantedDrain[];
};

// static data
type BuiltInNumberData = {
  max_growth: number;
  max_crossbreed_progress: number;
  max_powerlevel: number;
  max_nutrition: number;
  nutrition_starving: number;
  nutrition_hungry: number;
  extract_cost: number;
};

type BaseSlimeData = {
  scanned: BooleanLike;
  name: string;
  color: string;
  color_hex: string;
  sprite_icon: string;
  sprite_state: string;
  transparent: BooleanLike;
};

type SlimeInfoData = {
  mood_state: string | null;
  life_stage: string;
  health: number;
  max_health: number;
  nutrition: number;
  powerlevel: number;
  cores: number;
  growth: number;
  ranch_progress: number;
  split_cost: number;
};

type SlimeMutationData = {
  mutation_chance: number;
  crossbreed_modification: string | null;
  crossbreed_progress: number;
  mutations: Mutation[];
};

// i just split these into multiple subtypes then mushed them together bc like i thought one data type was just too fucking huge ~Lucy
type Data = {
  scanned: BooleanLike;
} & BaseSlimeData &
  SlimeInfoData &
  SlimeMutationData &
  BuiltInNumberData;

const REQUIREMENT_ICON_SIZE = '48px';

/** Fixed size so an odd-sized source icon can't shove one row out of line with its neighbors. */
function RequirementIcon(props: { requirement: Requirement }) {
  const { requirement } = props;

  return (
    <DmIcon
      icon={requirement.icon}
      icon_state={requirement.icon_state}
      fallback={<Icon name="question" />}
      width={REQUIREMENT_ICON_SIZE}
      height={REQUIREMENT_ICON_SIZE}
    />
  );
}

function RequirementCell(props: {
  requirement: Requirement;
  done: BooleanLike;
  children?: ReactNode;
}) {
  const { requirement, done, children } = props;

  return (
    <Box
      className={`SlimeRancherScanner__requirement${done ? ' SlimeRancherScanner__requirement--done' : ''}`}
    >
      <RequirementIcon requirement={requirement} />
      <span>{requirement.name}</span>
      {children}
    </Box>
  );
}

function MutationRow(props: { mutation: Mutation }) {
  const { mutation } = props;

  return (
    <Box className="SlimeRancherScanner__recipe">
      <Box className="SlimeRancherScanner__recipe-heading">
        <SlimeName color={mutation.color} hex={mutation.color_hex} />
        {!!mutation.ready && (
          <span className="SlimeRancherScanner__ready">
            <Icon name="check" /> Ready
          </span>
        )}
      </Box>
      <Box className="SlimeRancherScanner__requirements">
        {mutation.items.map((item) => (
          <RequirementCell key={item.name} requirement={item} done={item.done}>
            {!!item.done && (
              <Icon name="check" className="SlimeRancherScanner__completed" />
            )}
          </RequirementCell>
        ))}
        {mutation.drains.map((drain) => {
          const done = drain.drained >= drain.total;
          return (
            <RequirementCell key={drain.name} requirement={drain} done={done}>
              <ProgressBar
                value={drain.drained}
                maxValue={drain.total}
                color={done ? 'good' : 'average'}
              >
                {drain.drained} / {drain.total}
              </ProgressBar>
            </RequirementCell>
          );
        })}
      </Box>
    </Box>
  );
}

function Vitals() {
  const { data } = useBackend<Data>();
  const {
    color,
    color_hex,
    sprite_icon,
    sprite_state,
    mood_state,
    transparent,
    life_stage,
    health,
    max_health,
    nutrition,
    max_nutrition,
    nutrition_starving,
    nutrition_hungry,
    powerlevel,
    max_powerlevel,
    cores,
    growth,
    max_growth,
    ranch_progress,
    split_cost,
    extract_cost,
    mutation_chance,
    crossbreed_modification,
    crossbreed_progress,
    max_crossbreed_progress,
    mutations,
  } = data;
  const anyReady = mutations.some((mutation) => !!mutation.ready);
  const primed = split_cost > 0;
  const ranchTarget = primed ? split_cost : extract_cost;

  const starving = nutrition < nutrition_starving;
  const hungry = nutrition < nutrition_hungry;

  return (
    <Box className="SlimeRancher__card SlimeRancherScanner__vitals">
      <Box className="SlimeRancherScanner__identity">
        <Box className="SlimeRancherScanner__portrait-well">
          <SlimePortrait
            icon={sprite_icon}
            state={sprite_state}
            mood={mood_state}
            transparent={transparent}
          />
        </Box>
        <Box className="SlimeRancherScanner__identity-text">
          <h1>
            <SlimeName color={color} hex={color_hex} suffix="slime" />
          </h1>
          <span className="SlimeRancher__chip SlimeRancherScanner__life-stage">
            {capitalizeAll(life_stage)}
          </span>
        </Box>
      </Box>
      {!!starving && (
        <NoticeBox danger>
          This slime is starving, feed the poor thing soon!
        </NoticeBox>
      )}
      {!starving && !!hungry && <NoticeBox>This slime is hungry.</NoticeBox>}
      <hr className="SlimeRancher__rule" />
      <Box className="SlimeRancherScanner__meters">
        <Box className="SlimeRancherScanner__meter">
          <span>Health</span>
          <ProgressBar
            value={health}
            maxValue={max_health}
            ranges={{
              good: [max_health * 0.5, Infinity],
              average: [max_health * 0.25, max_health * 0.5],
              bad: [-Infinity, max_health * 0.25],
            }}
          >
            {health} / {max_health}
          </ProgressBar>
        </Box>
        <Box className="SlimeRancherScanner__meter">
          <span>Nutrition</span>
          {/* colored off the flags rather than a range, so it matches the game's own hunger thresholds */}
          <ProgressBar
            value={nutrition}
            maxValue={max_nutrition}
            color={starving ? 'bad' : hungry ? 'average' : 'good'}
          >
            {nutrition} / {max_nutrition}
          </ProgressBar>
        </Box>
        <Box className="SlimeRancherScanner__meter">
          <span>{primed ? 'Next: split' : 'Next: extract'}</span>
          <ProgressBar
            value={ranch_progress}
            maxValue={ranchTarget}
            color={primed ? 'good' : undefined}
          >
            {ranch_progress} / {ranchTarget}
          </ProgressBar>
        </Box>
        <Tooltip
          content={
            anyReady
              ? 'Chance this slime mutates instead of secreting an extract, once a recipe is ready.'
              : 'No recipe is finished yet, so this slime will only secrete extracts.'
          }
        >
          <Box className="SlimeRancherScanner__meter">
            <span>Mutation chance {!anyReady && <Icon name="lock" />}</span>
            <ProgressBar
              className={
                !anyReady
                  ? 'SlimeRancherScanner__instability--locked'
                  : undefined
              }
              value={mutation_chance}
              maxValue={100}
            >
              {mutation_chance}%
            </ProgressBar>
          </Box>
        </Tooltip>
      </Box>
      <hr className="SlimeRancher__rule" />
      <SlimePips label="Growth" value={growth} maxValue={max_growth} />
      <SlimePips
        label="Electric charge"
        value={powerlevel}
        maxValue={max_powerlevel}
      />
      {!!crossbreed_modification && (
        <SlimePips
          label={`Core mutation: ${crossbreed_modification}`}
          value={crossbreed_progress}
          maxValue={max_crossbreed_progress}
        />
      )}
      <Box className="SlimeRancherScanner__readings">
        <Box className="SlimeRancher__well">
          <span>Cores</span>
          <strong>{cores}</strong>
        </Box>
      </Box>
    </Box>
  );
}

function Mutations() {
  const { data } = useBackend<Data>();
  const { mutations } = data;
  const anyReady = mutations.some((mutation) => !!mutation.ready);

  if (mutations.length === 0) {
    return (
      <Box className="SlimeRancher__card SlimeRancherScanner__mutations">
        <h2 className="SlimeRancher__heading SlimeRancherScanner__badge">
          Mutations
        </h2>
        <p>This slime has nowhere left to mutate to.</p>
      </Box>
    );
  }

  return (
    <Box className="SlimeRancher__card SlimeRancherScanner__mutations">
      <h2 className="SlimeRancher__heading">Mutations</h2>
      {!anyReady && (
        <NoticeBox info>
          No recipe is finished yet, so this slime will only secrete extracts.
        </NoticeBox>
      )}
      <Box className="SlimeRancherScanner__recipes">
        {mutations.map((mutation) => (
          <MutationRow key={mutation.color} mutation={mutation} />
        ))}
      </Box>
    </Box>
  );
}

export const SlimeRancherScanner = () => {
  const { data } = useBackend<Data>();
  const { scanned } = data;

  return (
    <Window width={780} height={600} theme="slime_rancher">
      <Window.Content scrollable className="SlimeRancherScanner">
        {!scanned ? (
          <Box className="SlimeRancher__empty">
            <Icon name="crosshairs" size={3} />
            <h1>No slime currently scanned.</h1>
            <p>Point the scanner at any slime you can see.</p>
          </Box>
        ) : (
          <>
            <Vitals />
            <Mutations />
          </>
        )}
      </Window.Content>
    </Window>
  );
};
