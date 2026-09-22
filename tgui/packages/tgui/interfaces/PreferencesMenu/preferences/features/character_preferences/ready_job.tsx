import { CheckboxInput, type FeatureToggle } from '../base';

export const ready_job: FeatureToggle = {
  name: 'Show Name in Job Readying',
  category: 'GAMEPLAY',
  description:
    'Toggles whether your name shows in the pre-game Job Estimation panel. \
    Note: Command roles and AI will show with your name regardless of this pref.',
  component: CheckboxInput,
};
