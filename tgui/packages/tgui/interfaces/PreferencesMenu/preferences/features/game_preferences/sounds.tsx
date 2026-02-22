import { multiline } from 'common/string';
import {
  CheckboxInput,
  type FeatureChoiced,
  FeatureDropdownInput,
  type FeatureToggle,
} from '../base';

export const sound_combatmode: FeatureToggle = {
  name: 'Enable combat mode sound',
  category: 'SOUND',
  description: 'When enabled, hear sounds when toggling combat mode.',
  component: CheckboxInput,
};

export const sound_midi: FeatureToggle = {
  name: 'Enable admin music',
  category: 'SOUND',
  description: 'When enabled, admins will be able to play music to you.',
  component: CheckboxInput,
};

export const sound_achievement: FeatureChoiced = {
  name: 'Achievement unlock sound',
  category: 'SOUND',
  description: multiline`
    The sound that's played when unlocking an achievement.
    If disabled, no sound will be played.
  `,
  component: FeatureDropdownInput,
};

export const hearmusic: FeatureToggle = {
  name: 'Hear Radio Music',
  category: 'SOUND',
  description:
    'When enabled, hear music played in-game by the cassette player.',
  component: CheckboxInput,
};

export const sound_ai_radio: FeatureToggle = {
  name: 'Enable AI Radio Sounds',
  category: 'SOUND',
  description: 'When enabled, hear blips whenever AIs speak over the radio.',
  component: CheckboxInput,
};
