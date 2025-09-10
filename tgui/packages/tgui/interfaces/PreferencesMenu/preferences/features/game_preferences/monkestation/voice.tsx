import { CheckboxInput, FeatureToggle } from '../../base';

export const voice_sounds_short: FeatureToggle = {
  name: 'Voice Sounds: Single Bark',
  category: 'VOICE SOUNDS',
  description:
    'When enabled, you will only hear a single sound when players talk.',
  component: CheckboxInput,
};

export const voice_sounds_limited_pitch: FeatureToggle = {
  name: 'Voice Sounds: Disable Pitch Modification',
  category: 'VOICE SOUNDS',
  description:
    'When enabled, voice sounds will not play with any character pitch modifications.',
  component: CheckboxInput,
};

export const voice_sounds_only_goon: FeatureToggle = {
  name: 'Voice Sounds: Only Goonstation',
  category: 'VOICE SOUNDS',
  description:
    'When enabled, characters will only make goonstation voice sounds.',
  component: CheckboxInput,
};
