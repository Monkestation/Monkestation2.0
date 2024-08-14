import { CheckboxInput, FeatureToggle } from '../base';

export const streamer_mode: FeatureToggle = {
  name: 'Streamer Mode',
  category: 'GAMEPLAY',
  description: 'When enabled, hides potentially offensive words in chat.',
  component: CheckboxInput,
};
