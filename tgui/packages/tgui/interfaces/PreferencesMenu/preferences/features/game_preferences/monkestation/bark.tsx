import { CheckboxInput, FeatureToggle } from '../../base';

export const sound_barks_short: FeatureToggle = {
  name: 'Bark Sounds: Single Bark',
  category: 'BARK SOUNDS',
  description:
    'When enabled, you will only hear a single sound when players talk.',
  component: CheckboxInput,
};

export const sound_barks_limited_pitch: FeatureToggle = {
  name: 'Bark Sounds: Disable Pitch Modification',
  category: 'BARK SOUNDS',
  description:
    'When enabled, bark sounds will not play with any character pitch modifications.',
  component: CheckboxInput,
};

export const sound_barks_only_goon: FeatureToggle = {
  name: 'Bark Sounds: Only Goonstation',
  category: 'BARK SOUNDS',
  description:
    'When enabled, characters will only make goonstation bark sounds.',
  component: CheckboxInput,
};
