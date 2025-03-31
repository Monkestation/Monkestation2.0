import { CheckboxInput, FeatureToggle } from '../../base';

export const sound_short_barks: FeatureToggle = {
  name: 'Short Bark Sounds',
  category: 'SOUND',
  description:
    'When enabled, you will only hear a single sound when players talk.',
  component: CheckboxInput,
};
