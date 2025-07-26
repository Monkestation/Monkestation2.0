import { CheckboxInput, FeatureToggle } from '../base';

export const show_init_stats: FeatureToggle = {
  name: 'Enable Lobby Game Stats',
  category: 'UI',
  description:
    'When enabled, the lobby screen will report how long game set up is taking.',
  component: CheckboxInput,
};
