import { CheckboxInput, type FeatureToggle } from '../base';

export const voice_sounds_short: FeatureToggle = {
  name: 'Only One Bark',
  category: 'VOICE SOUNDS',
  description: 'When enabled, you will only hear one sound when players talk.',
  component: CheckboxInput,
};

export const voice_sounds_limited_pitch: FeatureToggle = {
  name: 'No Pitch Modification',
  category: 'VOICE SOUNDS',
  description:
    'When enabled, voice sounds will not play with any character pitch modifications.',
  component: CheckboxInput,
};

export const voice_sounds_only_goon: FeatureToggle = {
  name: 'Only Simple Sounds',
  category: 'VOICE SOUNDS',
  description:
    'When enabled, characters will only make simple voice sounds. (Goonstation Speak 1-4)',
  component: CheckboxInput,
};
